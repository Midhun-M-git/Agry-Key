from typing import Optional
from sqlalchemy import Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class AgriculturalPlot(Base):
    __tablename__ = "agricultural_plots"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    plot_name: Mapped[str] = mapped_column(String(50), default="Main Plot")
    acreage: Mapped[float] = mapped_column(Float, nullable=False)
    soil_type: Mapped[str] = mapped_column(String(50), nullable=False)  # Red, Black, Loamy, Alluvial, Clay
    water_source: Mapped[str] = mapped_column(String(50), nullable=False)  # Borewell, Canal, Rainfed, River
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)


class LivestockUnit(Base):
    __tablename__ = "livestock_units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    animal_type: Mapped[str] = mapped_column(String(50), nullable=False)  # Cow, Buffalo, Goat, Sheep
    breed: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    head_count: Mapped[int] = mapped_column(Integer, nullable=False)
    purpose: Mapped[str] = mapped_column(String(20), default="DAIRY")  # DAIRY, MEAT, DUAL


class PoultryUnit(Base):
    __tablename__ = "poultry_units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    bird_type: Mapped[str] = mapped_column(String(50), default="Hen")  # Hen, Duck, Turkey
    bird_count: Mapped[int] = mapped_column(Integer, nullable=False)
    purpose: Mapped[str] = mapped_column(String(20), default="EGGS")  # EGGS, MEAT, DUAL


class AquacultureUnit(Base):
    __tablename__ = "aquaculture_units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(ForeignKey("farmer_profiles.id"), nullable=False)
    pond_name: Mapped[str] = mapped_column(String(50), default="Pond 1")
    pond_size_acres: Mapped[float] = mapped_column(Float, nullable=False)
    fish_species: Mapped[str] = mapped_column(String(100), nullable=False)  # Catfish, Tilapia, Shrimp, Rohu
    water_type: Mapped[str] = mapped_column(String(20), default="FRESHWATER")  # FRESHWATER, BRACKISH
