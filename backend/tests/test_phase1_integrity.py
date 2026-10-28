"""Tests for Phase 1 production data integrity and fail-closed behaviors."""

import pytest
from unittest.mock import patch, MagicMock
from app.services.data_fetcher import DataFetcherService
from app.services.agmarknet_fetcher import AgmarknetFetcher
from app.routers.market import get_mandi_prices, get_price_history, _format_price_entry
from app.routers.community import list_posts
from app.routers.schemes import list_schemes
from app.models.community import Post
from app.models.scheme import Scheme
from app.core.database import SessionLocal


def test_weather_fails_closed_without_synthetic_defaults():
    """Verify weather returns unavailable without synthetic 28.0C / 70% defaults when API fails."""
    service = DataFetcherService()
    with patch("httpx.Client") as mock_client:
        mock_instance = MagicMock()
        mock_instance.__enter__.return_value.get.side_effect = Exception("Open-Meteo connection timeout")
        mock_client.return_value = mock_instance

        with patch("urllib.request.urlopen", side_effect=Exception("urllib failure")):
            result = service.fetch_climate_baseline(10.7867, 76.6547)

    assert result["status"] == "unavailable"
    assert result["current"] is None
    assert result["avg_max_temperature_c"] is None
    assert result["total_precipitation_mm"] is None
    assert result["forecast"] == []


def test_weather_rejects_incomplete_provider_payload():
    """Verify weather fails closed when critical fields like temperature_2m are missing."""
    service = DataFetcherService()
    incomplete_payload = {
        "current": {
            # temperature_2m missing
            "relative_humidity_2m": 65,
        },
        "daily": {"time": ["2026-10-28"]}
    }
    with patch("httpx.Client") as mock_client:
        mock_instance = MagicMock()
        mock_resp = MagicMock()
        mock_resp.status_code = 200
        mock_resp.json.return_value = incomplete_payload
        mock_instance.__enter__.return_value.get.return_value = mock_resp
        mock_client.return_value = mock_instance

        result = service.fetch_climate_baseline(10.7867, 76.6547)

    assert result["status"] == "unavailable"
    assert result["current"] is None


def test_input_costs_fails_closed_without_hardcoded_defaults():
    """Verify input costs return None/unavailable when not present in database."""
    service = DataFetcherService()
    costs = service.fetch_input_costs("NonExistentDistrictXYZ")
    assert costs["diesel_price_per_liter"] is None
    assert costs["urea_bag_price"] is None
    assert costs["labour_rate_per_day"] is None
    assert costs["status"] == "unavailable"


def test_market_unmatched_district_returns_empty_not_synthetic():
    """Verify market prices return empty list, not cross-district benchmark substitutions."""
    fetcher = AgmarknetFetcher()
    # District with no coverage
    items = fetcher.fetch_live_mandi_prices(district="UnknownDistrict999")
    assert items == []


def test_market_price_formatting_no_synthetic_spread_or_trend():
    """Verify _format_price_entry never invents min/max or synthetic fluctuation ratio."""
    raw = {
        "commodity_name": "Turmeric",
        "modal_price": 7500.0,
        # min_price, max_price, and change_percent omitted
        "price_unit": "quintal",
        "mandi_name": "Sultan Bathery",
        "district": "Wayanad",
        "state": "Kerala",
    }
    formatted = _format_price_entry(raw)
    assert formatted["price"] == 7500.0
    assert formatted["min_price"] is None
    assert formatted["max_price"] is None
    assert formatted["change_percent"] is None
    assert formatted["data_type"] == "reference_market_price"


def test_price_history_fails_closed_without_multiplier_curve():
    """Verify get_price_history returns unavailable when no dated historical observations exist."""
    db = SessionLocal()
    try:
        res = get_price_history(crop="RareExoticCrop999", district="Palakkad", db=db)
        assert res["status"] == "unavailable"
        assert res["history"] == []
        assert "unavailable" in res["message"].lower()
    finally:
        db.close()


def test_community_feed_never_auto_seeds_demo_posts():
    """Verify list_posts does not inject fake Palakkad blast posts into an empty database."""
    db = SessionLocal()
    try:
        # Query for any non-existent district
        res = list_posts(page=1, page_size=20, district="UniqueEmptyDistrictTest", current_user=None, db=db)
        assert res.total == 0
        assert res.items == []
    finally:
        db.close()


def test_schemes_all_have_official_gov_sources():
    """Verify all seeded government schemes carry valid official government portal URLs."""
    db = SessionLocal()
    try:
        schemes = list_schemes(db=db)
        for s in schemes:
            assert s.official_url is not None
            assert "gov.in" in s.official_url or "nic.in" in s.official_url
            assert s.name != ""
            assert s.code != ""
    finally:
        db.close()



def test_seed_db_refuses_when_deployed():
    """Verify seed_db.py aborts with SystemExit when running in deployed environment."""
    from scripts.seed_db import seed_database
    from app.core.config import settings

    prev = settings.ENVIRONMENT
    settings.ENVIRONMENT = "production"
    try:
        with pytest.raises(SystemExit) as exc:
            seed_database()
        assert exc.value.code == 1
    finally:
        settings.ENVIRONMENT = prev


def test_cli_seed_demo_refuses_when_deployed():
    """Verify app.cli seed-demo aborts with SystemExit when running in deployed environment."""
    from app.cli import seed_demo_data
    from app.core.config import settings

    prev = settings.ENVIRONMENT
    settings.ENVIRONMENT = "production"
    try:
        with pytest.raises(SystemExit) as exc:
            seed_demo_data()
        assert exc.value.code == 1
    finally:
        settings.ENVIRONMENT = prev


def test_unverified_schemes_hidden_when_deployed():
    """Verify list_schemes filters out schemes whose verification_status is unverified in deployed environments."""
    from app.core.config import settings

    prev = settings.ENVIRONMENT
    settings.ENVIRONMENT = "production"
    db = SessionLocal()
    try:
        schemes = list_schemes(db=db)
        # All 11 seed schemes are unverified, so zero should be returned when deployed
        assert len(schemes) == 0
    finally:
        db.close()
        settings.ENVIRONMENT = prev


def test_readiness_fails_if_demo_seed_in_deployed():
    """Verify readiness check returns 503 if demo_seed rows exist in market_price_trends when deployed."""
    from app.routers.health import readiness_check
    from app.models.economics import MarketPriceTrend
    from app.core.config import settings

    prev = settings.ENVIRONMENT
    settings.ENVIRONMENT = "production"
    db = SessionLocal()
    demo_row = None
    try:
        demo_row = MarketPriceTrend(
            commodity_name="DemoCropTest",
            modal_price=100.0,
            min_price=90.0,
            max_price=110.0,
            price_unit="quintal",
            mandi_name="DemoMandi",
            district="DemoDistrict",
            state="DemoState",
            sector="CROPS",
            official_source="Demo APMC Source",
            source_id="demo_seed",
        )
        db.add(demo_row)
        db.commit()

        from app.routers.health import verify_startup_provenance
        verify_startup_provenance(db=db, force=True)
        resp = readiness_check(db=db)
        # Should return JSONResponse with status 503
        assert hasattr(resp, "status_code")
        assert resp.status_code == 503
    finally:
        if demo_row:
            db.delete(demo_row)
            db.commit()
            verify_startup_provenance(db=db, force=True)
        db.close()
        settings.ENVIRONMENT = prev
