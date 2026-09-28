"""Cryptographic Blockchain Anti-Fraud, QR Verification, and Produce Registries router."""

from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.blockchain import BlockchainLedgerBlock
from app.models.user import FarmerProfile, User, UserRole
from app.routers.auth import get_current_user
from app.schemas.blockchain import (
    FertilizerVerifyRequest,
    FertilizerVerifyResponse,
    LedgerBlockResponse,
    ProduceRecordSaleRequest,
    ProduceRecordSaleResponse,
    ProduceRegisterRequest,
    ProduceRegisterResponse,
    ProduceVerifyRequest,
    ProduceVerifyResponse,
)
from app.services.blockchain_service import BlockchainService

router = APIRouter(prefix="/blockchain", tags=["Blockchain & Anti-Fraud"])


@router.post("/verify-fertilizer", response_model=FertilizerVerifyResponse)
def verify_fertilizer(req: FertilizerVerifyRequest, db: Session = Depends(get_db)):
    """Verifies fertilizer batch against statutory MRP and detects dealer overcharging."""
    result = BlockchainService.verify_fertilizer(
        db=db,
        batch_number=req.batch_number,
        dealer_asking_price=req.dealer_asking_price,
    )
    return FertilizerVerifyResponse(**result)


@router.get("/verify-fertilizer", response_model=FertilizerVerifyResponse)
def verify_fertilizer_get(
    batch_number: str = Query(..., min_length=2),
    dealer_asking_price: Optional[float] = Query(default=None, ge=0),
    db: Session = Depends(get_db),
):
    """GET endpoint for QR code scanner links to verify fertilizer batch and MRP."""
    result = BlockchainService.verify_fertilizer(
        db=db,
        batch_number=batch_number,
        dealer_asking_price=dealer_asking_price,
    )
    return FertilizerVerifyResponse(**result)


@router.post("/register-produce", response_model=ProduceRegisterResponse, status_code=status.HTTP_201_CREATED)
def register_produce(
    req: ProduceRegisterRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Registers farmer produce batch on the immutable ledger with Merkle proof."""
    profile = (
        db.query(FarmerProfile)
        .filter(FarmerProfile.user_id == current_user.id)
        .first()
    )
    if not profile and req.farmer_profile_id:
        profile = (
            db.query(FarmerProfile)
            .filter(FarmerProfile.id == req.farmer_profile_id)
            .first()
        )
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Active farmer profile required to register produce stock.",
        )

    stock = BlockchainService.register_produce(
        db=db,
        farmer_profile_id=profile.id,
        produce_type=req.produce_type,
        quantity=req.quantity,
        quantity_unit=req.quantity_unit,
    )

    return ProduceRegisterResponse(
        produce_batch_id=stock.produce_batch_id,
        farmer_profile_id=stock.farmer_profile_id,
        produce_type=stock.produce_type,
        quantity=stock.quantity,
        quantity_unit=stock.quantity_unit,
        merkle_hash=stock.merkle_hash,
        qr_code_payload=stock.qr_code_payload,
        created_at=stock.created_at,
    )


@router.post("/verify-produce", response_model=ProduceVerifyResponse)
def verify_produce(req: ProduceVerifyRequest, db: Session = Depends(get_db)):
    """Verifies produce batch authenticity and anti-hoarding provenance."""
    result = BlockchainService.verify_produce(db=db, identifier=req.identifier)
    return ProduceVerifyResponse(**result)


@router.get("/verify-produce", response_model=ProduceVerifyResponse)
def verify_produce_get(
    identifier: str = Query(..., min_length=2),
    db: Session = Depends(get_db),
):
    """GET endpoint for QR code scanner links to verify produce provenance."""
    result = BlockchainService.verify_produce(db=db, identifier=identifier)
    return ProduceVerifyResponse(**result)


@router.post("/record-sale", response_model=ProduceRecordSaleResponse)
def record_sale(
    req: ProduceRecordSaleRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Two-tier sold product verification (PLATFORM_VERIFIED vs SELF_REPORTED)."""
    result = BlockchainService.record_sale(
        db=db,
        produce_batch_id=req.produce_batch_id,
        quantity_sold=req.quantity_sold,
        sale_price_total=req.sale_price_total,
        verification_tier=req.verification_tier,
        buyer_details=req.buyer_details,
    )
    return ProduceRecordSaleResponse(**result)


@router.get("/ledger", response_model=List[LedgerBlockResponse])
def get_ledger_blocks(
    limit: int = Query(default=50, ge=1, le=200),
    db: Session = Depends(get_db),
):
    """Returns the immutable audit trail of blockchain ledger blocks."""
    blocks = (
        db.query(BlockchainLedgerBlock)
        .order_by(BlockchainLedgerBlock.block_index.desc())
        .limit(limit)
        .all()
    )
    return [
        LedgerBlockResponse(
            block_index=b.block_index,
            timestamp=b.timestamp,
            transaction_type=b.transaction_type,
            data_payload=b.data_payload,
            previous_hash=b.previous_hash,
            block_hash=b.block_hash,
        )
        for b in blocks
    ]
