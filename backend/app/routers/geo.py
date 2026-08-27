from fastapi import APIRouter
from app.schemas.geo import GeoLanguageDetectRequest, GeoLanguageDetectResponse

router = APIRouter(prefix="/geo", tags=["Zero-Touch Geolocation & Language"])


@router.post("/detect-language", response_model=GeoLanguageDetectResponse)
def detect_language_from_gps(req: GeoLanguageDetectRequest):
    # Simulated GPS region mapping (Coimbatore / Tamil Nadu default)
    state = "Tamil Nadu"
    district = "Coimbatore"
    lang_code = "ta"
    lang_name = "Tamil"
    dialect_pack = "kongu_tamil"

    ui_strings = {
        "welcome": "வணக்கம்! அக்ரி-கீ-க்கு வரவேற்கிறோம்!",
        "market_prices": "சந்தை விலைகள்",
        "fertilizer_mrp": "உரங்களின் விலை",
        "weather_advisory": "வானிலை எச்சரிக்கை",
        "crop_suggestions": "பயிர் பரிந்துரை",
        "dairy_section": "பால் பண்ணை பிரிவு",
        "poultry_section": "கோழி பண்ணை பிரிவு",
        "aquaculture_section": "மீன் பண்ணை பிரிவு",
    }

    return GeoLanguageDetectResponse(
        state=state,
        district=district,
        regional_language_code=lang_code,
        language_name=lang_name,
        dialect_pack_id=dialect_pack,
        audio_greeting_url="/static/audio/welcome_ta_kongu.mp3",
        ui_translations=ui_strings,
    )
