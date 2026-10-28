"""Zero-Touch Geolocation Language and Dialect Detection API router."""

from fastapi import APIRouter, HTTPException
from geopy.geocoders import Nominatim

from app.core.regions import district_registry
from app.schemas.geo import GeoLanguageDetectRequest, GeoLanguageDetectResponse

router = APIRouter(prefix="/geo", tags=["Zero-Touch Geolocation & Language"])

_LANGUAGE_NAMES = {
    "ml": "Malayalam",
    "ta": "Tamil",
    "te": "Telugu",
    "kn": "Kannada",
    "hi": "Hindi",
    "mr": "Marathi",
    "gu": "Gujarati",
    "bn": "Bengali",
    "pa": "Punjabi",
    "en": "English",
}

_STATE_DEFAULT_LANGUAGES = {
    "kerala": ("ml", "palakkad_malayalam"),
    "tamil nadu": ("ta", "coimbatore_tamil"),
    "karnataka": ("kn", "kannada_standard"),
    "andhra pradesh": ("te", "telugu_standard"),
    "telangana": ("te", "telugu_standard"),
    "maharashtra": ("mr", "marathi_standard"),
    "gujarat": ("gu", "gujarati_standard"),
    "west bengal": ("bn", "bengali_standard"),
    "punjab": ("pa", "punjabi_standard"),
    "uttar pradesh": ("hi", "hindi_standard"),
    "madhya pradesh": ("hi", "hindi_standard"),
    "rajasthan": ("hi", "hindi_standard"),
    "bihar": ("hi", "hindi_standard"),
    "haryana": ("hi", "hindi_standard"),
    "delhi": ("hi", "hindi_standard"),
}

_geolocator = Nominatim(user_agent="agry-key-backend")


def _reverse_geocode(latitude: float, longitude: float) -> tuple[str, str, bool]:
    """Resolve coordinates to state and district using geopy Nominatim without default fallbacks."""
    if not latitude or not longitude:
        return "", "", False

    # Basic bounding box approximation for India
    if not (6.0 <= latitude <= 38.0 and 68.0 <= longitude <= 98.0):
        return "", "", False

    try:
        location = _geolocator.reverse((latitude, longitude), exactly_one=True, timeout=3)
        if location and location.raw:
            address = location.raw.get("address", {})
            state = address.get("state")
            district = (
                address.get("state_district")
                or address.get("district")
                or address.get("county")
                or address.get("city_district")
                or address.get("city")
            )
            if state and district:
                return state, district, True
            if state:
                return state, district or "", bool(district)
    except Exception:
        pass

    return "", "", False


@router.post("/detect-language", response_model=GeoLanguageDetectResponse)
def detect_language_from_gps(req: GeoLanguageDetectRequest):
    """Maps GPS latitude and longitude to state, district, regional language, and dialect pack."""
    state, district, is_detected = _reverse_geocode(req.latitude, req.longitude)
    if not is_detected or not state or not district:
        raise HTTPException(
            status_code=404,
            detail="Location could not be determined from coordinates. Manual district selection required."
        )

    provider = district_registry.get_provider_for_location(state, district)
    if provider is None:
        # Check district name across all registered providers
        provider = district_registry.get_provider(district)

    if provider:
        state = provider.state_name
        district = provider.district_name
        lang_code = provider.language_code
        dialect_pack = f"{district.lower()}_{lang_code}"
    else:
        # Lookup state default language
        st_clean = state.lower().strip()
        if st_clean in _STATE_DEFAULT_LANGUAGES:
            lang_code, dialect_pack = _STATE_DEFAULT_LANGUAGES[st_clean]
        else:
            lang_code, dialect_pack = "en", "english_standard"

    lang_name = _LANGUAGE_NAMES.get(lang_code, lang_code.capitalize())
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
        is_detected=True,
        is_fallback=False,
    )
