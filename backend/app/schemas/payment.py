"""Pydantic schemas for Razorpay payments."""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

from app.models.payment import PaymentStatus


class PaymentCreateOrderRequest(BaseModel):
    order_id: int = Field(..., gt=0)


class PaymentCreateOrderResponse(BaseModel):
    payment_id: int
    order_id: int
    razorpay_order_id: str
    amount: float
    currency: str
    razorpay_key_id: str


class PaymentVerifyRequest(BaseModel):
    razorpay_order_id: str = Field(..., min_length=1)
    razorpay_payment_id: str = Field(..., min_length=1)
    razorpay_signature: str = Field(..., min_length=1)


class PaymentVerifyResponse(BaseModel):
    status: str
    message: str
    payment_id: int
    order_id: int
    order_status: str


class PaymentResponse(BaseModel):
    id: int
    order_id: int
    buyer_id: int
    razorpay_order_id: str
    razorpay_payment_id: Optional[str] = None
    amount: float
    currency: str
    status: PaymentStatus
    created_at: datetime
