import os
import sys
import pytest

_repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if _repo_root not in sys.path:
    sys.path.insert(0, _repo_root)

from fastapi.testclient import TestClient
from dl_microservice.app import app


@pytest.fixture
def dl_client():
    return TestClient(app)


def test_dl_microservice_health(dl_client):
    res = dl_client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "healthy"


def test_dl_microservice_root(dl_client):
    res = dl_client.get("/")
    assert res.status_code == 200
    assert "model_version" in res.json()


def test_dl_predict_with_valid_token(dl_client):
    res = dl_client.post(
        "/api/predict",
        json={"district": "Palakkad", "commodity": "Paddy"},
        headers={"Authorization": "Bearer secret-service-token-123"},
    )
    assert res.status_code == 200
    data = res.json()
    assert data["commodity"] == "Paddy"
    assert data["district"] == "Palakkad"
    assert data["status"] == "unavailable"
    assert data["reason"] == "Insufficient historical data for accurate forecasting"
    assert data["predicted_trend_30_days"] is None
    assert data["confidence_score"] is None


def test_dl_predict_unauthorized(dl_client):
    res = dl_client.post(
        "/api/predict",
        json={"district": "Palakkad", "commodity": "Paddy"},
        headers={"Authorization": "Bearer invalid-wrong-token"},
    )
    assert res.status_code == 401


def test_dl_predict_general_fallback_commodity(dl_client):
    res = dl_client.post(
        "/api/predict",
        json={"district": "Coimbatore", "commodity": "Dragonfruit"},
        headers={"Authorization": "Bearer secret-service-token-123"},
    )
    assert res.status_code == 200
    data = res.json()
    assert data["commodity"] == "Dragonfruit"
    assert data["status"] == "unavailable"
    assert data["reason"] == "Insufficient historical data for accurate forecasting"
    assert data["predicted_trend_30_days"] is None


def test_dl_custom_token_rejects_alternate_defaults(dl_client, monkeypatch):
    """Validates that configuring a custom token rejects hardcoded defaults or alternate allowlists."""
    import dl_microservice.app as dl_app

    monkeypatch.setattr(dl_app, "EXPECTED_TOKEN", "custom-production-token-999")

    # Hardcoded/old token should now be rejected
    res_old = dl_client.post(
        "/api/predict",
        json={"district": "Palakkad", "commodity": "Paddy"},
        headers={"Authorization": "Bearer secure-service-token-agry-key-2026"},
    )
    assert res_old.status_code == 401

    # Default secret should be rejected
    res_default = dl_client.post(
        "/api/predict",
        json={"district": "Palakkad", "commodity": "Paddy"},
        headers={"Authorization": "Bearer secret-service-token-123"},
    )
    assert res_default.status_code == 401

    # Custom token succeeds
    res_custom = dl_client.post(
        "/api/predict",
        json={"district": "Palakkad", "commodity": "Paddy"},
        headers={"Authorization": "Bearer custom-production-token-999"},
    )
    assert res_custom.status_code == 200
