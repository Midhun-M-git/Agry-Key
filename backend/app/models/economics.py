from datetime import datetime, timezone
from sqlalchemy import DateTime, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class FertilizerPriceIndex(Base):
    __tablename__ = "fertilizer_price_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    fertilizer_type: Mapped[str] = mapped_column(String(50), nullable=False)  # Urea, DAP, NPK, MOP
    official_mrp_per_bag: Mapped[float] = mapped_column(Float, nullable=False)
    bag_weight_kg: Mapped[float] = mapped_column(Float, default=45.0)
    official_source: Mapped[str] = mapped_column(String(50), default="mFMS Portal")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class FuelPriceIndex(Base):
    __tablename__ = "fuel_price_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    diesel_rate_per_liter: Mapped[float] = mapped_column(Float, nullable=False)
    petrol_rate_per_liter: Mapped[float] = mapped_column(Float, nullable=False)
    official_source: Mapped[str] = mapped_column(String(50), default="PPAC Portal")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class FeedPriceIndex(Base):
    __tablename__ = "feed_price_index"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    sector: Mapped[str] = mapped_column(String(20), nullable=False)  # DAIRY, POULTRY, AQUACULTURE
    feed_name: Mapped[str] = mapped_column(String(50), nullable=False)
    official_price_per_kg: Mapped[float] = mapped_column(Float, nullable=False)
    official_source: Mapped[str] = mapped_column(String(50), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class MarketPriceTrend(Base):
    __tablename__ = "market_price_trends"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    commodity_name: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    sector: Mapped[str] = mapped_column(String(20), nullable=False)  # CROPS, DAIRY, POULTRY, FISH
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    mandi_name: Mapped[str] = mapped_column(String(50), nullable=False)
    modal_price: Mapped[float] = mapped_column(Float, nullable=False)
    min_price: Mapped[float] = mapped_column(Float, nullable=False)
    max_price: Mapped[float] = mapped_column(Float, nullable=False)
    price_unit: Mapped[str] = mapped_column(String(20), default="quintal")
    official_source: Mapped[str] = mapped_column(String(50), nullable=False)  # Agmarknet, NDDB, NFDB
    fetched_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
