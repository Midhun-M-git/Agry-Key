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


def test_zero_touch_geo_language_detection_coimbatore():
    response = client.post("/api/v1/geo/detect-language", json={"latitude": 11.0168, "longitude": 76.9558})
    assert response.status_code == 200
    data = response.json()
    assert data["regional_language_code"] == "ta"
    assert data["district"] == "Coimbatore"
    assert "audio_greeting_url" in data


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


def test_otp_recovery_and_verification_flow(monkeypatch):
    from app.core.config import settings
    monkeypatch.setattr(settings, "SMS_API_KEY", "mock")

    test_phone = "+919123456780"
    # Mock OTP code generation for deterministic testing
    monkeypatch.setattr("app.routers.auth.generate_otp_code", lambda: "482913")

    # Request OTP with properly encoded query param or json body
    resp = client.post("/api/v1/auth/recover", json={"phone_number": test_phone})
    assert resp.status_code == 200
    assert resp.json()["status"] == "success"

    # Query the generated OTP from DB to test that hash is stored (not plaintext)
    from app.core.database import SessionLocal
    from app.models.user import OTPRecord
    db = SessionLocal()
    otp_record = db.query(OTPRecord).filter_by(phone_number=test_phone).order_by(OTPRecord.created_at.desc()).first()
    assert otp_record is not None
    # Verify SHA-256 hash length (64 hex characters) - plaintext OTP is NEVER stored
    assert len(otp_record.otp_code) == 64
    db.close()

    # Wrong OTP fails
    bad_resp = client.post("/api/v1/auth/verify-otp", json={"phone_number": test_phone, "otp_code": "000000"})
    assert bad_resp.status_code == 400

    # Correct OTP succeeds and returns JWT tokens + auto-created farmer profile
    good_resp = client.post("/api/v1/auth/verify-otp", json={"phone_number": test_phone, "otp": "482913"})
    assert good_resp.status_code == 200
    data = good_resp.json()
    assert data["token_type"] == "bearer"
    assert "access_token" in data
    assert "refresh_token" in data


