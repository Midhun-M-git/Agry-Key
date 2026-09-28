"""Unit and integration tests for the mobile-number OTP authentication feature."""

from datetime import datetime, timedelta, timezone
from fastapi.testclient import TestClient
import pytest

from app.main import app
from app.core.config import settings
from app.core.database import SessionLocal
from app.models.user import User, FarmerProfile, OTPRecord, UserRole
from app.routers.auth import _otp_requests
from app.utils.phone import normalize_indian_phone

client = TestClient(app)


@pytest.fixture(autouse=True)
def reset_rate_limits():
    """Resets rate limiting queue between test runs."""
    _otp_requests.clear()
    yield
    _otp_requests.clear()



def test_phone_normalization():
    """Validates that various common Indian phone formats normalize to +91XXXXXXXXXX."""
    assert normalize_indian_phone("9876543210") == "+919876543210"
    assert normalize_indian_phone("+91 98765 43210") == "+919876543210"
    assert normalize_indian_phone("09876543210") == "+919876543210"
    assert normalize_indian_phone("919876543210") == "+919876543210"
    assert normalize_indian_phone("+919876543210") == "+919876543210"
    assert normalize_indian_phone(" +91-98765-43210 ") == "+919876543210"

    # Invalid formats
    with pytest.raises(ValueError):
        normalize_indian_phone("12345")
    with pytest.raises(ValueError):
        normalize_indian_phone("1876543210")  # Does not start with 6-9
    with pytest.raises(ValueError):
        normalize_indian_phone("")


def test_otp_flow_new_farmer(monkeypatch):
    """
    Validates end-to-end OTP flow for a new farmer:
    Request OTP -> Development banner printed -> Store SHA-256 hash -> Verify -> Auto-create account + tokens.
    """
    monkeypatch.setattr("app.routers.auth.generate_otp_code", lambda: "555123")
    test_phone = "9811122233"
    expected_norm_phone = "+919811122233"

    # Clean up test user if previously existed
    db = SessionLocal()
    existing = db.query(User).filter_by(phone_number=expected_norm_phone).first()
    if existing:
        if existing.profile:
            db.delete(existing.profile)
            db.commit()
        db.delete(existing)
        db.commit()
    db.close()

    # 1. Request OTP via /api/auth/request-otp
    resp = client.post("/api/auth/request-otp", json={"phone_number": test_phone})
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "success"
    assert data["expires_in_seconds"] == 300
    # Crucial security assertion: OTP code must NOT be returned in API response
    assert "otp" not in data or data.get("otp") is None

    # 2. Verify OTPRecord stores SHA-256 hash (64 hex characters)
    db = SessionLocal()
    record = (
        db.query(OTPRecord)
        .filter_by(phone_number=expected_norm_phone)
        .order_by(OTPRecord.created_at.desc())
        .first()
    )
    assert record is not None
    assert len(record.otp_code) == 64
    assert record.is_verified is False
    assert record.attempts == 0
    db.close()

    # 3. Wrong OTP returns error and increments attempt counter
    wrong_resp = client.post(
        "/api/auth/verify-otp",
        json={"phone_number": test_phone, "otp": "999999"},
    )
    assert wrong_resp.status_code == 400
    assert "Invalid OTP" in wrong_resp.json()["detail"]

    # 4. Correct OTP succeeds and auto-creates farmer account
    verify_resp = client.post(
        "/api/auth/verify-otp",
        json={"phone_number": test_phone, "otp": "555123"},
    )
    assert verify_resp.status_code == 200
    auth_data = verify_resp.json()
    assert auth_data["token_type"] == "bearer"
    assert auth_data["is_new_user"] is True
    assert auth_data["access_token"] != ""
    assert auth_data["refresh_token"] != ""
    assert auth_data["user"]["phone_number"] == expected_norm_phone
    assert auth_data["user"]["role"] == "FARMER"


def test_otp_flow_existing_farmer(monkeypatch):
    """
    Validates that an existing farmer is logged into their existing account without creating duplicate accounts.
    """
    monkeypatch.setattr("app.routers.auth.generate_otp_code", lambda: "777888")
    test_phone = "+91 98111 22233"  # Same farmer as above
    expected_norm_phone = "+919811122233"

    # Request OTP
    resp = client.post("/api/v1/auth/request-otp", json={"phone_number": test_phone})
    assert resp.status_code == 200

    # Verify OTP
    verify_resp = client.post(
        "/api/v1/auth/verify-otp",
        json={"phone_number": test_phone, "otp": "777888"},
    )
    assert verify_resp.status_code == 200
    auth_data = verify_resp.json()
    assert auth_data["is_new_user"] is False  # Existing farmer!
    assert auth_data["user"]["phone_number"] == expected_norm_phone

    # Verify no duplicate user was created
    db = SessionLocal()
    users = db.query(User).filter_by(phone_number=expected_norm_phone).all()
    assert len(users) == 1
    db.close()


def test_otp_expiry(monkeypatch):
    """Validates that expired OTP records are rejected."""
    monkeypatch.setattr("app.routers.auth.generate_otp_code", lambda: "111222")
    test_phone = "9700011122"
    expected_norm_phone = "+919700011122"

    client.post("/api/auth/request-otp", json={"phone_number": test_phone})

    # Artificially expire the record in DB
    db = SessionLocal()
    record = (
        db.query(OTPRecord)
        .filter_by(phone_number=expected_norm_phone)
        .order_by(OTPRecord.created_at.desc())
        .first()
    )
    record.expires_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db.commit()
    db.close()

    # Attempt to verify expired OTP
    verify_resp = client.post(
        "/api/auth/verify-otp",
        json={"phone_number": test_phone, "otp": "111222"},
    )
    assert verify_resp.status_code == 400
    assert "expired" in verify_resp.json()["detail"].lower()


def test_otp_attempt_limits(monkeypatch):
    """Validates that after 5 failed attempts, the OTP is locked."""
    monkeypatch.setattr("app.routers.auth.generate_otp_code", lambda: "333444")
    test_phone = "9800099900"

    client.post("/api/auth/request-otp", json={"phone_number": test_phone})

    # Fail 5 times
    for _ in range(5):
        resp = client.post("/api/auth/verify-otp", json={"phone_number": test_phone, "otp": "000000"})
        assert resp.status_code == 400

    # 6th attempt (even with correct code) should be rejected due to attempt limit
    locked_resp = client.post("/api/auth/verify-otp", json={"phone_number": test_phone, "otp": "333444"})
    assert locked_resp.status_code == 400
    assert "too many" in locked_resp.json()["detail"].lower()
