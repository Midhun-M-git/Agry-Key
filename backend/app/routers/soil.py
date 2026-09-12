"""Soil health reports and regional fertilizer recommendations."""

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.regions import district_registry
from app.models.farm import AgriculturalPlot
from app.models.soil import FarmerSoilHealthCard
from app.models.user import FarmerProfile, User
from app.routers.auth import get_current_user
from app.schemas.soil import (
    SoilRecommendation,
    SoilRecommendationsResponse,
    SoilReportCreate,
    SoilReportListResponse,
    SoilReportResponse,
)

router = APIRouter(prefix="/soil", tags=["Soil Health"])


def _get_owned_profile(profile_id: int, current_user: User, db: Session) -> FarmerProfile:
    profile = (
        db.query(FarmerProfile)
        .filter(FarmerProfile.id == profile_id, FarmerProfile.user_id == current_user.id)
        .first()
    )
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Farmer profile not found")
    return profile


def _report_response(report: FarmerSoilHealthCard, db: Session) -> SoilReportResponse:
    plot = db.query(AgriculturalPlot).filter(AgriculturalPlot.id == report.plot_id).first()
    return SoilReportResponse(
        id=report.id,
        farmer_profile_id=report.farmer_profile_id,
        plot_id=report.plot_id,
        plot_name=plot.plot_name if plot else None,
        shc_number=report.shc_number,
        ph_level=report.ph_level,
        organic_carbon_percent=report.organic_carbon_percent,
        nitrogen_status=report.nitrogen_status,
        phosphorus_status=report.phosphorus_status,
        potassium_status=report.potassium_status,
        testing_lab_name=report.testing_lab_name,
        issue_date=report.issue_date,
    )


@router.get("/report", response_model=SoilReportListResponse)
def get_soil_reports(
    farmer_profile_id: int = Query(..., gt=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get soil health cards for the authenticated farmer's profile and plots."""
    profile = _get_owned_profile(farmer_profile_id, current_user, db)
    reports = (
        db.query(FarmerSoilHealthCard)
        .filter(FarmerSoilHealthCard.farmer_profile_id == profile.id)
        .order_by(FarmerSoilHealthCard.issue_date.desc())
        .all()
    )
    return SoilReportListResponse(
        farmer_profile_id=profile.id,
        reports=[_report_response(report, db) for report in reports],
        regional_survey=district_registry.get_soil_survey(profile.district),
    )


@router.post("/report", response_model=SoilReportResponse, status_code=status.HTTP_201_CREATED)
def submit_soil_report(
    req: SoilReportCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Submit a soil test result for one of the farmer's profiles and plots."""
    _get_owned_profile(req.farmer_profile_id, current_user, db)
    if req.plot_id:
        plot = (
            db.query(AgriculturalPlot)
            .filter(
                AgriculturalPlot.id == req.plot_id,
                AgriculturalPlot.farmer_profile_id == req.farmer_profile_id,
            )
            .first()
        )
        if not plot:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Farm plot not found")

    report = FarmerSoilHealthCard(**req.model_dump())
    db.add(report)
    db.commit()
    db.refresh(report)
    return _report_response(report, db)


@router.get("/recommendations", response_model=SoilRecommendationsResponse)
def get_soil_recommendations(
    district: str = Query(..., min_length=1),
    soil_type: str = Query(..., min_length=1),
):
    """Return soil-type fertilizer guidance enriched with regional survey data."""
    regional_survey = district_registry.get_soil_survey(district.strip())
    normalized_soil_type = soil_type.strip().upper().replace(" ", "_")
    recommendations_by_type = {
        "RED_LOAMY": [
            SoilRecommendation(
                input_name="Balanced NPK fertilizer",
                purpose="Maintain nitrogen, phosphorus, and potassium supply in light soils.",
                application_guidance="Apply from soil-test rates in split doses during crop growth.",
            ),
            SoilRecommendation(
                input_name="Farmyard manure or compost",
                purpose="Increase organic matter and water-holding capacity.",
                application_guidance="Incorporate well-decomposed organic matter before planting.",
            ),
        ],
        "BLACK_COTTON_SOIL": [
            SoilRecommendation(
                input_name="Nitrogen fertilizer",
                purpose="Support crop growth while reducing leaching losses.",
                application_guidance="Apply the soil-test dose in split applications with adequate moisture.",
            ),
            SoilRecommendation(
                input_name="Phosphorus and potash fertilizer",
                purpose="Support root development and crop quality in heavy clay soil.",
                application_guidance="Band or incorporate according to the soil-test recommendation.",
            ),
        ],
        "LATERITE": [
            SoilRecommendation(
                input_name="Lime or dolomite",
                purpose="Correct soil acidity where the soil test indicates a low pH.",
                application_guidance="Apply only at the soil-test rate and incorporate before planting.",
            ),
            SoilRecommendation(
                input_name="Compost with balanced NPK",
                purpose="Build organic matter and replenish nutrients in weathered soil.",
                application_guidance="Combine organic matter with split fertilizer applications.",
            ),
        ],
    }
    recommendations = recommendations_by_type.get(
        normalized_soil_type,
        [
            SoilRecommendation(
                input_name="Soil-test-based NPK",
                purpose="Match fertilizer application to measured nutrient availability.",
                application_guidance="Use the latest laboratory soil report before selecting a dose.",
            ),
            SoilRecommendation(
                input_name="Organic matter",
                purpose="Improve soil structure and nutrient retention.",
                application_guidance="Apply well-decomposed compost or farmyard manure before planting.",
            ),
        ],
    )
    return SoilRecommendationsResponse(
        district=district.strip(),
        soil_type=soil_type.strip(),
        regional_survey=regional_survey,
        recommendations=recommendations,
    )