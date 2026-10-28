from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.models.user import UserRole


class OTPRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with country code")


class OTPResponse(BaseModel):
    status: str = "success"
    message: str = "OTP dispatched"
    expires_in_seconds: int = 300


class UserRegisterRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with country code")
    password: Optional[str] = Field(default=None, description="Optional user password")
    full_name: Optional[str] = None
    role: UserRole = UserRole.FARMER
    preferred_language: str = "ta"

    @field_validator("role")
    @classmethod
    def validate_public_role(cls, v: UserRole) -> UserRole:
        if v not in (UserRole.FARMER, UserRole.BUYER):
            raise ValueError(
                "Registration is only permitted for FARMER or BUYER roles. "
                "Administrator accounts must be provisioned through controlled administrative procedures."
            )
        return v


class UserLoginRequest(BaseModel):
    phone_number: str = Field(..., description="Mobile number with country code")
    password: str = Field(..., description="User password")


class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp: Optional[str] = None
    otp_code: Optional[str] = None

    @property
    def code(self) -> str:
        return (self.otp or self.otp_code or "").strip()


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    is_new_user: bool = False
    user: Optional["UserProfileResponse"] = None


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

