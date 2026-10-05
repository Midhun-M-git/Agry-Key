"""Unit tests for Razorpay payments, invoice generation, multi-sector marketplace, and admin status."""

from datetime import datetime, timezone
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models.marketplace import Product
from app.models.order import Order, OrderStatus
from app.models.payment import Payment
from app.models.user import User, FarmerProfile, UserRole
from app.routers.auth import get_current_user

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_test_entities():
    db = SessionLocal()
    # 1. Farmer user
    farmer = db.query(User).filter(User.phone_number == "+919111111111").first()
    if not farmer:
        farmer = User(
            phone_number="+919111111111",
            full_name="Kerala Spices Producer",
            role=UserRole.FARMER,
        )
        db.add(farmer)
        db.commit()
        db.refresh(farmer)
        fp = FarmerProfile(user_id=farmer.id, state="Kerala", district="Palakkad")
        db.add(fp)
        db.commit()

    # 2. Buyer user
    buyer = db.query(User).filter(User.phone_number == "+919222222222").first()
    if not buyer:
        buyer = User(
            phone_number="+919222222222",
            full_name="Kochi Organic Supermarket",
            role=UserRole.BUYER,
        )
        db.add(buyer)
        db.commit()
        db.refresh(buyer)

    # 3. Admin user
    admin = db.query(User).filter(User.phone_number == "+919333333333").first()
    if not admin:
        admin = User(
            phone_number="+919333333333",
            full_name="Platform Overseer",
            role=UserRole.ADMIN,
        )
        db.add(admin)
        db.commit()
        db.refresh(admin)

    # 4. Multi-sector product
    product = db.query(Product).filter(Product.name == "Highland Black Pepper").first()
    if not product:
        product = Product(
            farmer_id=farmer.id,
            name="Highland Black Pepper",
            crop_type="Black Pepper",
            sector="CROPS",
            quality_grade="A",
            district="Palakkad",
            quantity=100.0,
            unit="kg",
            price_per_unit=650.0,
            is_active=True,
        )
        db.add(product)
        db.commit()
        db.refresh(product)

    # 5. Order
    order = db.query(Order).filter(Order.product_name == "Highland Black Pepper").first()
    if not order:
        order = Order(
            buyer_id=buyer.id,
            farmer_id=farmer.id,
            product_id=product.id,
            product_name="Highland Black Pepper",
            quantity=10.0,
            unit="kg",
            price_per_unit=650.0,
            total_amount=6500.0,
            delivery_address="Main Market Road, Kochi, Kerala",
            status=OrderStatus.PENDING,
        )
        db.add(order)
        db.commit()
        db.refresh(order)

    db.close()
    yield


def test_payment_flow_and_order_confirmation():
    db = SessionLocal()
    buyer = db.query(User).filter(User.phone_number == "+919222222222").first()
    buyer_id = buyer.id
    order = db.query(Order).filter(Order.product_name == "Highland Black Pepper").first()
    order_id = None
    if order:
        order_id = order.id
        db.query(Payment).filter(Payment.order_id == order.id).delete()
        order.status = OrderStatus.PENDING
        db.commit()
    db.close()

    def _get_test_buyer():
        s = SessionLocal()
        return s.query(User).filter(User.id == buyer_id).first()

    app.dependency_overrides[get_current_user] = _get_test_buyer

    # 1. Create payment order
    create_resp = client.post(
        "/api/v1/payment/create-order",
        json={"order_id": order_id},
    )
    assert create_resp.status_code == 200
    p_data = create_resp.json()
    assert p_data["order_id"] == order_id
    assert p_data["amount"] == 6500.0
    rzp_order_id = p_data["razorpay_order_id"]

    # 2. Verify payment with valid mock signature
    verify_resp = client.post(
        "/api/v1/payment/verify",
        json={
            "razorpay_order_id": rzp_order_id,
            "razorpay_payment_id": f"pay_mock_{order_id}",
            "razorpay_signature": "mock_sig_valid_12345",
        },
    )
    assert verify_resp.status_code == 200
    v_data = verify_resp.json()
    assert v_data["status"] == "SUCCESS"
    assert v_data["order_status"] == "CONFIRMED"

    # 3. Check payment status retrieval
    get_pay = client.get(f"/api/v1/payment/order/{order_id}")
    assert get_pay.status_code == 200
    assert get_pay.json()["status"] == "SUCCESS"
    app.dependency_overrides.clear()


def test_invoice_pdf_download():
    db = SessionLocal()
    buyer = db.query(User).filter(User.phone_number == "+919222222222").first()
    buyer_id = buyer.id
    order = db.query(Order).filter(Order.product_name == "Highland Black Pepper").first()
    order_id = order.id
    db.close()

    def _get_test_buyer():
        s = SessionLocal()
        return s.query(User).filter(User.id == buyer_id).first()

    app.dependency_overrides[get_current_user] = _get_test_buyer

    resp = client.get(f"/api/v1/orders/{order_id}/invoice")
    app.dependency_overrides.clear()

    assert resp.status_code == 200
    assert resp.headers["content-type"] == "application/pdf"
    assert resp.content.startswith(b"%PDF")
    assert len(resp.content) > 1000  # Valid ReportLab binary document


def test_multi_sector_marketplace_listings():
    db = SessionLocal()
    farmer = db.query(User).filter(User.phone_number == "+919111111111").first()
    db.close()

    app.dependency_overrides[get_current_user] = lambda: farmer

    # Create an aquaculture listing via /listings
    resp = client.post(
        "/api/v1/marketplace/listings",
        json={
            "name": "Fresh Freshwater Tilapia",
            "crop_type": "Tilapia Fish",
            "sector": "AQUACULTURE",
            "quality_grade": "A",
            "district": "Palakkad",
            "quantity": 80.0,
            "unit": "kg",
            "price_per_unit": 220.0,
            "description": "Harvested fresh from Palakkad reservoir aquaculture unit.",
        },
    )
    app.dependency_overrides.clear()
    assert resp.status_code == 201
    prod = resp.json()
    assert prod["sector"] == "AQUACULTURE"
    assert prod["quality_grade"] == "A"
    assert prod["expires_at"] is not None  # Auto-calculated for perishable sector

    # Filter listings by sector
    list_resp = client.get("/api/v1/marketplace/listings?sector=AQUACULTURE")
    assert list_resp.status_code == 200
    items = list_resp.json()
    assert len(items) >= 1
    assert all(i["sector"] == "AQUACULTURE" for i in items)


def test_admin_status_endpoint():
    db = SessionLocal()
    admin = db.query(User).filter(User.phone_number == "+919333333333").first()
    farmer = db.query(User).filter(User.phone_number == "+919111111111").first()
    db.close()

    # Unauthorized for farmer
    app.dependency_overrides[get_current_user] = lambda: farmer
    resp_unauth = client.get("/api/v1/admin/status")
    assert resp_unauth.status_code == 403

    # Authorized for admin
    app.dependency_overrides[get_current_user] = lambda: admin
    resp = client.get("/api/v1/admin/status")
    app.dependency_overrides.clear()

    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "HEALTHY"
    metrics = data["metrics"]
    assert metrics["total_registered_users"] >= 3
    assert metrics["blockchain_block_height"] >= 1
    assert metrics["supported_districts_count"] == 11
