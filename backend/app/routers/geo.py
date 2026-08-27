"""Zero-Touch Geolocation Language and Dialect Detection API router."""

from fastapi import APIRouter
from app.core.regions import district_registry
from app.schemas.geo import GeoLanguageDetectRequest, GeoLanguageDetectResponse

router = APIRouter(prefix="/geo", tags=["Zero-Touch Geolocation & Language"])


@router.post("/detect-language", response_model=GeoLanguageDetectResponse)
def detect_language_from_gps(req: GeoLanguageDetectRequest):
    """Maps GPS latitude and longitude to state, district, regional language, and dialect pack."""
    # Active district focus: Palakkad, Kerala
    district = "Palakkad"
    state = "Kerala"
    lang_code = "ml"
    lang_name = "Malayalam"
    dialect_pack = "palakkad_malayalam"

    provider = district_registry.get_provider(district)
    if provider:
        state = provider.state_name
        district = provider.district_name
        lang_code = provider.language_code

    slang_pack = district_registry.get_slang_pack(district)
    if slang_pack:
        dialect_pack = slang_pack.get("dialect_pack_id", dialect_pack)

    return GeoLanguageDetectResponse(
        state=state,
        district=district,
        regional_language_code=lang_code,
        language_name=lang_name,
        dialect_pack_id=dialect_pack,
        audio_greeting_url=f"/api/v1/voice/greeting?lang={lang_code}&dialect={dialect_pack}",
        ui_translations={},
    )
