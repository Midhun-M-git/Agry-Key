"""Official primary source economic indexes.

All data in these tables is fetched and verified by the Data Checker Agent (Phase 4)
from official government primary sources. No data is hardcoded here.

Sources:
- Fertilizer MRP      → mFMS Portal (Ministry of Chemicals & Fertilizers)
- Fuel rates          → PPAC Portal (Petroleum Planning & Analysis Cell)
- Feed prices         → NDDB, NFDB, KEPCO, State Poultry Boards
- Labour rates        → State Labour Department / MGNREGA wage notifications
- Electricity tariffs → State Electricity Regulatory Commissions (SERC)
- Transport costs     → PPAC fuel rates × distance model
- Market prices       → Agmarknet APMC, NDDB, Matsyafed, State Fisheries Boards
"""

from datetime import datetime, timezone
from sqlalchemy import DateTime, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class FertilizerPriceIndex(Base):
    """Official mFMS manufacturer MRP price index for fertilizers (national MRP, state subsidy offsets vary)."""
    __tablename__ = "fertilizer_price_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    fertilizer_type: Mapped[str] = mapped_column(String(50), nullable=False)
    bag_weight_kg: Mapped[float] = mapped_column(Float, default=45.0)
    official_mrp_per_bag: Mapped[float] = mapped_column(Float, nullable=False)
    state: Mapped[str] = mapped_column(String(50), nullable=True)
    state_subsidy_offset: Mapped[float] = mapped_column(Float, default=0.0)
    effective_price_per_bag: Mapped[float] = mapped_column(Float, nullable=False)
    official_source: Mapped[str] = mapped_column(String(100), default="mFMS Portal")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class FuelPriceIndex(Base):
    """Official PPAC district-level diesel and petrol retail rates (varies by state tax structure)."""
    __tablename__ = "fuel_price_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    diesel_rate_per_liter: Mapped[float] = mapped_column(Float, nullable=False)
    petrol_rate_per_liter: Mapped[float] = mapped_column(Float, nullable=False)
    official_source: Mapped[str] = mapped_column(String(100), default="PPAC Portal")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class FeedPriceIndex(Base):
    """Official livestock, poultry, and aquaculture feed price index per state."""
    __tablename__ = "feed_price_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    sector: Mapped[str] = mapped_column(String(20), nullable=False)
    feed_name: Mapped[str] = mapped_column(String(50), nullable=False)
    official_price_per_kg: Mapped[float] = mapped_column(Float, nullable=False)
    official_source: Mapped[str] = mapped_column(String(100), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class LabourRateIndex(Base):
    """State-wise and seasonal agricultural labour rate index (sourced from State Labour Dept / MGNREGA)."""
    __tablename__ = "labour_rate_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=True)
    labour_type: Mapped[str] = mapped_column(String(50), nullable=False)
    rate_per_day_inr: Mapped[float] = mapped_column(Float, nullable=False)
    season: Mapped[str] = mapped_column(String(20), nullable=True)
    official_source: Mapped[str] = mapped_column(String(100), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class ElectricityTariffIndex(Base):
    """State Electricity Regulatory Commission (SERC) agricultural pump tariff per unit."""
    __tablename__ = "electricity_tariff_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    state: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    consumer_category: Mapped[str] = mapped_column(String(50), nullable=False)
    rate_per_unit_inr: Mapped[float] = mapped_column(Float, nullable=False)
    official_source: Mapped[str] = mapped_column(String(100), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class TransportCostIndex(Base):
    """District-to-mandi transport cost model derived from fuel rates and distance bands."""
    __tablename__ = "transport_cost_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    from_district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    to_mandi: Mapped[str] = mapped_column(String(100), nullable=False)
    distance_km: Mapped[float] = mapped_column(Float, nullable=False)
    estimated_cost_per_quintal_inr: Mapped[float] = mapped_column(Float, nullable=False)
    vehicle_type: Mapped[str] = mapped_column(String(30), default="MINI_TRUCK")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class MarketPriceTrend(Base):
    """Live verified produce market prices from official mandis across all food sectors."""
    __tablename__ = "market_price_trends"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    commodity_name: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    sector: Mapped[str] = mapped_column(String(20), nullable=False)
    state: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    mandi_name: Mapped[str] = mapped_column(String(100), nullable=False)
    modal_price: Mapped[float] = mapped_column(Float, nullable=False)
    min_price: Mapped[float] = mapped_column(Float, nullable=False)
    max_price: Mapped[float] = mapped_column(Float, nullable=False)
    price_unit: Mapped[str] = mapped_column(String(20), default="quintal")
    official_source: Mapped[str] = mapped_column(String(100), nullable=False)
    fetched_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
