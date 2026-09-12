"""Request and response schemas for orders and tracking."""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field

from app.models.order import OrderStatus


class OrderCreate(BaseModel):
    product_id: int = Field(..., gt=0)
    quantity: float = Field(..., gt=0)
    delivery_address: str = Field(..., min_length=1, max_length=500)
    notes: Optional[str] = Field(default=None, max_length=2000)


class OrderStatusUpdate(BaseModel):
    status: OrderStatus


class TrackingEvent(BaseModel):
    status: OrderStatus
    timestamp: Optional[datetime]
    completed: bool


class OrderResponse(BaseModel):
    id: int
    buyer_id: int
    buyer_name: Optional[str]
    farmer_id: int
    farmer_name: Optional[str]
    product_id: int
    product_name: str
    quantity: float
    unit: str
    price_per_unit: float
    total_amount: float
    delivery_address: str
    notes: Optional[str]
    status: OrderStatus
    created_at: datetime
    updated_at: datetime
    tracking: List[TrackingEvent]