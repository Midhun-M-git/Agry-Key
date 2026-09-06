import io
from fastapi import APIRouter, Query, Response
from pydantic import BaseModel
from gtts import gTTS
from app.agents.llm_client import llm_client

router = APIRouter(prefix="/voice", tags=["Voice Generation & AI Assistant"])

GREETINGS = {
    "ta": "வணக்கம்! அக்ரி-கீ-க்கு வரவேற்கிறோம்! நான் உங்களுக்கு தமிழ் மொழியில் உதவ வேண்டுமா?",
    "hi": "नमस्ते! Agry-Key में आपका स्वागत है! क्या आप हिंदी में इंटरफ़ेस चाहते हैं?",
    "ml": "നമസ്കാരം! അഗ്രി കീയിലേക്ക് സ്വാഗതം! നിങ്ങൾക്ക് മലയാളത്തിൽ ഈ ആപ്പ് ഉപയോഗിക്കണോ?",
    "en": "Hello! Welcome to Agry-Key. Do you want to continue in English?"
}

class VoiceSpeakRequest(BaseModel):
    text: str
    lang: str = "en"

class VoiceAssistantQuery(BaseModel):
    query: str
    lang: str = "en"
    district: str = "Palakkad"

class VoiceIntentRequest(BaseModel):
    query: str
    lang: str = "en"

@router.post("/intent")
def parse_voice_intent(req: VoiceIntentRequest):
    """Classifies spoken query into a target screen route and generates a spoken confirmation."""
    text = req.query.lower().strip()
    lang = req.lang.lower()
    
    # 1. Direct rule-based keyword matching for fast zero-latency navigation
    screen_mappings = {
        "market": ["market", "mandi", "price", "rate", "വില", "ചന്ത", "मंडी", "भाव", "சந்தை", "விலை"],
        "weather": ["weather", "rain", "forecast", "temp", "കാലാവസ്ഥ", "മഴ", "मौसम", "बारिश", "வானிலை", "மழை"],
        "disease_detection": ["disease", "pest", "leaf", "plant", "രോഗം", "രോഗങ്ങൾ", "രോഗ", "കീടങ്ങൾ", "കീട", "बीमारी", "कीड़ा", "நோய்", "பூச்சி"],
        "crop_advisory": ["advisory", "advice", "crop", "fertilizer", "ഉപദേശം", "വിള", "सलाह", "फसल", "ஆலோசனை", "பயிர்"],
        "government_schemes": ["scheme", "government", "subsidy", "പദ്ധതി", "സർക്കാർ", "योजना", "सरकारी", "திட்டம்", "அரசு"],
        "soil_health": ["soil", "npk", "ph", "മണ്ണ്", "പരീക്ഷണ", "मिट्टी", "मृदा", "மண்"],
        "farmer_dashboard": ["farmer", "producer", "കർഷകൻ", "किसान", "விவசாயி"],
        "buyer_dashboard": ["buyer", "consumer", "വ്യാപാരി", "ഉപഭോക്താവ്", "खरीदार", "நுகர்வோர்"],
        "ai_assistant": ["assistant", "ai", "help", "ആസ്കിംഗ്", "സഹായം", "सहायक", "உதவி"],
        "my_orders": ["order", "purchase", "ഓർഡർ", "ऑर्डर", "ஆர்டர்"],
        "profile": ["profile", "account", "പ്രൊഫൈൽ", "प्रोफ़ाइल", "சுயவிவரம்"],
        "language": ["language", "ഭാഷ", "भाषा", "மொழி"]
    }
    
    target_screen = None
    for screen, keywords in screen_mappings.items():
        if any(kw in text for kw in keywords):
            target_screen = screen
            break

    # 2. AI LLM Intent Classification Fallback if rule-based lookup is ambiguous
    if not target_screen:
        prompt = (
            f"Classify the following user spoken query into exactly one of these screen target categories: "
            f"[market, weather, disease_detection, crop_advisory, government_schemes, soil_health, farmer_dashboard, buyer_dashboard, ai_assistant, my_orders, profile, language]. "
            f"Query: '{req.query}'. Respond ONLY with the single category keyword in lower case."
        )
        try:
            llm_res = llm_client.generate_response(prompt, system_message="Respond strictly with the single screen category name.")
            cleaned = llm_res.strip().lower()
            for key in screen_mappings.keys():
                if key in cleaned:
                    target_screen = key
                    break
        except Exception:
            target_screen = "ai_assistant"

    if not target_screen:
        target_screen = "ai_assistant"

    spoken_responses = {
        "en": {
            "market": "Opening Mandi Market Prices",
            "weather": "Opening Weather Forecast",
            "disease_detection": "Opening Disease Detection",
            "crop_advisory": "Opening Crop Advisory",
            "government_schemes": "Opening Government Schemes",
            "soil_health": "Opening Soil Health",
            "farmer_dashboard": "Opening Farmer Dashboard",
            "buyer_dashboard": "Opening Buyer Dashboard",
            "ai_assistant": "Opening AI Assistant",
            "my_orders": "Opening My Orders",
            "profile": "Opening Profile",
            "language": "Opening Language Selection"
        },
        "ml": {
            "market": "വിപണി വിവരങ്ങൾ തുറക്കുന്നു",
            "weather": "കാലാവസ്ഥാ പ്രവചനം തുറക്കുന്നു",
            "disease_detection": "രോഗ നിർണ്ണയം തുറക്കുന്നു",
            "crop_advisory": "വിള ഉപദേശങ്ങൾ തുറക്കുന്നു",
            "government_schemes": "സർക്കാർ പദ്ധതികൾ തുറക്കുന്നു",
            "soil_health": "മണ്ണുപരിശോധന പേജ് തുറക്കുന്നു",
            "farmer_dashboard": "കർഷക ഡാഷ്‌ബോർഡ് തുറക്കുന്നു",
            "buyer_dashboard": "ഉപഭോക്തൃ ഡാഷ്‌ബോർഡ് തുറക്കുന്നു",
            "ai_assistant": "എഐ അസിസ്റ്റന്റ് തുറക്കുന്നു",
            "my_orders": "ഓർഡറുകൾ തുറക്കുന്നു",
            "profile": "പ്രൊഫൈൽ പേജ് തുറക്കുന്നു",
            "language": "ഭാഷാ തിരഞ്ഞെടുപ്പ് തുറക്കുന്നു"
        }
    }

    spoken_text = spoken_responses.get(lang, spoken_responses["en"]).get(target_screen, f"Opening {target_screen}")

    return {
        "query": req.query,
        "target_screen": target_screen,
        "spoken_text": spoken_text,
        "audio_url": f"/api/v1/voice/greeting?lang={lang}"
    }

@router.get("/greeting")
def get_voice_greeting(lang: str = Query("en"), dialect: str = Query(None)):
    """Generates a dynamic voice greeting using text-to-speech."""
    lang_code = lang.lower()
    
    if lang_code not in GREETINGS:
        lang_code = "en"
        
    text = GREETINGS.get(lang_code, GREETINGS["en"])
    
    try:
        tts = gTTS(text=text, lang=lang_code, slow=False)
        mp3_fp = io.BytesIO()
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)
        return Response(content=mp3_fp.read(), media_type="audio/mpeg")
    except Exception as e:
        return Response(content=b"", media_type="audio/mpeg")

@router.post("/speak")
def synthesize_voice_response(req: VoiceSpeakRequest):
    """Synthesizes dynamic text into audio stream using gTTS."""
    lang_code = req.lang.lower()
    if lang_code not in ["ml", "hi", "ta", "en"]:
        lang_code = "en"
    
    try:
        tts = gTTS(text=req.text[:300], lang=lang_code, slow=False)
        mp3_fp = io.BytesIO()
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)
        return Response(content=mp3_fp.read(), media_type="audio/mpeg")
    except Exception as e:
        return Response(content=b"", media_type="audio/mpeg")

@router.post("/assistant")
def query_ai_voice_assistant(req: VoiceAssistantQuery):
    """Processes farmer voice query through AI LLM client and returns AI text answer."""
    prompt = (
        f"You are AgriKey AI, an expert voice agricultural assistant for farmers in {req.district}, India. "
        f"Answer the farmer's query concisely in 2-3 sentences. Query: {req.query}"
    )
    system_msg = "You are a helpful, practical AI agricultural advisor. Keep answers under 50 words so it can be spoken out loud."
    
    try:
        response_text = llm_client.generate_response(prompt, system_message=system_msg)
    except Exception as e:
        response_text = f"I received your question about {req.query}. Please check local mandi rates and weather advisory."
        
    return {
        "query": req.query,
        "response": response_text,
        "audio_url": f"/api/v1/voice/greeting?lang={req.lang}"
    }


