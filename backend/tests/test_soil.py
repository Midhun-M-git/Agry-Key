"""Unit tests for soil survey endpoints and admin upload verification."""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import get_db
from app.models.user import User, UserRole
from app.routers.auth import get_current_user
from app.routers.soil import get_current_admin_user

client = TestClient(app)


def test_get_district_soil_survey_palakkad():
    response = client.get("/api/v1/soil/survey/palakkad")
    assert response.status_code == 200
    data = response.json()
    assert data["district"] == "Palakkad"
    assert data["state"] == "Kerala"
    assert len(data["panchayaths_and_taluks"]) >= 4
    taluk_names = [t["taluk"] for t in data["panchayaths_and_taluks"]]
    assert "Alathur" in taluk_names
    assert "Chittur" in taluk_names


def test_get_district_soil_survey_coimbatore():
    response = client.get("/api/v1/soil/survey/coimbatore")
    assert response.status_code == 200
    data = response.json()
    assert data["district"] == "Coimbatore"
    assert data["state"] == "Tamil Nadu"
    assert len(data["panchayaths_and_taluks"]) >= 3


def test_get_district_soil_survey_not_found():
    response = client.get("/api/v1/soil/survey/nonexistent_place")
    assert response.status_code == 404


def test_upload_soil_survey_forbidden_for_non_admin():
    farmer_user = User(id=99, phone_number="+919876543210", role=UserRole.FARMER)
    app.dependency_overrides[get_current_user] = lambda: farmer_user

    payload = {
        "state": "Kerala",
        "district": "Palakkad",
        "survey_authority": "Field Survey Team",
        "panchayaths_and_taluks": [
            {
                "taluk": "Alathur",
                "predominant_soil_type": "LATERITE",
                "ph_level": 5.8
            }
        ]
    }
    response = client.post("/api/v1/soil/survey-upload", json=payload)
    app.dependency_overrides.clear()
    assert response.status_code == 403


def test_upload_soil_survey_success_for_admin():
    import shutil
    from pathlib import Path
    from app.core.regions import district_registry

    admin_user = User(id=1, phone_number="+919999999999", role=UserRole.ADMIN)
    app.dependency_overrides[get_current_user] = lambda: admin_user
    app.dependency_overrides[get_current_admin_user] = lambda: admin_user

    payload = {
        "state": "Kerala",
        "district": "Wayanad",
        "survey_authority": "KAU Soil Survey Team",
        "last_updated": "2026-03-25",
        "panchayaths_and_taluks": [
            {
                "taluk": "Vythiri",
                "village_panchayath": "Kalpetta",
                "predominant_soil_type": "HILL_SOIL",
                "ph_level": 5.5,
                "organic_carbon_percent": 0.85,
                "nitrogen_kg_ha": 260.0,
                "phosphorus_kg_ha": 18.0,
                "potassium_kg_ha": 190.0,
                "suitable_crops": ["Coffee", "Tea", "Pepper"]
            }
        ]
    }
    try:
        response = client.post("/api/v1/soil/survey-upload", json=payload)
        assert response.status_code == 200
        assert response.json()["status"] == "success"

        # Verify it can be read back from the endpoint
        survey_res = client.get("/api/v1/soil/survey/wayanad")
        assert survey_res.status_code == 200
        assert survey_res.json()["district"] == "Wayanad"
    finally:
        app.dependency_overrides.clear()
        district_registry._soil_surveys.pop("wayanad", None)
        wayanad_dir = Path(__file__).resolve().parent.parent / "app" / "core" / "regions" / "kerala" / "wayanad"
        if wayanad_dir.exists():
            shutil.rmtree(wayanad_dir)

