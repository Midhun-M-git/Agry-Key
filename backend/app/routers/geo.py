"""Zero-Touch Geolocation Language and Dialect Detection API router."""

from fastapi import APIRouter
from geopy.geocoders import Nominatim

from app.core.regions import district_registry
from app.schemas.geo import GeoLanguageDetectRequest, GeoLanguageDetectResponse

router = APIRouter(prefix="/geo", tags=["Zero-Touch Geolocation & Language"])

_DEFAULT_LOCATION = {"state": "Kerala", "district": "Palakkad"}
_LANGUAGE_NAMES = {"ml": "Malayalam", "ta": "Tamil"}
_geolocator = Nominatim(user_agent="agry-key-backend")


def _reverse_geocode(latitude: float, longitude: float) -> tuple[str, str]:
    """Resolve coordinates to state and district, retaining a local fallback."""
    try:
        location = _geolocator.reverse((latitude, longitude), exactly_one=True, timeout=5)
        address = location.raw.get("address", {}) if location else {}
        state = address.get("state")
        district = (
            address.get("state_district")
            or address.get("district")
            or address.get("county")
            or address.get("city_district")
        )
        if state and district:
            return state, district
    except Exception:
        pass
    return _DEFAULT_LOCATION["state"], _DEFAULT_LOCATION["district"]


@router.post("/detect-language", response_model=GeoLanguageDetectResponse)
def detect_language_from_gps(req: GeoLanguageDetectRequest):
    """Maps GPS latitude and longitude to state, district, regional language, and dialect pack."""
    state, district = _reverse_geocode(req.latitude, req.longitude)

    provider = district_registry.get_provider_for_location(state, district)
    if provider is None:
        state = _DEFAULT_LOCATION["state"]
        district = _DEFAULT_LOCATION["district"]
        provider = district_registry.get_provider_for_location(state, district)

    lang_code = "ml"
    dialect_pack = "palakkad_malayalam"
    if provider:
        state = provider.state_name
        district = provider.district_name
        lang_code = provider.language_code

    lang_name = _LANGUAGE_NAMES.get(lang_code, lang_code)
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
