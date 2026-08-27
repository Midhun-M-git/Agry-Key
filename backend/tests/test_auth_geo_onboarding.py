from fastapi.testclient import TestClient
from app.main import app
from app.core.database import Base, engine

client = TestClient(app)


def setup_module(module):
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)


def test_zero_touch_geo_language_detection_palakkad():
    response = client.post("/api/v1/geo/detect-language", json={"latitude": 10.7867, "longitude": 76.6547})
    assert response.status_code == 200
    data = response.json()
    assert data["regional_language_code"] == "ml"
    assert data["district"] == "Palakkad"
    assert data["dialect_pack_id"] == "palakkad_malayalam"
    assert "audio_greeting_url" in data
    assert "ui_translations" in data


def test_i18n_translations():
    response = client.get("/api/v1/i18n/translations?lang=ml")
    assert response.status_code == 200
    data = response.json()
    assert data["language_code"] == "ml"
    assert "welcome" in data["translations"]


def test_user_registration_and_login_flow():
    # 1. Register User
    reg_payload = {
        "phone_number": "+919876543210",
        "password": "SecretPassword123",
        "full_name": "Sreekumar Farmer",
        "role": "FARMER",
        "preferred_language": "ml"
    }
    response = client.post("/api/v1/auth/register", json=reg_payload)
    assert response.status_code == 201
    user_data = response.json()
    assert user_data["phone_number"] == "+919876543210"

    # 2. Login User
    login_payload = {
        "phone_number": "+919876543210",
        "password": "SecretPassword123"
    }
    response = client.post("/api/v1/auth/login", json=login_payload)
    assert response.status_code == 200
    tokens = response.json()
    assert "access_token" in tokens
    assert tokens["token_type"] == "bearer"

    token = tokens["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 3. Get Active Profile
    me_resp = client.get("/api/v1/auth/me", headers=headers)
    assert me_resp.status_code == 200
    assert me_resp.json()["phone_number"] == "+919876543210"

    # 4. Onboard Multi-Sector Farm Portfolio (Palakkad Region)
    onboard_payload = {
        "state": "Kerala",
        "district": "Palakkad",
        "latitude": 10.7867,
        "longitude": 76.6547,
        "plots": [
            {
                "plot_name": "Paddy Field Palakkad",
                "acreage": 3.0,
                "soil_type": "Alluvial",
                "water_source": "River",
                "crops_currently_grown": ["Paddy"]
            }
        ],
        "livestock": [
            {
                "animal_type": "Cow",
                "breed": "Veechur",
                "head_count": 50,
                "purpose": "DAIRY"
            }
        ],
        "aquaculture": [
            {
                "pond_name": "Main Fish Pond",
                "pond_size_acres": 0.5,
                "fish_species": "Karimeen"
            }
        ]
    }
    onboard_resp = client.post("/api/v1/onboarding/farm", json=onboard_payload, headers=headers)
    assert onboard_resp.status_code == 200
    onboard_data = onboard_resp.json()
    assert onboard_data["status"] == "success"
    assert len(onboard_data["configured_units"]) == 3
