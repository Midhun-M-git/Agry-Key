"""Unit tests for agricultural and emergency veterinary services."""

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_get_veterinary_services_palakkad():
    response = client.get("/api/v1/services/veterinary?district=Palakkad")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 3
    clinics = [d["clinic_name"] for d in data]
    assert any("Palakkad" in c for c in clinics)
    assert any("Alathur" in c for c in clinics)
    assert any("Chittur" in c for c in clinics)


def test_get_veterinary_services_coimbatore():
    response = client.get("/api/v1/services/veterinary?district=Coimbatore")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 2
    assert any("Coimbatore" in d["clinic_name"] for d in data)


def test_check_app_update():
    response = client.get("/api/v1/services/app-update")
    assert response.status_code == 200
    data = response.json()
    assert "latest_version" in data
    assert "download_url" in data
    assert data["download_url"].startswith("http")


def test_unit_aware_price_conversions():
    """Validates that price conversions only apply to compatible mass units and reject incompatible units."""
    from app.services.data_fetcher import to_unit_aware_quintal_price

    # Quintal remains same
    assert to_unit_aware_quintal_price(2500.0, "quintal") == 2500.0
    assert to_unit_aware_quintal_price(2500.0, "qtl") == 2500.0

    # Kg converts by 100x
    assert to_unit_aware_quintal_price(25.0, "kg") == 2500.0
    assert to_unit_aware_quintal_price(30.5, "kilogram") == 3050.0

    # Ton / metric ton converts by 0.1x (10 quintals per ton)
    assert to_unit_aware_quintal_price(30000.0, "tonne") == 3000.0
    assert to_unit_aware_quintal_price(20000.0, "ton") == 2000.0

    # Incompatible units return None rather than corrupting calculations
    assert to_unit_aware_quintal_price(5.0, "piece") is None
    assert to_unit_aware_quintal_price(10.0, "count") is None
    assert to_unit_aware_quintal_price(50.0, "litre") is None
    assert to_unit_aware_quintal_price(100.0, "") is None


def test_financial_optimizer_requires_explicit_parameters():
    """Validates that financial optimizer returns status unavailable when crop parameters are not supplied."""
    from app.services.financial_crop_optimizer import FinancialCropOptimizer

    # 1. Without crop candidates -> returns status unavailable (fail-closed)
    result = FinancialCropOptimizer.optimize(
        state="Kerala",
        district="Palakkad",
        acreage=2.0,
        soil_type="RED_LOAMY",
    )
    assert result.get("status") == "unavailable"
    assert "not provided" in result.get("reason", "").lower()

    # 2. With explicit user-provided crop candidates -> computes optimization
    user_crops = [
        {
            "crop_id": "custom_crop",
            "name_en": "Groundnut",
            "expected_yield_quintals": 12.0,
            "harvest_price_per_quintal": 6500.0,
            "seed_cost_per_acre": 3000.0,
            "fertilizer_cost_per_acre": 2500.0,
            "labor_cost_per_acre": 6000.0,
            "duration_days": 105,
            "risk_level": "LOW",
            "strategy_type": "BALANCED",
        }
    ]
    calc_result = FinancialCropOptimizer.optimize(
        state="Kerala",
        district="Palakkad",
        acreage=1.0,
        soil_type="RED_LOAMY",
        crop_candidates=user_crops,
    )
    assert "strategies" in calc_result
    assert len(calc_result["strategies"]) > 0


def test_llm_fallback_advisory_removes_ungrounded_percentage_claims():
    """Validates that offline fallback advisory does not synthesize fabricated numerical percentage improvements."""
    from app.agents.llm_client import LLMClient

    client_llm = LLMClient()
    insights = client_llm.generate_response(
        prompt="Farmer in Palakkad looking for strategy for crop harvest."
    )
    assert "12-18%" not in insights
    assert "30-40%" not in insights
    assert "25%" not in insights
    assert "unavailable" in insights.lower()


def test_production_mock_payment_lockdown():
    """Validates that ALLOW_MOCK_PAYMENT cannot be set to True in production environment."""
    from app.core.config import Settings
    import pytest

    # Should raise ValueError
    with pytest.raises(ValueError, match="ALLOW_MOCK_PAYMENT cannot be True in"):
        Settings(
            ENVIRONMENT="production",
            ALLOW_MOCK_PAYMENT=True,
            SECRET_KEY="a" * 32,
        )


def test_cli_demo_data_verifier():
    """Validates that cli check_demo_data function executes without error."""
    from app.cli import check_demo_data
    # Should run and return boolean
    result = check_demo_data()
    assert isinstance(result, bool)


