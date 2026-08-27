"""Multi-sector farm portfolio models (crop land, cattle, poultry, fish ponds)."""

from typing import Optional
from sqlalchemy import Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class AgriculturalPlot(Base):
    """Crop plot entity capturing acreage, soil type, and primary water source."""
    __tablename__ = "agricultural_plots"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    plot_name: Mapped[str] = mapped_column(String(50), default="Main Plot")
    acreage: Mapped[float] = mapped_column(Float, nullable=False)
    soil_type: Mapped[str] = mapped_column(String(50), nullable=False)
    water_source: Mapped[str] = mapped_column(String(50), nullable=False)
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)


class LivestockUnit(Base):
    """Livestock production unit (cows, buffaloes, goats, sheep)."""
    __tablename__ = "livestock_units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    animal_type: Mapped[str] = mapped_column(String(50), nullable=False)
    breed: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    head_count: Mapped[int] = mapped_column(Integer, nullable=False)
    purpose: Mapped[str] = mapped_column(String(20), default="DAIRY")


class PoultryUnit(Base):
    """Poultry production unit (hens, ducks)."""
    __tablename__ = "poultry_units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    bird_type: Mapped[str] = mapped_column(String(50), default="Hen")
    bird_count: Mapped[int] = mapped_column(Integer, nullable=False)
    purpose: Mapped[str] = mapped_column(String(20), default="EGGS")


class AquacultureUnit(Base):
    """Aquaculture pond production unit (freshwater/brackish fish farming)."""
    __tablename__ = "aquaculture_units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    pond_name: Mapped[str] = mapped_column(String(50), default="Pond 1")
    pond_size_acres: Mapped[float] = mapped_column(Float, nullable=False)
    fish_species: Mapped[str] = mapped_column(String(100), nullable=False)
    water_type: Mapped[str] = mapped_column(String(20), default="FRESHWATER")
