"""Pinpointed regional soil survey and soil health models.

Supports:
1. Ground Survey Data collected by developer field survey teams per village/taluk.
2. Official Soil Health Card (SHC) laboratory test results uploaded by/for farmers.
3. KVK / State Soil Testing Laboratory reference data per district.
"""

from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class DistrictSoilSurvey(Base):
    """Ground soil survey data collected by developer/field survey teams per village/taluk.
    
    This is populated when survey teams physically visit regions to collect soil sample tests.
    """
    __tablename__ = "district_soil_surveys"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    taluk_block: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    village_panchayath: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    # Soil chemical & physical properties
    soil_type: Mapped[str] = mapped_column(String(50), nullable=False)  # e.g., RED_LOAMY, BLACK_COTTON, LATERITE
    ph_level: Mapped[float] = mapped_column(Float, nullable=False)       # 0.0 - 14.0
    electrical_conductivity_ec: Mapped[Optional[float]] = mapped_column(Float, nullable=True) # dS/m
    organic_carbon_percent: Mapped[Optional[float]] = mapped_column(Float, nullable=True)     # %
    nitrogen_kg_per_hectare: Mapped[Optional[float]] = mapped_column(Float, nullable=True)   # N (kg/ha)
    phosphorus_kg_per_hectare: Mapped[Optional[float]] = mapped_column(Float, nullable=True) # P (kg/ha)
    potassium_kg_per_hectare: Mapped[Optional[float]] = mapped_column(Float, nullable=True)  # K (kg/ha)

    surveyor_name: Mapped[str] = mapped_column(String(100), default="Field Survey Team")
    tested_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class FarmerSoilHealthCard(Base):
    """Farmer's specific Soil Health Card (SHC) issued by KVK / Soil Testing Lab."""
    __tablename__ = "farmer_soil_health_cards"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    plot_id: Mapped[Optional[int]] = mapped_column(ForeignKey("agricultural_plots.id"), nullable=True)
    shc_number: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    ph_level: Mapped[float] = mapped_column(Float, nullable=False)
    organic_carbon_percent: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    nitrogen_status: Mapped[str] = mapped_column(String(20), default="MEDIUM")   # LOW, MEDIUM, HIGH
    phosphorus_status: Mapped[str] = mapped_column(String(20), default="MEDIUM") # LOW, MEDIUM, HIGH
    potassium_status: Mapped[str] = mapped_column(String(20), default="MEDIUM")  # LOW, MEDIUM, HIGH

    testing_lab_name: Mapped[str] = mapped_column(String(100), nullable=False)
    issue_date: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
