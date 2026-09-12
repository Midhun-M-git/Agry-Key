"""Weather and agricultural alert API routes."""

from fastapi import APIRouter, Query

from app.services.data_fetcher import data_fetcher_service

router = APIRouter(prefix="/weather", tags=["Weather"])


@router.get("")
def get_weather(
    lat: float = Query(..., ge=-90, le=90, description="GPS latitude"),
    lng: float = Query(..., ge=-180, le=180, description="GPS longitude"),
):
    """Return current weather, a seven-day forecast, and agricultural alerts."""
    weather = data_fetcher_service.fetch_climate_baseline(lat, lng)
    return {
        "latitude": lat,
        "longitude": lng,
        **weather,
    }