"""Request and response schemas for marketplace listings."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    crop_type: str = Field(..., min_length=1, max_length=50)
    sector: str = Field(default="CROPS", min_length=1, max_length=30)
    quality_grade: str = Field(default="A", min_length=1, max_length=10)
    district: str = Field(..., min_length=1, max_length=100)
    quantity: float = Field(..., gt=0)
    unit: str = Field(default="kg", min_length=1, max_length=20)
    price_per_unit: float = Field(..., gt=0)
    description: Optional[str] = Field(default=None, max_length=2000)
    image_url: Optional[str] = Field(default=None, max_length=500)
    expires_at: Optional[datetime] = None


class ProductUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=100)
    crop_type: Optional[str] = Field(default=None, min_length=1, max_length=50)
    sector: Optional[str] = Field(default=None, min_length=1, max_length=30)
    quality_grade: Optional[str] = Field(default=None, min_length=1, max_length=10)
    district: Optional[str] = Field(default=None, min_length=1, max_length=100)
    quantity: Optional[float] = Field(default=None, gt=0)
    unit: Optional[str] = Field(default=None, min_length=1, max_length=20)
    price_per_unit: Optional[float] = Field(default=None, gt=0)
    description: Optional[str] = Field(default=None, max_length=2000)
    image_url: Optional[str] = Field(default=None, max_length=500)
    expires_at: Optional[datetime] = None


class ProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    farmer_id: int
    farmer_name: Optional[str]
    name: str
    crop_type: str
    sector: str = "CROPS"
    quality_grade: str = "A"
    district: str
    quantity: float
    unit: str
    price_per_unit: float
    description: Optional[str]
    image_url: Optional[str]
    is_active: bool
    expires_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime