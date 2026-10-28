"""Unit and concurrency tests for marketplace orders, atomic stock reservations, and role authorization."""

from datetime import datetime, timedelta, timezone
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.marketplace import Product
from app.models.order import Order, OrderStatus
from app.models.user import User, FarmerProfile, UserRole
from app.routers.auth import get_current_user

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_order_entities():
    db = SessionLocal()
    # Farmer A
    farmer_a = db.query(User).filter(User.phone_number == "+919555111111").first()
    if not farmer_a:
        farmer_a = User(phone_number="+919555111111", full_name="Farmer Alice", role=UserRole.FARMER)
        db.add(farmer_a)
        db.commit()
        db.refresh(farmer_a)
        db.add(FarmerProfile(user_id=farmer_a.id, state="Kerala", district="Palakkad"))
        db.commit()

    # Farmer B
    farmer_b = db.query(User).filter(User.phone_number == "+919555222222").first()
    if not farmer_b:
        farmer_b = User(phone_number="+919555222222", full_name="Farmer Bob", role=UserRole.FARMER)
        db.add(farmer_b)
        db.commit()
        db.refresh(farmer_b)
        db.add(FarmerProfile(user_id=farmer_b.id, state="Kerala", district="Kollam"))
        db.commit()

    # Buyer A
    buyer_a = db.query(User).filter(User.phone_number == "+919555333333").first()
    if not buyer_a:
        buyer_a = User(phone_number="+919555333333", full_name="Buyer Charlie", role=UserRole.BUYER)
        db.add(buyer_a)
        db.commit()

    # Buyer B
    buyer_b = db.query(User).filter(User.phone_number == "+919555444444").first()
    if not buyer_b:
        buyer_b = User(phone_number="+919555444444", full_name="Buyer Dave", role=UserRole.BUYER)
        db.add(buyer_b)
        db.commit()

    db.close()
    yield


def test_order_atomic_stock_decrement_and_insufficient_stock():
    db = SessionLocal()
    farmer_a = db.query(User).filter(User.phone_number == "+919555111111").first()
    buyer_a = db.query(User).filter(User.phone_number == "+919555333333").first()

    # Create fresh product with 10 kg
    prod = Product(
        farmer_id=farmer_a.id,
        name="Organic Turmeric Test",
        crop_type="Turmeric",
        sector="CROPS",
        quality_grade="A",
        district="Palakkad",
        quantity=10.0,
        unit="kg",
        price_per_unit=120.0,
        is_active=True,
    )
    db.add(prod)
    db.commit()
    db.refresh(prod)
    prod_id = prod.id
    farmer_a_id = farmer_a.id
    buyer_a_id = buyer_a.id
    db.close()

    def _get_buyer_a():
        s = SessionLocal()
        return s.query(User).filter(User.id == buyer_a_id).first()

    app.dependency_overrides[get_current_user] = _get_buyer_a

    # 1. Order 8 kg -> Success, remaining is 2 kg
    resp = client.post(
        "/api/v1/orders",
        json={
            "product_id": prod_id,
            "quantity": 8.0,
            "delivery_address": "123 Farm Road, Kochi",
        },
    )
    assert resp.status_code == 201
    order_data = resp.json()
    assert order_data["quantity"] == 8.0
    assert order_data["total_amount"] == 960.0

    db_check = SessionLocal()
    p = db_check.query(Product).filter(Product.id == prod_id).first()
    assert p.quantity == 2.0
    db_check.close()

    # 2. Order 5 kg when only 2 kg remain -> 400 Bad Request
    fail_resp = client.post(
        "/api/v1/orders",
        json={
            "product_id": prod_id,
            "quantity": 5.0,
            "delivery_address": "123 Farm Road, Kochi",
        },
    )
    assert fail_resp.status_code == 409
    assert "Insufficient available product quantity" in fail_resp.json()["detail"]

    # Stock must still be 2.0
    db_check = SessionLocal()
    p = db_check.query(Product).filter(Product.id == prod_id).first()
    assert p.quantity == 2.0
    db_check.close()

    app.dependency_overrides.clear()


def test_order_creation_expired_listing_rejected():
    db = SessionLocal()
    farmer_a = db.query(User).filter(User.phone_number == "+919555111111").first()
    buyer_a = db.query(User).filter(User.phone_number == "+919555333333").first()

    # Create expired product listing
    expired_prod = Product(
        farmer_id=farmer_a.id,
        name="Expired Fish Batch",
        crop_type="Tilapia",
        sector="AQUACULTURE",
        quality_grade="B",
        district="Palakkad",
        quantity=50.0,
        unit="kg",
        price_per_unit=200.0,
        is_active=True,
        expires_at=datetime.now(timezone.utc) - timedelta(hours=2),
    )
    db.add(expired_prod)
    db.commit()
    db.refresh(expired_prod)
    prod_id = expired_prod.id
    buyer_a_id = buyer_a.id
    db.close()

    def _get_buyer_a():
        s = SessionLocal()
        return s.query(User).filter(User.id == buyer_a_id).first()

    app.dependency_overrides[get_current_user] = _get_buyer_a

    resp = client.post(
        "/api/v1/orders",
        json={
            "product_id": prod_id,
            "quantity": 5.0,
            "delivery_address": "456 Ocean Road, Kochi",
        },
    )
    app.dependency_overrides.clear()
    assert resp.status_code == 400
    assert "listing has expired" in resp.json()["detail"].lower()


def test_order_status_update_permissions():
    """Validates that only the actual selling farmer can update order status."""
    db = SessionLocal()
    farmer_a = db.query(User).filter(User.phone_number == "+919555111111").first()
    farmer_b = db.query(User).filter(User.phone_number == "+919555222222").first()
    buyer_a = db.query(User).filter(User.phone_number == "+919555333333").first()

    prod = Product(
        farmer_id=farmer_a.id,
        name="Cardamom Grade A",
        crop_type="Cardamom",
        sector="CROPS",
        quality_grade="A",
        district="Idukki",
        quantity=20.0,
        unit="kg",
        price_per_unit=1500.0,
        is_active=True,
    )
    db.add(prod)
    db.commit()

    order = Order(
        buyer_id=buyer_a.id,
        farmer_id=farmer_a.id,
        product_id=prod.id,
        product_name="Cardamom Grade A",
        quantity=2.0,
        unit="kg",
        price_per_unit=1500.0,
        total_amount=3000.0,
        delivery_address="Market Lane, Munnar",
        status=OrderStatus.CONFIRMED,
    )
    db.add(order)
    db.commit()
    order_id = order.id
    farmer_a_id = farmer_a.id
    farmer_b_id = farmer_b.id
    buyer_a_id = buyer_a.id
    db.close()

    def _get_farmer_a():
        s = SessionLocal()
        return s.query(User).filter(User.id == farmer_a_id).first()

    def _get_farmer_b():
        s = SessionLocal()
        return s.query(User).filter(User.id == farmer_b_id).first()

    # Farmer B (unrelated farmer) attempts to update status -> 403 Forbidden
    app.dependency_overrides[get_current_user] = _get_farmer_b
    resp_unauth = client.put(f"/api/v1/orders/{order_id}/status", json={"status": "SHIPPED"})
    assert resp_unauth.status_code == 403
    assert "permission" in resp_unauth.json()["detail"].lower() or "seller" in resp_unauth.json()["detail"].lower()

    # Farmer A (actual seller) updates status -> 200 OK
    app.dependency_overrides[get_current_user] = _get_farmer_a
    resp_auth = client.put(f"/api/v1/orders/{order_id}/status", json={"status": "SHIPPED"})
    assert resp_auth.status_code == 200
    assert resp_auth.json()["status"] == "SHIPPED"

    app.dependency_overrides.clear()


def test_order_cancellation_and_atomic_restocking():
    """Validates that only the placing buyer can cancel, and stock is automatically restored."""
    db = SessionLocal()
    farmer_a = db.query(User).filter(User.phone_number == "+919555111111").first()
    buyer_a = db.query(User).filter(User.phone_number == "+919555333333").first()
    buyer_b = db.query(User).filter(User.phone_number == "+919555444444").first()

    prod = Product(
        farmer_id=farmer_a.id,
        name="Ginger Fresh Harvest",
        crop_type="Ginger",
        sector="CROPS",
        quality_grade="A",
        district="Wayanad",
        quantity=5.0,  # 5 kg remaining
        unit="kg",
        price_per_unit=80.0,
        is_active=True,
    )
    db.add(prod)
    db.commit()

    order = Order(
        buyer_id=buyer_a.id,
        farmer_id=farmer_a.id,
        product_id=prod.id,
        product_name="Ginger Fresh Harvest",
        quantity=3.0,
        unit="kg",
        price_per_unit=80.0,
        total_amount=240.0,
        delivery_address="Way 5, Kalpetta",
        status=OrderStatus.PENDING,
    )
    db.add(order)
    db.commit()
    order_id = order.id
    prod_id = prod.id
    buyer_a_id = buyer_a.id
    buyer_b_id = buyer_b.id
    db.close()

    def _get_buyer_a():
        s = SessionLocal()
        return s.query(User).filter(User.id == buyer_a_id).first()

    def _get_buyer_b():
        s = SessionLocal()
        return s.query(User).filter(User.id == buyer_b_id).first()

    # Buyer B tries to cancel Buyer A's order -> 403 Forbidden
    app.dependency_overrides[get_current_user] = _get_buyer_b
    resp_unauth = client.post(f"/api/v1/orders/{order_id}/cancel")
    assert resp_unauth.status_code == 403
    assert "permission" in resp_unauth.json()["detail"].lower() or "buyer" in resp_unauth.json()["detail"].lower()

    # Buyer A cancels order -> 200 OK
    app.dependency_overrides[get_current_user] = _get_buyer_a
    resp_auth = client.post(f"/api/v1/orders/{order_id}/cancel")
    assert resp_auth.status_code == 200
    assert resp_auth.json()["status"] == "CANCELLED"

    # Verify inventory was restocked: 5.0 + 3.0 = 8.0 kg
    db_check = SessionLocal()
    p = db_check.query(Product).filter(Product.id == prod_id).first()
    assert p.quantity == 8.0
    db_check.close()

    # Cancelling again fails with 409 Conflict
    resp_repeat = client.post(f"/api/v1/orders/{order_id}/cancel")
    assert resp_repeat.status_code == 409

    app.dependency_overrides.clear()
