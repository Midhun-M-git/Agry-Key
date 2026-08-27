from sqlalchemy import Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class VeterinaryService(Base):
    __tablename__ = "veterinary_services"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    clinic_name: Mapped[str] = mapped_column(String(100), nullable=False)
    doctor_name: Mapped[str] = mapped_column(String(100), nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    sub_district: Mapped[str] = mapped_column(String(50), nullable=False)
    phone_number: Mapped[str] = mapped_column(String(20), nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    service_type: Mapped[str] = mapped_column(String(50), default="CATTLE_POULTRY")  # GOVT, PRIVATE, EMERGENCY


class GeoRegionLanguageMap(Base):
    __tablename__ = "geo_region_language_maps"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    regional_language_code: Mapped[str] = mapped_column(String(10), nullable=False)  # ta, hi, ml, te, mr, etc.
    dialect_pack_id: Mapped[str] = mapped_column(String(50), nullable=False)  # kongu_tamil, marathwada_marathi
