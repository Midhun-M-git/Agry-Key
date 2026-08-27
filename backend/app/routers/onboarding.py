"""AI Voice Interview farm portfolio onboarding router."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.farm import AgriculturalPlot, LivestockUnit, PoultryUnit, AquacultureUnit
from app.models.user import FarmerProfile, User
from app.routers.auth import get_current_user
from app.schemas.onboarding import FarmOnboardingRequest, FarmOnboardingResponse

router = APIRouter(prefix="/onboarding", tags=["AI Voice Interview Onboarding"])


@router.post("/farm", response_model=FarmOnboardingResponse)
def setup_farm_portfolio(
    req: FarmOnboardingRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Processes parsed AI Voice Interview responses to configure a multi-sector farm portfolio."""
    profile = db.query(FarmerProfile).filter(FarmerProfile.user_id == current_user.id).first()
    if not profile:
        profile = FarmerProfile(
            user_id=current_user.id,
            state=req.state,
            district=req.district,
            latitude=req.latitude,
            longitude=req.longitude,
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)
    else:
        profile.state = req.state
        profile.district = req.district
        if req.latitude:
            profile.latitude = req.latitude
        if req.longitude:
            profile.longitude = req.longitude
        db.commit()

    configured = []

    # 1. Configure Agricultural Plots
    for p in req.plots:
        plot = AgriculturalPlot(
            farmer_profile_id=profile.id,
            plot_name=p.plot_name,
            acreage=p.acreage,
            soil_type=p.soil_type,
            water_source=p.water_source,
            latitude=req.latitude,
            longitude=req.longitude,
        )
        db.add(plot)
        configured.append(f"Crop Plot: {p.acreage} acres ({p.soil_type} soil)")

    # 2. Configure Livestock Units
    for l in req.livestock:
        livestock = LivestockUnit(
            farmer_profile_id=profile.id,
            animal_type=l.animal_type,
            breed=l.breed,
            head_count=l.head_count,
            purpose=l.purpose,
        )
        db.add(livestock)
        configured.append(f"Livestock: {l.head_count} {l.animal_type}s")

    # 3. Configure Poultry Units
    for p_unit in req.poultry:
        poultry = PoultryUnit(
            farmer_profile_id=profile.id,
            bird_type=p_unit.bird_type,
            bird_count=p_unit.bird_count,
            purpose=p_unit.purpose,
        )
        db.add(poultry)
        configured.append(f"Poultry: {p_unit.bird_count} {p_unit.bird_type}s")

    # 4. Configure Aquaculture Units
    for a in req.aquaculture:
        aqua = AquacultureUnit(
            farmer_profile_id=profile.id,
            pond_name=a.pond_name,
            pond_size_acres=a.pond_size_acres,
            fish_species=a.fish_species,
        )
        db.add(aqua)
        configured.append(f"Aquaculture: {a.pond_size_acres} acre pond ({a.fish_species})")

    db.commit()

    return FarmOnboardingResponse(
        status="success",
        farmer_profile_id=profile.id,
        configured_units=configured,
        summary_message=f"Farm portfolio successfully configured with {len(configured)} production units.",
    )
