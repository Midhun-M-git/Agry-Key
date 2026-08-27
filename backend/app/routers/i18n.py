"""i18n Localization translation bundles and voice mode preference settings."""

from typing import Dict
from fastapi import APIRouter, Query

router = APIRouter(prefix="/i18n", tags=["i18n Localization & Preferences"])

TRANSLATION_STORE: Dict[str, Dict[str, str]] = {
    "ta": {
        "welcome": "வணக்கம்! அக்ரி-கீ-க்கு வரவேற்கிறோம்!",
        "voice_prompt": "நான் உங்களுக்கு குரல் வழிகாட்ட வேண்டுமா?",
        "guest_mode": "சந்தை விலைகளை மட்டும் பார்க்க",
        "register_farmer": "விவசாயி / உற்பத்தியாளர் பதிவு",
        "market_prices": "சந்தை விலைகள்",
        "veterinary_contacts": "பக்கத்து கால்நடை மருத்துவர் தொடர்புகள்",
    },
    "hi": {
        "welcome": "नमस्ते! Agry-Key में आपका स्वागत है!",
        "voice_prompt": "क्या आप आवाज द्वारा मार्गदर्शन चाहते हैं?",
        "guest_mode": "केवल बाजार मूल्य देखें",
        "register_farmer": "किसान पंजीकरण",
        "market_prices": "बाजार भाव",
        "veterinary_contacts": "निकटतम पशु चिकित्सा संपर्क",
    },
    "ml": {
        "welcome": "സ്വാഗതം! Agry-Key-ലേക്ക് സ്വാഗതം!",
        "voice_prompt": "ശബ്ദ മാർഗ്ഗനിർദ്ദേശം വേണമെന്നുണ്ടോ?",
        "guest_mode": "മാർക്കറ്റ് വിലകൾ മാത്രം കാണുക",
        "register_farmer": "കർഷക രജിസ്ട്രേഷൻ",
        "market_prices": "മാർക്കറ്റ് വിലകൾ",
        "veterinary_contacts": "അടുത്തുള്ള മൃഗാശുപത്രി ബന്ധപ്പെടലുകൾ",
    },
}


@router.post("/preferences")
def update_voice_preference(voice_enabled: bool):
    """Updates user session preference for voice-guided interaction mode (ON/OFF)."""
    return {
        "status": "success",
        "voice_guidance_enabled": voice_enabled,
        "message": "Voice guidance preference updated.",
    }


@router.get("/translations")
def get_translations(lang: str = Query(default="ta", description="Language code e.g. ta, hi, ml")):
    """Returns localizable UI translation string key-value bundle for the specified regional language."""
    bundle = TRANSLATION_STORE.get(lang.lower(), TRANSLATION_STORE["ta"])
    return {
        "language_code": lang,
        "translations": bundle,
    }
