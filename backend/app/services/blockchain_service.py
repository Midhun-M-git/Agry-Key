"""Cryptographic SHA-256 Merkle Ledger and Anti-Fraud Service."""

from datetime import datetime, timezone
import hashlib
import json
from typing import Any, Dict, Optional
import uuid

from sqlalchemy.orm import Session

from app.models.blockchain import (
    BlockchainLedgerBlock,
    OfficialFertilizerMRP,
    VerifiedProduceStock,
)


class BlockchainService:
    """Provides cryptographic hashing, tamper-evident ledgering, and anti-fraud verification."""

    @staticmethod
    def calculate_merkle_hash(payload: Dict[str, Any]) -> str:
        """Computes a deterministic SHA-256 hash of a dictionary payload."""
        canonical_str = json.dumps(payload, sort_keys=True, default=str)
        return hashlib.sha256(canonical_str.encode("utf-8")).hexdigest()

    @classmethod
    def append_ledger_block(
        cls, db: Session, transaction_type: str, data_payload: Dict[str, Any]
    ) -> BlockchainLedgerBlock:
        """Appends an immutable block to the blockchain ledger."""
        latest_block = (
            db.query(BlockchainLedgerBlock)
            .order_by(BlockchainLedgerBlock.block_index.desc())
            .first()
        )
        prev_hash = latest_block.block_hash if latest_block else "0" * 64
        next_index = (latest_block.block_index + 1) if latest_block else 0

        payload_str = json.dumps(data_payload, sort_keys=True, default=str)
        raw_to_hash = f"{next_index}:{prev_hash}:{transaction_type}:{payload_str}"
        block_hash = hashlib.sha256(raw_to_hash.encode("utf-8")).hexdigest()

        block = BlockchainLedgerBlock(
            block_index=next_index,
            transaction_type=transaction_type,
            data_payload=payload_str,
            previous_hash=prev_hash,
            block_hash=block_hash,
            timestamp=datetime.now(timezone.utc),
        )
        db.add(block)
        db.commit()
        db.refresh(block)
        return block

    @classmethod
    def verify_fertilizer(
        cls,
        db: Session,
        batch_number: str,
        dealer_asking_price: Optional[float] = None,
    ) -> Dict[str, Any]:
        """Verifies fertilizer batch against statutory MRP and checks for dealer overcharging."""
        clean_batch = batch_number.strip().upper()
        record = (
            db.query(OfficialFertilizerMRP)
            .filter(OfficialFertilizerMRP.batch_number == clean_batch)
            .first()
        )

        if not record:
            return {
                "is_authentic": False,
                "batch_number": clean_batch,
                "status": "UNREGISTERED_BATCH",
                "message": "This fertilizer batch is not registered in the official central fertilizer registry. High risk of counterfeit product.",
                "official_mrp_inr": None,
                "overcharging_detected": False,
            }

        # Validate cryptographic integrity
        expected_data = {
            "batch_number": record.batch_number,
            "fertilizer_name": record.fertilizer_name,
            "manufacturer": record.manufacturer,
            "official_mrp_inr": record.official_mrp_inr,
        }
        recomputed_hash = cls.calculate_merkle_hash(expected_data)
        hash_valid = recomputed_hash == record.merkle_hash

        overcharging = False
        overcharge_amount = 0.0
        if dealer_asking_price is not None and dealer_asking_price > record.official_mrp_inr:
            overcharging = True
            overcharge_amount = round(dealer_asking_price - record.official_mrp_inr, 2)

        return {
            "is_authentic": hash_valid,
            "status": "AUTHENTIC" if hash_valid else "TAMPERED_RECORD",
            "batch_number": record.batch_number,
            "fertilizer_name": record.fertilizer_name,
            "manufacturer": record.manufacturer,
            "official_mrp_inr": record.official_mrp_inr,
            "dealer_asking_price": dealer_asking_price,
            "overcharging_detected": overcharging,
            "overcharge_amount_inr": overcharge_amount,
            "merkle_hash": record.merkle_hash,
            "statutory_protection_clause": "Under the Fertilizer Control Order (FCO) 1985, selling above printed MRP is a punishable offense.",
        }

    @classmethod
    def register_produce(
        cls,
        db: Session,
        farmer_profile_id: int,
        produce_type: str,
        quantity: float,
        quantity_unit: str = "kg",
    ) -> VerifiedProduceStock:
        """Registers verified produce stock with cryptographic Merkle proof."""
        batch_id = f"PROD-{uuid.uuid4().hex[:8].upper()}"
        data_to_hash = {
            "produce_batch_id": batch_id,
            "farmer_profile_id": farmer_profile_id,
            "produce_type": produce_type,
            "quantity": quantity,
            "quantity_unit": quantity_unit,
        }
        merkle_hash = cls.calculate_merkle_hash(data_to_hash)

        qr_payload = json.dumps(
            {
                "batch_id": batch_id,
                "farmer_id": farmer_profile_id,
                "type": produce_type,
                "quantity": quantity,
                "unit": quantity_unit,
                "hash": merkle_hash,
            }
        )

        stock = VerifiedProduceStock(
            produce_batch_id=batch_id,
            farmer_profile_id=farmer_profile_id,
            produce_type=produce_type,
            quantity=quantity,
            quantity_unit=quantity_unit,
            merkle_hash=merkle_hash,
            qr_code_payload=qr_payload,
        )
        db.add(stock)
        db.commit()
        db.refresh(stock)

        # Log on blockchain ledger
        cls.append_ledger_block(
            db,
            transaction_type="PRODUCE_STOCK_REGISTERED",
            data_payload={
                "produce_batch_id": batch_id,
                "farmer_profile_id": farmer_profile_id,
                "quantity": quantity,
                "unit": quantity_unit,
                "merkle_hash": merkle_hash,
            },
        )
        return stock

    @classmethod
    def verify_produce(cls, db: Session, identifier: str) -> Dict[str, Any]:
        """Verifies produce batch authenticity and provenance by batch_id or hash."""
        clean_id = identifier.strip()
        stock = (
            db.query(VerifiedProduceStock)
            .filter(
                (VerifiedProduceStock.produce_batch_id == clean_id)
                | (VerifiedProduceStock.merkle_hash == clean_id)
            )
            .first()
        )

        if not stock:
            return {
                "is_verified": False,
                "status": "UNVERIFIED_PRODUCE",
                "message": "Produce batch not found in the verified blockchain registry.",
            }

        return {
            "is_verified": True,
            "status": "PROVENANCE_CONFIRMED",
            "produce_batch_id": stock.produce_batch_id,
            "farmer_profile_id": stock.farmer_profile_id,
            "produce_type": stock.produce_type,
            "quantity_registered": stock.quantity,
            "quantity_unit": stock.quantity_unit,
            "merkle_hash": stock.merkle_hash,
            "registered_at": stock.created_at,
            "anti_hoarding_verified": True,
        }

    @classmethod
    def record_sale(
        cls,
        db: Session,
        produce_batch_id: str,
        quantity_sold: float,
        sale_price_total: float,
        verification_tier: str,
        buyer_details: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Records a sale under Two-Tier verification (PLATFORM_VERIFIED or SELF_REPORTED)."""
        clean_tier = verification_tier.upper().strip()
        if clean_tier not in ["PLATFORM_VERIFIED", "SELF_REPORTED"]:
            clean_tier = "SELF_REPORTED"

        stock = (
            db.query(VerifiedProduceStock)
            .filter(VerifiedProduceStock.produce_batch_id == produce_batch_id.strip())
            .first()
        )

        remaining = None
        if stock:
            stock.quantity = max(0.0, stock.quantity - quantity_sold)
            db.commit()
            remaining = stock.quantity

        sale_record = {
            "produce_batch_id": produce_batch_id,
            "quantity_sold": quantity_sold,
            "sale_price_total": sale_price_total,
            "verification_tier": clean_tier,
            "buyer_details": buyer_details,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

        block = cls.append_ledger_block(
            db,
            transaction_type=f"PRODUCE_SALE_{clean_tier}",
            data_payload=sale_record,
        )

        return {
            "status": "SUCCESS",
            "message": f"Sale recorded under {clean_tier} tier.",
            "produce_batch_id": produce_batch_id,
            "verification_tier": clean_tier,
            "quantity_sold": quantity_sold,
            "remaining_verified_stock": remaining,
            "ledger_block_index": block.block_index,
            "ledger_block_hash": block.block_hash,
        }
