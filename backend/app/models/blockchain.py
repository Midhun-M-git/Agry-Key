"""Cryptographic SHA-256 Merkle Ledger and Anti-Fraud Verification Registries."""

from datetime import datetime, timezone
from sqlalchemy import DateTime, Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class OfficialFertilizerMRP(Base):
    """Official fertilizer manufacturer batch MRP registry for dealer overcharging protection."""
    __tablename__ = "official_fertilizer_mrp"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    batch_number: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    manufacturer: Mapped[str] = mapped_column(String(100), nullable=False)
    fertilizer_name: Mapped[str] = mapped_column(String(100), nullable=False)
    official_mrp_inr: Mapped[float] = mapped_column(Float, nullable=False)
    merkle_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    qr_code_payload: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class VerifiedProduceStock(Base):
    """Verified farmer produce stock registry for anti-hoarding provenance proof."""
    __tablename__ = "verified_produce_stock"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    produce_batch_id: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    farmer_profile_id: Mapped[int] = mapped_column(Integer, nullable=False)
    produce_type: Mapped[str] = mapped_column(String(50), nullable=False)
    quantity: Mapped[float] = mapped_column(Float, nullable=False)
    quantity_unit: Mapped[str] = mapped_column(String(20), default="kg")
    merkle_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    qr_code_payload: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class BlockchainLedgerBlock(Base):
    """Immutable SHA-256 Merkle-hash ledger blocks."""
    __tablename__ = "blockchain_ledger_blocks"

    block_index: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    transaction_type: Mapped[str] = mapped_column(String(50), nullable=False)
    data_payload: Mapped[str] = mapped_column(Text, nullable=False)
    previous_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    block_hash: Mapped[str] = mapped_column(String(64), nullable=False)
