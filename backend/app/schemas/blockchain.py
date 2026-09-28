"""Schemas for Blockchain Anti-Fraud, QR verification, and Produce Registries."""

from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class FertilizerVerifyRequest(BaseModel):
    batch_number: str = Field(..., min_length=2, max_length=50)
    dealer_asking_price: Optional[float] = Field(default=None, ge=0)


class FertilizerVerifyResponse(BaseModel):
    is_authentic: bool
    status: str
    batch_number: str
    fertilizer_name: Optional[str] = None
    manufacturer: Optional[str] = None
    official_mrp_inr: Optional[float] = None
    dealer_asking_price: Optional[float] = None
    overcharging_detected: bool = False
    overcharge_amount_inr: float = 0.0
    merkle_hash: Optional[str] = None
    statutory_protection_clause: Optional[str] = None
    message: Optional[str] = None


class ProduceRegisterRequest(BaseModel):
    farmer_profile_id: Optional[int] = Field(default=None, gt=0)
    produce_type: str = Field(..., min_length=2, max_length=100)
    quantity: float = Field(..., gt=0)
    quantity_unit: str = Field(default="kg", max_length=20)


class ProduceRegisterResponse(BaseModel):
    produce_batch_id: str
    farmer_profile_id: int
    produce_type: str
    quantity: float
    quantity_unit: str
    merkle_hash: str
    qr_code_payload: str
    created_at: datetime


class ProduceVerifyRequest(BaseModel):
    identifier: str = Field(..., min_length=2)


class ProduceVerifyResponse(BaseModel):
    is_verified: bool
    status: str
    produce_batch_id: Optional[str] = None
    farmer_profile_id: Optional[int] = None
    produce_type: Optional[str] = None
    quantity_registered: Optional[float] = None
    quantity_unit: Optional[str] = None
    merkle_hash: Optional[str] = None
    registered_at: Optional[datetime] = None
    anti_hoarding_verified: bool = False
    message: Optional[str] = None


class ProduceRecordSaleRequest(BaseModel):
    produce_batch_id: str = Field(..., min_length=2)
    quantity_sold: float = Field(..., gt=0)
    sale_price_total: float = Field(..., gt=0)
    verification_tier: str = Field(default="SELF_REPORTED")
    buyer_details: Optional[str] = None


class ProduceRecordSaleResponse(BaseModel):
    status: str
    message: str
    produce_batch_id: str
    verification_tier: str
    quantity_sold: float
    remaining_verified_stock: Optional[float] = None
    ledger_block_index: int
    ledger_block_hash: str


class LedgerBlockResponse(BaseModel):
    block_index: int
    timestamp: datetime
    transaction_type: str
    data_payload: str
    previous_hash: str
    block_hash: str
