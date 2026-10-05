from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.schemas.advisory import AdvisoryRequest, AdvisoryResponse
from app.agents.advisory import advisory_agent
from app.agents.verifier import verifier_agent
from app.agents.llm_client import llm_client

router = APIRouter()


class ChatRequest(BaseModel):
    question: str
    state: str = "Kerala"
    district: str = ""
    language: str = "en"


class ChatResponse(BaseModel):
    answer: str


@router.post("/generate", response_model=AdvisoryResponse)
async def generate_advisory_strategy(request: AdvisoryRequest):
    """
    Triggers the Triple Autonomous Agent pipeline to generate a verified,
    localized farming strategy based on live data and deep learning forecasts.
    """
    try:
        print(f"[Router] Starting Advisory Engine for Farmer {request.farmer_profile_id}")
        raw_strategy = advisory_agent.generate_strategy(
            farmer_profile_id=request.farmer_profile_id,
            district=request.district,
            lat=request.latitude,
            lng=request.longitude,
            farm_portfolio=request.farm_portfolio
        )

        print("[Router] Verifying and localizing strategy...")
        final_strategy = verifier_agent.verify_and_localize(
            raw_strategy=raw_strategy,
            state=request.state,
            district=request.district
        )

        return AdvisoryResponse(
            district=request.district,
            final_strategy=final_strategy
        )

    except Exception as e:
        print(f"[Router] Error generating advisory: {e}")
        raise HTTPException(status_code=500, detail="Failed to generate advisory strategy.")


import json
import re

def _extract_farm_details_from_text(prompt: str) -> str:
    """Extracts structured farm attributes from speech/text and returns a JSON string."""
    t = prompt.lower()
    data = {
        "state": "",
        "district": "",
        "farm_name": "",
        "crop": "",
        "acreage": "",
        "soil_type": "",
        "water_source": "",
        "animal_type": "",
        "breed": "",
        "head_count": "",
        "bird_type": "",
        "bird_count": "",
        "pond_name": "",
        "pond_size": "",
        "fish_species": ""
    }

    ac_match = re.search(r'(\d+(?:\.\d+)?)\s*(?:acres?|acre|ac|cents?|hectares?|ha)\b', t)
    if ac_match:
        data["acreage"] = ac_match.group(1)

    states = [
        "kerala", "tamil nadu", "karnataka", "andhra pradesh", "telangana",
        "maharashtra", "punjab", "haryana", "uttar pradesh", "gujarat",
        "rajasthan", "madhya pradesh", "bihar", "west bengal", "odisha"
    ]
    for s in states:
        if s in t:
            data["state"] = s.title()
            break

    districts = [
        "palakkad", "thrissur", "ernakulam", "malappuram", "kozhikode", "wayanad",
        "kannur", "kasaragod", "idukki", "kottayam", "alappuzha", "pathanamthitta",
        "kollam", "thiruvananthapuram", "coimbatore", "madurai", "salem", "erode",
        "mysore", "mandya", "vellore", "tiruchirappalli", "tanjore", "shimoga"
    ]
    for d in districts:
        if d in t:
            data["district"] = d.title()
            break

    crops = [
        "paddy", "rice", "wheat", "cotton", "sugarcane", "maize", "corn",
        "tomato", "potato", "onion", "chilli", "pepper", "cardamom", "ginger",
        "turmeric", "tea", "coffee", "rubber", "coconut", "banana", "arecanut",
        "mango", "cashew", "tapioca", "groundnut", "mustard"
    ]
    for c in crops:
        if c in t:
            data["crop"] = c.title()
            break

    if "red" in t:
        data["soil_type"] = "Red Loamy"
    elif "black" in t:
        data["soil_type"] = "Black Clay"
    elif "alluvial" in t:
        data["soil_type"] = "Alluvial"
    elif "sandy" in t:
        data["soil_type"] = "Sandy Loam"
    elif "laterite" in t:
        data["soil_type"] = "Laterite"
    elif "clay" in t:
        data["soil_type"] = "Clayey Soil"

    if "borewell" in t or "bore well" in t:
        data["water_source"] = "Borewell"
    elif "canal" in t:
        data["water_source"] = "Canal Irrigation"
    elif "well" in t:
        data["water_source"] = "Open Well"
    elif "river" in t:
        data["water_source"] = "River Water"
    elif "rain" in t:
        data["water_source"] = "Rainfed"
    elif "drip" in t:
        data["water_source"] = "Drip Irrigation"

    cow_match = re.search(r'(\d+)\s*(?:cows?|cattle|buffalos?|goats?)', t)
    if "cow" in t or "cattle" in t:
        data["animal_type"] = "Cow"
        data["head_count"] = cow_match.group(1) if cow_match else "1"
        data["breed"] = "Desi"
    elif "buffalo" in t:
        data["animal_type"] = "Buffalo"
        data["head_count"] = cow_match.group(1) if cow_match else "1"
        data["breed"] = "Murrah"
    elif "goat" in t:
        data["animal_type"] = "Goat"
        data["head_count"] = cow_match.group(1) if cow_match else "1"
        data["breed"] = "Malabari"

    hen_match = re.search(r'(\d+)\s*(?:hens?|chickens?|birds?|ducks?|poultry)', t)
    if "hen" in t or "chicken" in t or "poultry" in t:
        data["bird_type"] = "Hen"
        data["bird_count"] = hen_match.group(1) if hen_match else "10"
    elif "duck" in t:
        data["bird_type"] = "Duck"
        data["bird_count"] = hen_match.group(1) if hen_match else "10"

    if "pond" in t or "fish" in t or "aquaculture" in t:
        data["pond_name"] = "Farm Pond"
        data["pond_size"] = "0.5"
        for fish in ["tilapia", "carp", "catla", "rohu", "prawn", "shrimp"]:
            if fish in t:
                data["fish_species"] = fish.title()
                break
        if not data["fish_species"]:
            data["fish_species"] = "Carp"

    dist = data["district"] or "Green"
    crp = data["crop"] or "Agri"
    data["farm_name"] = f"{dist} {crp} Farm"

    return json.dumps(data)


def _generate_domain_advisory(question: str, state: str, district: str) -> str:
    """Provides high-quality, practical agricultural guidance tailored to Indian farming."""
    q = question.lower()
    loc = f"in {district}, {state}" if district else f"in {state}"

    if any(k in q for k in ["pest", "disease", "blast", "borer", "bug", "fungus", "leaf"]):
        return (
            f"Pest & Disease Advisory for {loc}: Inspect leaf underside and stems for early signs. "
            "For sucking pests or leaf folders, spray 5% neem seed kernel extract (NSKE) or neem oil (5ml/L). "
            "For fungal blast or blight, ensure good field drainage and avoid excessive nitrogen application. "
            "Consult your nearest Krishi Bhavan for biocontrol agents like Trichoderma or Pseudomonas."
        )
    elif any(k in q for k in ["fertilizer", "urea", "dap", "npk", "potash", "nutrient", "soil"]):
        return (
            f"Nutrient Management Guide for {loc}: Follow soil test-based application. "
            "As a rule of thumb, apply full Phosphorus and 50% Potash as basal dose before planting. "
            "Apply Nitrogen (Urea) in 2 to 3 split doses during active vegetative growth and flowering. "
            "Incorporate well-decomposed Farm Yard Manure (FYM) to enhance soil microbial activity."
        )
    elif any(k in q for k in ["weather", "rain", "forecast", "monsoon", "climate"]):
        return (
            f"Weather Advisory for {loc}: Monitor IMD weather bulletins. "
            "Ensure proper clearing of drainage channels in fields ahead of predicted heavy rainfall. "
            "Postpone foliar chemical spraying and fertilizer top-dressing if rain is forecasted within 24 hours."
        )
    elif any(k in q for k in ["scheme", "pm-kisan", "pmfby", "subsidy", "loan", "kisan"]):
        return (
            f"Government Schemes for Farmers {loc}: Under PM-KISAN, eligible landholding farmers receive ₹6,000/year "
            "in 3 equal installments. Under PM Fasal Bima Yojana (PMFBY), insure your seasonal crops against natural calamities "
            "at minimal premium (1.5% - 2%). Contact your local Krishi Bhavan or Village Extension Officer for machinery subsidy."
        )
    elif any(k in q for k in ["price", "market", "mandi", "rate", "sell"]):
        return (
            f"Market & Price Advisory for {loc}: Check daily modal auction prices on the e-NAM portal "
            "or the AgriKey Marketplace section. Avoid distress sales at harvest peaks; consider utilizing local warehouse receipts "
            "or direct farmer-to-buyer aggregation to secure 10-15% higher realization."
        )
    elif any(k in q for k in ["cow", "buffalo", "dairy", "milk", "cattle", "livestock", "feed"]):
        return (
            f"Livestock Advisory for {loc}: Maintain clean, well-ventilated cattle sheds. Provide clean drinking water and green fodder "
            "supplemented with 30-50g mineral mixture daily. Ensure deworming and timely vaccination against Foot and Mouth Disease (FMD). "
            "For veterinary emergency assistance, dial 1962."
        )
    else:
        return (
            f"AgriKey Expert Advisory for {loc}: For optimal yield, practice crop rotation, adopt certified seeds, "
            "and utilize drip or sprinkler irrigation to conserve water. Keep records of input costs and weather patterns. "
            "Ask specific questions about pests, fertilizers, market prices, or government schemes for detailed recommendations."
        )


@router.post("/chat", response_model=ChatResponse)
async def chat_with_ai(request: ChatRequest):
    """
    Real-time AI assistant for farmer questions using the Gemini LLM.
    Includes smart NLP entity extraction and specialized agronomy fallbacks.
    """
    # Check if this is a voice interview entity extraction request
    if "extract farm details" in request.question.lower() or "required json format" in request.question.lower():
        # First try Gemini LLM if key is present
        try:
            if llm_client.model:
                answer = llm_client.generate_response(prompt=request.question)
                if "{" in answer and "}" in answer and answer != llm_client.FALLBACK_RESPONSE:
                    return ChatResponse(answer=answer)
        except Exception:
            pass

        # Robust NLP extraction fallback
        extracted_json = _extract_farm_details_from_text(request.question)
        return ChatResponse(answer=extracted_json)

    # General farmer question
    try:
        location_context = (
            f"in {request.district}, {request.state}" if request.district
            else f"in {request.state}"
        )
        system_message = (
            "You are an expert agricultural advisor for Indian farmers. "
            f"The farmer is located {location_context}. "
            "Answer questions concisely and practically in simple language. "
            "Focus on actionable advice related to Indian farming: crops, weather, "
            "market prices, soil health, government schemes, fertilizers, and pests. "
            "If the question is in a regional language, respond in the same language. "
            "Keep answers under 150 words."
        )
        answer = llm_client.generate_response(
            prompt=request.question,
            system_message=system_message,
        )

        # If Gemini is unconfigured or returned generic fallback, use rich agronomy advisor
        if not answer or answer == llm_client.FALLBACK_RESPONSE:
            answer = _generate_domain_advisory(
                question=request.question,
                state=request.state,
                district=request.district
            )

        return ChatResponse(answer=answer)
    except Exception as e:
        print(f"[Router] Chat error: {e}")
        # Return helpful domain advisory even on exception
        fallback = _generate_domain_advisory(
            question=request.question,
            state=request.state,
            district=request.district
        )
        return ChatResponse(answer=fallback)
