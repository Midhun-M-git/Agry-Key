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

