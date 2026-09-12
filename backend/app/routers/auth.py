"""Authentication, JWT session management, registration, and OTP recovery router."""

from datetime import datetime, timedelta, timezone
from collections import defaultdict, deque
import secrets

import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
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
    OTPVerifyRequest,
    TokenResponse,
    UserLoginRequest,
    UserProfileResponse,
    UserRegisterRequest,
)

router = APIRouter(prefix="/auth", tags=["Authentication & Accounts"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

_OTP_EXPIRY_MINUTES = 10
_OTP_REQUEST_WINDOW_SECONDS = 10 * 60
_OTP_REQUEST_COOLDOWN_SECONDS = 60
_OTP_REQUEST_LIMIT = 3
_otp_requests: dict[str, deque[datetime]] = defaultdict(deque)


def _enforce_otp_rate_limit(phone_number: str, now: datetime) -> None:
    requests = _otp_requests[phone_number]
    cutoff = now - timedelta(seconds=_OTP_REQUEST_WINDOW_SECONDS)
    while requests and requests[0] < cutoff:
        requests.popleft()

    if requests and (now - requests[-1]).total_seconds() < _OTP_REQUEST_COOLDOWN_SECONDS:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Please wait before requesting another OTP",
        )
    if len(requests) >= _OTP_REQUEST_LIMIT:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many OTP requests. Try again later",
        )
    requests.append(now)


def _send_otp_sms(phone_number: str, otp_code: str) -> None:
    if not settings.SMS_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="SMS delivery is not configured",
        )

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
    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Unable to deliver OTP",
        ) from exc


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


    return user


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


@router.post("/refresh", response_model=TokenResponse)
def refresh_token(token: str, db: Session = Depends(get_db)):
    """Exchanges a valid refresh token for a fresh access token pair."""
    payload = decode_token(token)
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


@router.post("/recover")
def request_otp_recovery(phone_number: str, db: Session = Depends(get_db)):
    """Dispatches a one-time OTP recovery code for mobile account recovery."""
    now = datetime.now(timezone.utc)
    _enforce_otp_rate_limit(phone_number, now)
    otp_code = f"{secrets.randbelow(1_000_000):06d}"
    expires_at = now + timedelta(minutes=_OTP_EXPIRY_MINUTES)

    _send_otp_sms(phone_number, otp_code)

    otp_entry = OTPRecord(
        phone_number=phone_number,
        otp_code=otp_code,
        expires_at=expires_at,
    )
    db.add(otp_entry)
    db.commit()

    return {
        "status": "success",
        "message": "OTP code dispatched",
        "expires_in_seconds": _OTP_EXPIRY_MINUTES * 60,
    }


@router.post("/verify-otp")
def verify_otp(req: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verifies the newest unused recovery OTP before it expires."""
    otp_entry = (
        db.query(OTPRecord)
        .filter(
            OTPRecord.phone_number == req.phone_number,
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
    if expires_at <= now or not secrets.compare_digest(otp_entry.otp_code, req.otp_code):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP",
        )

    otp_entry.is_verified = True
    db.commit()
    return {"status": "success", "message": "OTP verified"}


@router.get("/me", response_model=UserProfileResponse)
def get_me(current_user: User = Depends(get_current_user)):
    """Returns profile details for the currently authenticated user session."""
    return current_user
