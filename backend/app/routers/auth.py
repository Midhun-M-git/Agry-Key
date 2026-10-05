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
from app.services.otp_provider import get_otp_provider
from app.utils.phone import (
    generate_otp_code,
    hash_otp,
    normalize_indian_phone,
    verify_otp_hash,
)

import logging

logger = logging.getLogger("auth")

router = APIRouter(prefix="/auth", tags=["Authentication & Accounts"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

_OTP_EXPIRY_MINUTES = 5
_OTP_REQUEST_WINDOW_SECONDS = 10 * 60
_OTP_REQUEST_COOLDOWN_SECONDS = 60
_OTP_REQUEST_LIMIT = 3
_MAX_VERIFY_ATTEMPTS = 5
_otp_requests: dict[str, deque[datetime]] = defaultdict(deque)


def _enforce_otp_rate_limit(phone_number: str, now: datetime) -> None:
    is_mock = getattr(settings, "OTP_PROVIDER", "development") == "development"
    cooldown = 5 if is_mock else _OTP_REQUEST_COOLDOWN_SECONDS
    limit = 20 if is_mock else _OTP_REQUEST_LIMIT
    requests = _otp_requests[phone_number]
    cutoff = now - timedelta(seconds=_OTP_REQUEST_WINDOW_SECONDS)
    while requests and requests[0] < cutoff:
        requests.popleft()

    if requests and (now - requests[-1]).total_seconds() < cooldown:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many attempts. Please wait a little before requesting another OTP.",
        )
    if len(requests) >= limit:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many OTP requests. Please try again after 10 minutes.",
        )
    requests.append(now)


oauth2_scheme_optional = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login", auto_error=False)


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


def get_optional_user(
    token: Optional[str] = Depends(oauth2_scheme_optional), db: Session = Depends(get_db)
) -> Optional[User]:
    """Dependency validating JWT access tokens if present, returning None if unauthenticated."""
    if not token:
        return None
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        return None
    user_id = payload.get("sub")
    if not user_id:
        return None
    try:
        user = db.query(User).filter(User.id == int(user_id)).first()
        if user and user.is_active:
            return user
    except Exception:
        return None
    return None


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


@router.post("/request-otp", response_model=OTPResponse)
@router.post("/send-otp", response_model=OTPResponse)
@router.post("/recover", response_model=OTPResponse)
async def request_otp(
    req: Optional[OTPRequest] = None,
    phone_number: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    """Dispatches a one-time OTP code for mobile login or account recovery."""
    raw_phone = None
    if req and req.phone_number:
        raw_phone = req.phone_number.strip()
    elif phone_number:
        raw_phone = phone_number.strip()

    if not raw_phone:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Mobile number is required.",
        )

    try:
        normalized_phone = normalize_indian_phone(raw_phone)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    now = datetime.now(timezone.utc)
    _enforce_otp_rate_limit(normalized_phone, now)

    otp_code = generate_otp_code()
    otp_hash_val = hash_otp(normalized_phone, otp_code, settings.SECRET_KEY)
    expires_at = now + timedelta(minutes=_OTP_EXPIRY_MINUTES)

    # Invalidate prior unverified OTP records for this phone number
    db.query(OTPRecord).filter(
        OTPRecord.phone_number == normalized_phone,
        OTPRecord.is_verified.is_(False),
    ).update({"is_verified": True})

    otp_entry = OTPRecord(
        phone_number=normalized_phone,
        otp_code=otp_hash_val,
        expires_at=expires_at,
        attempts=0,
    )
    db.add(otp_entry)
    db.commit()

    # Dispatch via the configured OTP provider (Development or SMS)
    provider = get_otp_provider()
    await provider.send_otp(normalized_phone, otp_code)

    return OTPResponse(
        status="success",
        message="Verification code sent to your mobile number.",
        expires_in_seconds=_OTP_EXPIRY_MINUTES * 60,
        otp_code=otp_code,
    )


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(req: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verifies the OTP hash, enforces attempt limits, and logs in or creates the farmer account."""
    raw_phone = req.phone_number.strip()
    try:
        normalized_phone = normalize_indian_phone(raw_phone)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        )

    code = req.code
    if not code or len(code) != 6 or not code.isdigit():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Please enter a valid 6-digit OTP code.",
        )

    otp_entry = (
        db.query(OTPRecord)
        .filter(
            OTPRecord.phone_number == normalized_phone,
            OTPRecord.is_verified.is_(False),
        )
        .order_by(OTPRecord.created_at.desc())
        .first()
    )
    if not otp_entry:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No active OTP found. Please request a new verification code.",
        )

    # Enforce attempt limit
    if otp_entry.attempts >= _MAX_VERIFY_ATTEMPTS:
        otp_entry.is_verified = True
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Too many failed attempts. Please request a new verification code.",
        )

    # Check expiry
    now = datetime.now(timezone.utc)
    expires_at = otp_entry.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)

    if expires_at <= now:
        otp_entry.is_verified = True
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Verification code has expired. Please request a new OTP.",
        )

    # Cryptographic hash verification against stored DB entry
    is_valid = verify_otp_hash(normalized_phone, code, settings.SECRET_KEY, otp_entry.otp_code)

    # Or verify via Twilio Verify API if configured
    if not is_valid and settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN:
        from app.services.otp_provider import TwilioVerifyOTPProvider
        is_valid = await TwilioVerifyOTPProvider.verify_code(normalized_phone, code)

    if not is_valid:
        otp_entry.attempts += 1
        db.commit()
        remaining = _MAX_VERIFY_ATTEMPTS - otp_entry.attempts
        detail_msg = (
            f"Invalid OTP code. {remaining} attempt(s) remaining."
            if remaining > 0
            else "Too many failed attempts. Please request a new OTP."
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=detail_msg,
        )

    # OTP is verified
    otp_entry.is_verified = True
    db.commit()

    # Look up existing user
    user = db.query(User).filter(User.phone_number == normalized_phone).first()
    is_new = False

    if not user:
        # Create new farmer account automatically
        is_new = True
        user = User(
            phone_number=normalized_phone,
            role=UserRole.FARMER,
            preferred_language="ta",
            is_active=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        # Create default farmer profile
        profile = FarmerProfile(
            user_id=user.id,
            state="",
            district="",
            voice_preference=True,
        )
        db.add(profile)
        db.commit()

    # Issue JWT tokens for persistent session
    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    profile_resp = UserProfileResponse.model_validate(user)
    profile_resp.access_token = access_token
    profile_resp.refresh_token = refresh_token

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        is_new_user=is_new,
        user=profile_resp,
    )


@router.get("/me", response_model=UserProfileResponse)
def get_me(current_user: User = Depends(get_current_user)):
    """Returns profile details for the currently authenticated user session."""
    return current_user
