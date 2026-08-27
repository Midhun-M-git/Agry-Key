from typing import Dict
from pydantic import BaseModel, Field


class GeoLanguageDetectRequest(BaseModel):
    latitude: float = Field(..., description="GPS latitude")
    longitude: float = Field(..., description="GPS longitude")


class GeoLanguageDetectResponse(BaseModel):
    state: str
    district: str
    regional_language_code: str
    language_name: str
    dialect_pack_id: str
    audio_greeting_url: str
    ui_translations: Dict[str, str]
