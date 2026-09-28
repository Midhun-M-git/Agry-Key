"""Unit tests for Blockchain Anti-Fraud, Merkle Hashing, and Produce Registries."""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.blockchain import OfficialFertilizerMRP, BlockchainLedgerBlock
from app.models.user import User, FarmerProfile, UserRole
from app.routers.auth import get_current_user
from app.services.blockchain_service import BlockchainService

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_blockchain_db():
    db = SessionLocal()
    # Ensure sample official fertilizer MRP is present
    test_batch = "IFFCO-TEST-2026-01"
    existing = db.query(OfficialFertilizerMRP).filter(OfficialFertilizerMRP.batch_number == test_batch).first()
    if not existing:
        payload = {
            "batch_number": test_batch,
            "fertilizer_name": "IFFCO Nano Urea 500ml",
            "manufacturer": "IFFCO India Ltd",
            "official_mrp_inr": 225.0,
        }
        h = BlockchainService.calculate_merkle_hash(payload)
        rec = OfficialFertilizerMRP(
            batch_number=test_batch,
            manufacturer="IFFCO India Ltd",
            fertilizer_name="IFFCO Nano Urea 500ml",
            official_mrp_inr=225.0,
            merkle_hash=h,
            qr_code_payload=f'{{"batch":"{test_batch}","mrp":225.0,"hash":"{h}"}}',
        )
        db.add(rec)
        db.commit()

    # Ensure farmer user exists
    farmer = db.query(User).filter(User.phone_number == "+919988776655").first()
    if not farmer:
        farmer = User(
            phone_number="+919988776655",
            full_name="Palakkad Verified Farmer",
            role=UserRole.FARMER,
        )
        db.add(farmer)
        db.commit()
        db.refresh(farmer)

        profile = FarmerProfile(
            user_id=farmer.id,
            state="Kerala",
            district="Palakkad",
        )
        db.add(profile)
        db.commit()

    db.close()
    yield


def test_merkle_hash_calculation():
    payload_a = {"item": "Paddy", "quantity": 100}
    payload_b = {"quantity": 100, "item": "Paddy"}
    # Canonical ordering produces identical hash
    assert BlockchainService.calculate_merkle_hash(payload_a) == BlockchainService.calculate_merkle_hash(payload_b)


def test_verify_fertilizer_authentic_and_overcharging():
    # 1. Authentic at normal price
    resp = client.post(
        "/api/v1/blockchain/verify-fertilizer",
        json={"batch_number": "IFFCO-TEST-2026-01", "dealer_asking_price": 225.0},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["is_authentic"] is True
    assert data["status"] == "AUTHENTIC"
    assert data["official_mrp_inr"] == 225.0
    assert data["overcharging_detected"] is False

    # 2. Overcharging dealer asking 275 INR
    resp_overcharge = client.post(
        "/api/v1/blockchain/verify-fertilizer",
        json={"batch_number": "IFFCO-TEST-2026-01", "dealer_asking_price": 275.0},
    )
    assert resp_overcharge.status_code == 200
    data_oc = resp_overcharge.json()
    assert data_oc["overcharging_detected"] is True
    assert data_oc["overcharge_amount_inr"] == 50.0

    # 3. GET endpoint for QR barcode scanner links
    resp_get = client.get("/api/v1/blockchain/verify-fertilizer?batch_number=IFFCO-TEST-2026-01")
    assert resp_get.status_code == 200
    assert resp_get.json()["is_authentic"] is True


def test_verify_fertilizer_unregistered_counterfeit():
    resp = client.post(
        "/api/v1/blockchain/verify-fertilizer",
        json={"batch_number": "FAKE-DEALER-BATCH-999"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["is_authentic"] is False
    assert data["status"] == "UNREGISTERED_BATCH"


def test_register_and_verify_produce_stock():
    db = SessionLocal()
    farmer = db.query(User).filter(User.phone_number == "+919988776655").first()
    db.close()

    app.dependency_overrides[get_current_user] = lambda: farmer

    # Register produce
    resp = client.post(
        "/api/v1/blockchain/register-produce",
        json={"produce_type": "Palakkad Matta Rice", "quantity": 500.0, "quantity_unit": "kg"},
    )
    app.dependency_overrides.clear()
    assert resp.status_code == 201
    prod_data = resp.json()
    assert prod_data["produce_batch_id"].startswith("PROD-")
    assert prod_data["quantity"] == 500.0
    batch_id = prod_data["produce_batch_id"]

    # Verify produce provenance via POST
    verify_resp = client.post(
        "/api/v1/blockchain/verify-produce",
        json={"identifier": batch_id},
    )
    assert verify_resp.status_code == 200
    v_data = verify_resp.json()
    assert v_data["is_verified"] is True
    assert v_data["produce_type"] == "Palakkad Matta Rice"
    assert v_data["anti_hoarding_verified"] is True

    # Record sale under PLATFORM_VERIFIED tier
    app.dependency_overrides[get_current_user] = lambda: farmer
    sale_resp = client.post(
        "/api/v1/blockchain/record-sale",
        json={
            "produce_batch_id": batch_id,
            "quantity_sold": 150.0,
            "sale_price_total": 7500.0,
            "verification_tier": "PLATFORM_VERIFIED",
            "buyer_details": "Agry-Key Verified Co-Op",
        },
    )
    app.dependency_overrides.clear()
    assert sale_resp.status_code == 200
    s_data = sale_resp.json()
    assert s_data["status"] == "SUCCESS"
    assert s_data["verification_tier"] == "PLATFORM_VERIFIED"
    assert s_data["remaining_verified_stock"] == 350.0


def test_blockchain_ledger_blocks_retrieval():
    resp = client.get("/api/v1/blockchain/ledger?limit=10")
    assert resp.status_code == 200
    blocks = resp.json()
    assert isinstance(blocks, list)
    if len(blocks) > 0:
        assert "block_hash" in blocks[0]
        assert "previous_hash" in blocks[0]
