from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

from app.models.user import UserRole


class OTPRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with country code")


class OTPResponse(BaseModel):
    status: str
    message: str
    expires_in_seconds: int = 600
    otp: Optional[str] = None
    sms_delivered: bool = False


class UserRegisterRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with country code")
    password: str = Field(..., min_length=6, description="User password")
    full_name: Optional[str] = None
    role: UserRole = UserRole.FARMER
    preferred_language: str = "ta"


class UserLoginRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with country code")
    password: str = Field(..., description="User password")


class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp_code: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class UserProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    phone_number: str
    full_name: Optional[str] = None
    role: UserRole
    preferred_language: str
    is_active: bool
    created_at: datetime
    access_token: Optional[str] = None
    refresh_token: Optional[str] = None

