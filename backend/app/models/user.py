"""User accounts, farmer profiles, and mobile OTP authentication models."""

from datetime import datetime, timezone
import enum
from typing import Optional
from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class UserRole(str, enum.Enum):
    """Supported platform user roles."""
    FARMER = "FARMER"
    BUYER = "BUYER"
    ADMIN = "ADMIN"


class User(Base):
    """Core user authentication and account model."""
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    phone_number: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    hashed_password: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    full_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.FARMER, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    preferred_language: Mapped[str] = mapped_column(String(10), default="ta")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    profile: Mapped[Optional["FarmerProfile"]] = relationship("FarmerProfile", back_populates="user", uselist=False)


class FarmerProfile(Base):
    """Top-level farmer profile linking geographic location and voice preferences."""
    __tablename__ = "farmer_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, nullable=False)
    state: Mapped[str] = mapped_column(String(50), nullable=False)
    district: Mapped[str] = mapped_column(String(50), nullable=False)
    sub_district: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    village: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    voice_preference: Mapped[bool] = mapped_column(Boolean, default=True)

    user: Mapped["User"] = relationship("User", back_populates="profile")


class OTPRecord(Base):
    """One-time password dispatch and verification log."""
    __tablename__ = "otp_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    phone_number: Mapped[str] = mapped_column(String(20), index=True, nullable=False)
    otp_code: Mapped[str] = mapped_column(String(10), nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
