"""Live Mandi market prices and agricultural commodity price trends."""

from datetime import datetime, timezone, timedelta
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.economics import MarketPriceTrend
from app.services.agmarknet_fetcher import agmarknet_fetcher, PRIMARY_MANDI_DATASETS

router = APIRouter(prefix="/market", tags=["Market Prices"])


def _format_price_entry(record: Dict[str, Any]) -> Dict[str, Any]:
    commodity = record.get("commodity_name") or record.get("crop") or "Unknown"
    modal = float(record.get("modal_price") or record.get("price") or 0.0)
    min_p = float(record["min_price"]) if record.get("min_price") is not None else None
    max_p = float(record["max_price"]) if record.get("max_price") is not None else None
    unit = record.get("price_unit") or record.get("unit") or "quintal"
    mandi = record.get("mandi_name") or record.get("mandi") or ""
    district = record.get("district") or ""
    state = record.get("state") or ""

    trend = record.get("change_percent")
    if trend is not None:
        try:
            trend = float(trend)
        except (ValueError, TypeError):
            trend = None

    obs_date = record.get("observation_date") or record.get("trend_date") or record.get("arrival_date")
    if obs_date is not None and hasattr(obs_date, "isoformat"):
        obs_date = obs_date.isoformat()

    return {
        "crop": commodity,
        "commodity_name": commodity,
        "price": modal,
        "modal_price": modal,
        "min_price": min_p,
        "max_price": max_p,
        "unit": unit,
        "price_unit": unit,
        "change_percent": trend,
        "mandi": mandi,
        "mandi_name": mandi,
        "district": district,
        "state": state,
        "sector": record.get("sector", "CROP"),
        "official_source": record.get("official_source", "Agmarknet APMC Portal / State Marketing Board"),
        "observation_date": str(obs_date) if obs_date else None,
        "is_live": bool(record.get("is_live", False)),
        "data_type": "reference_market_price",
    }


@router.get("/prices")
def get_mandi_prices(
    district: Optional[str] = Query(default=None, description="Filter by district name"),
    crop: Optional[str] = Query(default=None, description="Filter by crop/commodity name"),
    state: Optional[str] = Query(default=None, description="Filter by state name"),
    db: Session = Depends(get_db),
) -> List[Dict[str, Any]]:
    """
    Returns live APMC mandi prices for agricultural produce, filtered by district, state, or crop.
    First checks database records, falling back to comprehensive verified Agmarknet baseline datasets.
    """
    # 1. Check DB first
    query = db.query(MarketPriceTrend).filter((MarketPriceTrend.source_id.is_(None)) | (MarketPriceTrend.source_id != 'demo_seed'))
    if district and district.strip():
        query = query.filter(MarketPriceTrend.district.ilike(f"%{district.strip()}%"))
    if state and state.strip():
        query = query.filter(MarketPriceTrend.state.ilike(f"%{state.strip()}%"))
    if crop and crop.strip():
        query = query.filter(MarketPriceTrend.commodity_name.ilike(f"%{crop.strip()}%"))

    db_records = query.all()
    if db_records:
        return [
            _format_price_entry({
                "commodity_name": r.commodity_name,
                "modal_price": r.modal_price,
                "min_price": r.min_price,
                "max_price": r.max_price,
                "price_unit": r.price_unit,
                "mandi_name": r.mandi_name,
                "district": r.district,
                "state": r.state,
                "sector": r.sector,
                "official_source": r.official_source,
            })
            for r in db_records
        ]

    # 2. Comprehensive Agmarknet Ingestion dataset fallback
    live_items = agmarknet_fetcher.fetch_live_mandi_prices(district=district, state=state)

    if crop and crop.strip():
        c_low = crop.strip().lower()
        live_items = [
            item for item in live_items
            if c_low in item["commodity_name"].lower() or item["commodity_name"].lower() in c_low
        ]

    # Never substitute unrelated districts if query returned no matches
    return [_format_price_entry(item) for item in live_items]


@router.get("/search")
def search_crops(
    query: str = Query(..., min_length=1, description="Crop search query"),
    db: Session = Depends(get_db),
) -> List[Dict[str, Any]]:
    """Searches crops and commodities across all active mandis."""
    q_clean = query.strip().lower()

    # Search in DB
    db_items = db.query(MarketPriceTrend).filter(
        MarketPriceTrend.commodity_name.ilike(f"%{q_clean}%"),
        (MarketPriceTrend.source_id.is_(None)) | (MarketPriceTrend.source_id != 'demo_seed'),
    ).all()

    if db_items:
        return [
            _format_price_entry({
                "commodity_name": r.commodity_name,
                "modal_price": r.modal_price,
                "min_price": r.min_price,
                "max_price": r.max_price,
                "price_unit": r.price_unit,
                "mandi_name": r.mandi_name,
                "district": r.district,
                "state": r.state,
                "sector": r.sector,
            })
            for r in db_items
        ]

    # Fallback search in primary datasets
    matches = [
        item for item in PRIMARY_MANDI_DATASETS
        if q_clean in item["commodity_name"].lower() or q_clean in item.get("sector", "").lower()
    ]
    return [_format_price_entry(item) for item in matches]


@router.get("/history")
def get_price_history(
    crop: str = Query(..., description="Crop name to fetch historical trends"),
    district: Optional[str] = Query(default=None, description="District filter"),
    db: Session = Depends(get_db),
) -> Dict[str, Any]:
    """
    Returns dated historical observations recorded in the database.
    If no observations exist for this crop and region, honestly returns status: unavailable.
    Never invents synthetic multipliers or fake historical price curves.
    """
    c_clean = crop.strip().lower()
    query = db.query(MarketPriceTrend).filter(
        MarketPriceTrend.commodity_name.ilike(f"%{c_clean}%"),
        (MarketPriceTrend.source_id.is_(None)) | (MarketPriceTrend.source_id != 'demo_seed'),
    )
    if district and district.strip():
        query = query.filter(MarketPriceTrend.district.ilike(f"%{district.strip()}%"))

    records = query.order_by(MarketPriceTrend.fetched_at.asc()).all()
    if not records:
        return {
            "status": "unavailable",
            "message": f"Historical price observations for '{crop}' are unavailable for this region.",
            "history": [],
        }

    history = [
        {
            "date": r.fetched_at.isoformat() if hasattr(r.fetched_at, "isoformat") else str(r.fetched_at),
            "price": float(r.modal_price),
            "modal_price": float(r.modal_price),
            "unit": r.price_unit,
            "mandi": r.mandi_name,
            "source": r.official_source,
        }
        for r in records
    ]
    return {
        "status": "available",
        "crop": crop,
        "history": history,
    }
