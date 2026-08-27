"""Location-based veterinary doctor discovery and geographic language mapping models."""

from sqlalchemy import Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class VeterinaryService(Base):
    """Veterinary hospital and doctor contact registry for direct emergency calls."""
    __tablename__ = "veterinary_services"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    clinic_name: Mapped[str] = mapped_column(String(100), nullable=False)
    doctor_name: Mapped[str] = mapped_column(String(100), nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    sub_district: Mapped[str] = mapped_column(String(50), nullable=False)
    phone_number: Mapped[str] = mapped_column(String(20), nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    service_type: Mapped[str] = mapped_column(String(50), default="CATTLE_POULTRY")


class GeoRegionLanguageMap(Base):
    """Maps district GPS coordinates to regional languages and farming dialect packs."""
    __tablename__ = "geo_region_language_maps"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    regional_language_code: Mapped[str] = mapped_column(String(10), nullable=False)
    dialect_pack_id: Mapped[str] = mapped_column(String(50), nullable=False)
