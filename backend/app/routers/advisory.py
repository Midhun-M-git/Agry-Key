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


@router.post("/chat", response_model=ChatResponse)
async def chat_with_ai(request: ChatRequest):
    """
    Real-time AI assistant for farmer questions using the Gemini LLM.
    Takes a natural language question and returns a farming-specific answer.
    """
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
        return ChatResponse(answer=answer)
    except Exception as e:
        print(f"[Router] Chat error: {e}")
        raise HTTPException(status_code=500, detail="AI assistant is temporarily unavailable.")
