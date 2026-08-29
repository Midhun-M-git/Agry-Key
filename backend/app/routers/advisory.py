from fastapi import APIRouter, HTTPException
from app.schemas.advisory import AdvisoryRequest, AdvisoryResponse
from app.agents.advisory import advisory_agent
from app.agents.verifier import verifier_agent

router = APIRouter()

@router.post("/generate", response_model=AdvisoryResponse)
async def generate_advisory_strategy(request: AdvisoryRequest):
    """
    Triggers the Triple Autonomous Agent pipeline to generate a verified,
    localized farming strategy based on live data and deep learning forecasts.
    """
    try:
        # 1. Advisory Agent: Gathers live data, DL forecasts, computes Net Profit/Synergies, 
        # and asks the LLM for a raw strategic plan.
        print(f"[Router] Starting Advisory Engine for Farmer {request.farmer_profile_id}")
        raw_strategy = advisory_agent.generate_strategy(
            farmer_profile_id=request.farmer_profile_id,
            district=request.district,
            lat=request.latitude,
            lng=request.longitude,
            farm_portfolio=request.farm_portfolio
        )
        
        # 2. Verifier Agent: Audits the raw strategy for safety and injects regional slang.
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
