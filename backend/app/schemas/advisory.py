from pydantic import BaseModel, Field
from typing import Dict, Any

class AdvisoryRequest(BaseModel):
    farmer_profile_id: int
    state: str = Field(..., description="State where the farm is located")
    district: str = Field(..., description="District where the farm is located")
    latitude: float
    longitude: float
    farm_portfolio: Dict[str, Any] = Field(..., description="The full farm portfolio (plots, livestock, etc.)")

class AdvisoryResponse(BaseModel):
    status: str = "success"
    district: str
    final_strategy: str
    message: str = "Strategy generated successfully."
