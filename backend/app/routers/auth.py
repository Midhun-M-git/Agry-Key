"""Authentication, JWT session management, registration, and OTP recovery router."""

from datetime import datetime, timedelta, timezone
from collections import defaultdict, deque
import secrets

import httpx
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.security import OAuth2PasswordBearer
from typing import Optional
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_password_hash,
    verify_password,
)
from app.models.user import User, FarmerProfile, OTPRecord, UserRole
from app.schemas.user import (
    OTPRequest,
    OTPResponse,
    OTPVerifyRequest,
    TokenResponse,
    UserLoginRequest,
    UserProfileResponse,
    UserRegisterRequest,
)

import logging

logger = logging.getLogger("auth")

router = APIRouter(prefix="/auth", tags=["Authentication & Accounts"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

_OTP_EXPIRY_MINUTES = 10
_OTP_REQUEST_WINDOW_SECONDS = 10 * 60
_OTP_REQUEST_COOLDOWN_SECONDS = 60
_OTP_REQUEST_LIMIT = 3
_otp_requests: dict[str, deque[datetime]] = defaultdict(deque)


def _enforce_otp_rate_limit(phone_number: str, now: datetime) -> None:
    is_mock = not settings.SMS_API_KEY or settings.SMS_API_KEY in ("mock", "test")
    cooldown = 5 if is_mock else _OTP_REQUEST_COOLDOWN_SECONDS
    limit = 20 if is_mock else _OTP_REQUEST_LIMIT
    requests = _otp_requests[phone_number]
    cutoff = now - timedelta(seconds=_OTP_REQUEST_WINDOW_SECONDS)
    while requests and requests[0] < cutoff:
        requests.popleft()

    if requests and (now - requests[-1]).total_seconds() < cooldown:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Please wait before requesting another OTP",
        )
    if len(requests) >= limit:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many OTP requests. Try again later",
        )
    requests.append(now)


def _send_otp_sms(phone_number: str, otp_code: str) -> bool:
    # Always log clearly to console/stdout so Render & local logs show the OTP
    print(f"\n=======================================================", flush=True)
    print(f"🔑 [AGRY-KEY OTP] Mobile: {phone_number} | Code: {otp_code}", flush=True)
    print(f"=======================================================\n", flush=True)
    logger.info(f"🔑 [AGRY-KEY OTP] Mobile: {phone_number} | Code: {otp_code}")

    # Allow mock / test mode when SMS_API_KEY is unset, 'mock' or 'test'
    if not settings.SMS_API_KEY or settings.SMS_API_KEY in ("mock", "test"):
        return False

    provider = (settings.SMS_PROVIDER or "msg91").lower()
    if provider == "twilio":
        if not (settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN and settings.TWILIO_FROM_NUMBER):
            logger.warning("Twilio SMS credentials incomplete. Falling back to console OTP.")
            return False
        try:
            url = f"https://api.twilio.com/2010-04-01/Accounts/{settings.TWILIO_ACCOUNT_SID}/Messages.json"
            response = httpx.post(
                url,
                auth=(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN),
                data={
                    "From": settings.TWILIO_FROM_NUMBER,
                    "To": phone_number,
                    "Body": f"Your Agry-Key OTP verification code is {otp_code}. Valid for {_OTP_EXPIRY_MINUTES} minutes.",
                },
                timeout=10,
            )
            response.raise_for_status()
            return True
        except Exception as exc:
            logger.error(f"Unable to deliver OTP via Twilio: {exc}")
            return False
    else:
        # Default MSG91
        if not settings.SMS_API_KEY:
            logger.warning("MSG91 auth key missing. Falling back to console OTP.")
            return False
        payload = {
            "mobile": phone_number,
            "otp": otp_code,
            "otp_expiry": str(_OTP_EXPIRY_MINUTES),
        }
        if settings.SMS_OTP_TEMPLATE_ID:
            payload["template_id"] = settings.SMS_OTP_TEMPLATE_ID

        try:
            response = httpx.post(
                "https://control.msg91.com/api/v5/otp",
                headers={
                    "authkey": settings.SMS_API_KEY,
                    "Content-Type": "application/json",
                },
                json=payload,
                timeout=10,
            )
            response.raise_for_status()
            return True
        except Exception as exc:
            logger.error(f"Unable to deliver OTP via MSG91: {exc}")
            return False


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> User:
    """Dependency validating JWT access tokens and injecting the active User entity."""
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )
    return user


@router.post("/register", response_model=UserProfileResponse, status_code=status.HTTP_201_CREATED)
def register_user(req: UserRegisterRequest, db: Session = Depends(get_db)):
    """Registers a new user and initializes their default farmer profile."""
    existing = db.query(User).filter(User.phone_number == req.phone_number).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered",
        )

    user = User(
        phone_number=req.phone_number,
        hashed_password=get_password_hash(req.password),
        full_name=req.full_name,
        role=req.role,
        preferred_language=req.preferred_language,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    if req.role == UserRole.FARMER:
        profile = FarmerProfile(
            user_id=user.id,
            state="",
            district="",
            voice_preference=True,
        )
        db.add(profile)
        db.commit()

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    response_data = UserProfileResponse.model_validate(user)
    response_data.access_token = access_token
    response_data.refresh_token = refresh_token
    return response_data


@router.post("/login", response_model=TokenResponse)
def login_user(req: UserLoginRequest, db: Session = Depends(get_db)):
    """Authenticates credentials and returns a JWT access and refresh token pair."""
    user = db.query(User).filter(User.phone_number == req.phone_number).first()
    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password",
        )

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
    )


class RefreshTokenPayload(BaseModel):
    refresh_token: Optional[str] = None
    token: Optional[str] = None


@router.post("/refresh", response_model=TokenResponse)
def refresh_token(
    token: Optional[str] = Query(default=None),
    body: Optional[RefreshTokenPayload] = None,
    db: Session = Depends(get_db),
):
    """Exchanges a valid refresh token for a fresh access token pair."""
    raw_token = token
    if not raw_token and body:
        raw_token = body.refresh_token or body.token

    if not raw_token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Refresh token required in query parameter or request body",
        )

    payload = decode_token(raw_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    user_id = payload.get("sub")
    access_token = create_access_token(subject=user_id)
    new_refresh_token = create_refresh_token(subject=user_id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
    )


@router.post("/send-otp", response_model=OTPResponse)
@router.post("/recover", response_model=OTPResponse)
def request_otp(
    req: Optional[OTPRequest] = None,
    phone_number: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    """Dispatches a one-time OTP code for mobile login or account recovery."""
    target_phone = None
    if req and req.phone_number:
        target_phone = req.phone_number.strip()
    elif phone_number:
        target_phone = phone_number.strip()

    if not target_phone:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number is required",
        )

    now = datetime.now(timezone.utc)
    _enforce_otp_rate_limit(target_phone, now)
    otp_code = f"{secrets.randbelow(1_000_000):06d}"
    expires_at = now + timedelta(minutes=_OTP_EXPIRY_MINUTES)

    sms_delivered = _send_otp_sms(target_phone, otp_code)

    otp_entry = OTPRecord(
        phone_number=target_phone,
        otp_code=otp_code,
        expires_at=expires_at,
    )
    db.add(otp_entry)
    db.commit()

    include_debug_otp = (
        not settings.SMS_API_KEY
        or settings.SMS_API_KEY in ("mock", "test")
        or not sms_delivered
    )

    return OTPResponse(
        status="success",
        message="OTP sent to mobile" if sms_delivered else "OTP generated (logged to server console)",
        expires_in_seconds=_OTP_EXPIRY_MINUTES * 60,
        otp=otp_code if include_debug_otp else None,
        sms_delivered=sms_delivered,
    )


@router.post("/verify-otp")
def verify_otp(req: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verifies the newest unused OTP and logs the user in if already registered."""
    clean_phone = req.phone_number.strip()
    clean_code = req.otp_code.strip()

    otp_entry = (
        db.query(OTPRecord)
        .filter(
            OTPRecord.phone_number == clean_phone,
            OTPRecord.is_verified.is_(False),
        )
        .order_by(OTPRecord.created_at.desc())
        .first()
    )
    if not otp_entry:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP",
        )

    now = datetime.now(timezone.utc)
    expires_at = otp_entry.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at <= now or not secrets.compare_digest(otp_entry.otp_code, clean_code):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP",
        )

    otp_entry.is_verified = True
    db.commit()

    # Check if user with this phone number exists
    user = db.query(User).filter(User.phone_number == clean_phone).first()
    if user and user.is_active:
        access_token = create_access_token(subject=user.id)
        refresh_token = create_refresh_token(subject=user.id)
        role_val = user.role.value if hasattr(user.role, 'value') else str(user.role)
        return {
            "status": "success",
            "message": "OTP verified successfully",
            "user_exists": True,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "user": {
                "id": user.id,
                "phone_number": user.phone_number,
                "full_name": user.full_name or "",
                "role": role_val,
                "preferred_language": user.preferred_language,
            },
        }

    return {
        "status": "success",
        "message": "OTP verified successfully",
        "user_exists": False,
        "phone_number": clean_phone,
    }


@router.get("/me", response_model=UserProfileResponse)
def get_me(current_user: User = Depends(get_current_user)):
    """Returns profile details for the currently authenticated user session."""
    return current_user
