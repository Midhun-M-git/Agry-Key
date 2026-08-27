"""Production harvest and sale records across crops, dairy, poultry, and fish."""

from datetime import datetime, timezone
import enum
from typing import Optional
from sqlalchemy import DateTime, Enum, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class VerificationTier(str, enum.Enum):
    """Two-tier data verification classification."""
    PLATFORM_VERIFIED = "PLATFORM_VERIFIED"
    SELF_REPORTED = "SELF_REPORTED"


class CropRecord(Base):
    """Harvest and sale record for agricultural crop plots."""
    __tablename__ = "crop_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    plot_id: Mapped[int] = mapped_column(ForeignKey("agricultural_plots.id"), nullable=False)
    crop_name: Mapped[str] = mapped_column(String(50), nullable=False)
    season: Mapped[str] = mapped_column(String(20), nullable=False)
    quantity_produced: Mapped[float] = mapped_column(Float, nullable=False)
    quantity_unit: Mapped[str] = mapped_column(String(20), default="quintal")
    sale_price_per_unit: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    input_cost_total: Mapped[float] = mapped_column(Float, default=0.0)
    verification_tier: Mapped[VerificationTier] = mapped_column(
        Enum(VerificationTier), default=VerificationTier.SELF_REPORTED
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class LivestockRecord(Base):
    """Yield and feed record for livestock production units."""
    __tablename__ = "livestock_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    unit_id: Mapped[int] = mapped_column(ForeignKey("livestock_units.id"), nullable=False)
    product_name: Mapped[str] = mapped_column(String(50), default="Milk")
    daily_yield_liters: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    sale_price_per_liter: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    feed_cost_monthly: Mapped[float] = mapped_column(Float, default=0.0)
    verification_tier: Mapped[VerificationTier] = mapped_column(
        Enum(VerificationTier), default=VerificationTier.SELF_REPORTED
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class PoultryRecord(Base):
    """Egg yield and feed record for poultry units."""
    __tablename__ = "poultry_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    unit_id: Mapped[int] = mapped_column(ForeignKey("poultry_units.id"), nullable=False)
    daily_egg_count: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    sale_price_per_egg: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    feed_cost_monthly: Mapped[float] = mapped_column(Float, default=0.0)
    verification_tier: Mapped[VerificationTier] = mapped_column(
        Enum(VerificationTier), default=VerificationTier.SELF_REPORTED
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class AquacultureRecord(Base):
    """Fish harvest and feed record for aquaculture units."""
    __tablename__ = "aquaculture_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    unit_id: Mapped[int] = mapped_column(ForeignKey("aquaculture_units.id"), nullable=False)
    fish_harvest_kg: Mapped[float] = mapped_column(Float, nullable=False)
    sale_price_per_kg: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    feed_cost_cycle: Mapped[float] = mapped_column(Float, default=0.0)
    verification_tier: Mapped[VerificationTier] = mapped_column(
        Enum(VerificationTier), default=VerificationTier.SELF_REPORTED
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
