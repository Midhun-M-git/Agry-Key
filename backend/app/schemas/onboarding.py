from typing import List, Optional
from pydantic import BaseModel, Field


class PlotInputSchema(BaseModel):
    plot_name: str = "Main Plot"
    acreage: float
    soil_type: str  # Red, Black, Loamy, Alluvial
    water_source: str  # Borewell, Canal, Rainfed
    crops_currently_grown: List[str] = []


class LivestockInputSchema(BaseModel):
    animal_type: str  # Cow, Buffalo, Goat, Sheep
    breed: Optional[str] = None
    head_count: int
    purpose: str = "DAIRY"


class PoultryInputSchema(BaseModel):
    bird_type: str = "Hen"
    bird_count: int
    purpose: str = "EGGS"


class AquacultureInputSchema(BaseModel):
    pond_name: str = "Pond 1"
    pond_size_acres: float
    fish_species: str


class FarmOnboardingRequest(BaseModel):
    state: str
    district: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    plots: List[PlotInputSchema] = []
    livestock: List[LivestockInputSchema] = []
    poultry: List[PoultryInputSchema] = []
    aquaculture: List[AquacultureInputSchema] = []


class FarmOnboardingResponse(BaseModel):
    status: str = "success"
    farmer_profile_id: int
    configured_units: List[str]
    summary_message: str
