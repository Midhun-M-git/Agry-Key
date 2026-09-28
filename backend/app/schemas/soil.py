"""Request and response schemas for soil health reports."""

from datetime import datetime
from typing import Any, Dict, List, Optional
from typing import Literal

from pydantic import BaseModel, Field


SoilStatus = Literal["LOW", "MEDIUM", "HIGH"]


class SoilReportCreate(BaseModel):
    farmer_profile_id: int = Field(..., gt=0)
    plot_id: Optional[int] = Field(default=None, gt=0)
    shc_number: Optional[str] = Field(default=None, max_length=50)
    ph_level: float = Field(..., ge=0, le=14)
    organic_carbon_percent: Optional[float] = Field(default=None, ge=0)
    nitrogen_status: SoilStatus = "MEDIUM"
    phosphorus_status: SoilStatus = "MEDIUM"
    potassium_status: SoilStatus = "MEDIUM"
    testing_lab_name: str = Field(..., min_length=1, max_length=100)
    issue_date: Optional[datetime] = None


class SoilReportResponse(BaseModel):
    id: int
    farmer_profile_id: int
    plot_id: Optional[int]
    plot_name: Optional[str]
    shc_number: Optional[str]
    ph_level: float
    organic_carbon_percent: Optional[float]
    nitrogen_status: str
    phosphorus_status: str
    potassium_status: str
    testing_lab_name: str
    issue_date: Optional[datetime]


class SoilReportListResponse(BaseModel):
    farmer_profile_id: int
    reports: List[SoilReportResponse]
    regional_survey: Optional[Dict[str, Any]]


class SoilRecommendation(BaseModel):
    input_name: str
    purpose: str
    application_guidance: str


class SoilRecommendationsResponse(BaseModel):
    district: str
    soil_type: str
    regional_survey: Optional[Dict[str, Any]]
    recommendations: List[SoilRecommendation]


class SoilSurveyTalukData(BaseModel):
    taluk: str = Field(..., min_length=1)
    village_panchayath: Optional[str] = None
    predominant_soil_type: str = Field(..., min_length=1)
    ph_level: Optional[float] = Field(None, ge=0, le=14)
    organic_carbon_percent: Optional[float] = Field(None, ge=0)
    nitrogen_kg_ha: Optional[float] = Field(None, ge=0)
    phosphorus_kg_ha: Optional[float] = Field(None, ge=0)
    potassium_kg_ha: Optional[float] = Field(None, ge=0)
    water_table_depth_m: Optional[float] = Field(None, ge=0)
    suitable_crops: List[str] = Field(default_factory=list)


class SoilSurveyUploadRequest(BaseModel):
    state: str = Field(..., min_length=1)
    district: str = Field(..., min_length=1)
    survey_authority: Optional[str] = None
    last_updated: Optional[str] = None
    panchayaths_and_taluks: List[SoilSurveyTalukData] = Field(..., min_length=1)