"""Razorpay payment gateway integration router."""

from datetime import datetime, timezone
import hashlib
import hmac
from typing import Optional
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
import razorpay
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models.order import Order, OrderStatus
from app.models.payment import Payment, PaymentStatus
from app.models.user import User, UserRole
from app.routers.auth import get_current_user
from app.schemas.payment import (
    PaymentCreateOrderRequest,
    PaymentCreateOrderResponse,
    PaymentResponse,
    PaymentVerifyRequest,
    PaymentVerifyResponse,
)
from app.services.blockchain_service import BlockchainService

router = APIRouter(prefix="/payment", tags=["Payments"])


def _get_razorpay_client() -> Optional[razorpay.Client]:
    if (
        settings.RAZORPAY_KEY_ID
        and settings.RAZORPAY_KEY_SECRET
        and not settings.RAZORPAY_KEY_ID.startswith("rzp_test_placeholder")
    ):
        return razorpay.Client(
            auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
        )
    return None


@router.post("/create-order", response_model=PaymentCreateOrderResponse)
def create_payment_order(
    req: PaymentCreateOrderRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Creates a Razorpay gateway order for an existing pending order."""
    order = db.query(Order).filter(Order.id == req.order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

    if order.buyer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only initiate payment for your own orders.",
        )

    # Check if already paid
    existing_paid = (
        db.query(Payment)
        .filter(Payment.order_id == order.id, Payment.status == PaymentStatus.SUCCESS)
        .first()
    )
    if existing_paid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Order has already been paid and confirmed.",
        )

    amount_in_paise = int(round(float(order.total_amount) * 100))
    client = _get_razorpay_client()

    if client:
        try:
            rzp_order = client.order.create(
                {
                    "amount": amount_in_paise,
                    "currency": "INR",
                    "receipt": f"order_rcpt_{order.id}",
                    "notes": {
                        "order_id": str(order.id),
                        "buyer_id": str(current_user.id),
                    },
                }
            )
            razorpay_order_id = rzp_order["id"]
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail=f"Razorpay order creation failed: {str(e)}",
            )
    else:
        # Check if mock payments are explicitly allowed in non-production
        is_prod = getattr(settings, "is_deployed", False)
        allow_mock = getattr(settings, "ALLOW_MOCK_PAYMENT", False)
        if is_prod or not allow_mock:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Live payment gateway credentials are not configured. Mock payment is disabled in production.",
            )
        # Sandbox / Mock fallback when explicitly allowed in development/testing
        razorpay_order_id = f"order_mock_{uuid.uuid4().hex[:14]}"

    payment_record = Payment(
        order_id=order.id,
        buyer_id=current_user.id,
        razorpay_order_id=razorpay_order_id,
        amount=order.total_amount,
        currency="INR",
        status=PaymentStatus.PENDING,
    )
    db.add(payment_record)
    db.commit()
    db.refresh(payment_record)

    return PaymentCreateOrderResponse(
        payment_id=payment_record.id,
        order_id=order.id,
        razorpay_order_id=razorpay_order_id,
        amount=order.total_amount,
        currency="INR",
        razorpay_key_id=settings.RAZORPAY_KEY_ID or "rzp_test_placeholder",
    )


@router.post("/verify", response_model=PaymentVerifyResponse)
def verify_payment(
    req: PaymentVerifyRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Verifies Razorpay payment signature and updates order status to CONFIRMED."""
    payment = (
        db.query(Payment)
        .filter(Payment.razorpay_order_id == req.razorpay_order_id)
        .first()
    )
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment record with given razorpay_order_id not found",
        )

    # Enforce ownership: only the buyer who initiated the order/payment or admin can verify
    if payment.buyer_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are only authorized to verify payments for your own orders.",
        )

    order = db.query(Order).filter(Order.id == payment.order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Associated order not found")

    # Reject invalid state transitions
    if order.status == OrderStatus.CANCELLED:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Cannot verify payment for a cancelled order.",
        )

    # Idempotent confirmation: if already successfully verified, return authoritative success
    if payment.status == PaymentStatus.SUCCESS and order.status == OrderStatus.CONFIRMED:
        return PaymentVerifyResponse(
            status="SUCCESS",
            message="Payment has already been confirmed.",
            payment_id=payment.id,
            order_id=order.id,
            order_status=order.status.value,
        )

    client = _get_razorpay_client()
    is_valid = False

    if client:
        try:
            client.utility.verify_payment_signature(
                {
                    "razorpay_order_id": req.razorpay_order_id,
                    "razorpay_payment_id": req.razorpay_payment_id,
                    "razorpay_signature": req.razorpay_signature,
                }
            )
            is_valid = True
        except razorpay.errors.SignatureVerificationError:
            is_valid = False
    else:
        is_prod = getattr(settings, "is_deployed", False)
        allow_mock = getattr(settings, "ALLOW_MOCK_PAYMENT", False)
        if is_prod or not allow_mock:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Live payment gateway credentials missing. Mock payment verification is disallowed.",
            )
        # Sandbox / Mock verification logic
        generated = hmac.new(
            (settings.RAZORPAY_KEY_SECRET or "secret").encode("utf-8"),
            f"{req.razorpay_order_id}|{req.razorpay_payment_id}".encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()
        is_valid = (
            (req.razorpay_signature == generated)
            or (allow_mock and (req.razorpay_signature.startswith("mock_sig_") or req.razorpay_signature.startswith("sig_verified_")))
        )

    if not is_valid:
        payment.status = PaymentStatus.FAILED
        payment.error_description = "Invalid payment signature"
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment signature verification failed",
        )

    # Mark payment successful
    payment.status = PaymentStatus.SUCCESS
    payment.razorpay_payment_id = req.razorpay_payment_id
    payment.razorpay_signature = req.razorpay_signature
    order.status = OrderStatus.CONFIRMED
    order.confirmed_at = datetime.now(timezone.utc)
    db.commit()

    # Append blockchain ledger block for payment confirmation
    BlockchainService.append_ledger_block(
        db=db,
        transaction_type="ORDER_PAYMENT_CONFIRMED",
        data_payload={
            "order_id": order.id,
            "payment_id": payment.id,
            "razorpay_payment_id": req.razorpay_payment_id,
            "amount": payment.amount,
            "buyer_id": current_user.id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        },
    )

    return PaymentVerifyResponse(
        status="SUCCESS",
        message="Payment verified and order confirmed successfully.",
        payment_id=payment.id,
        order_id=order.id,
        order_status=order.status.value,
    )


class CODConfirmRequest(BaseModel):
    order_id: int = Field(..., description="Order ID to confirm via Cash on Delivery")


@router.post("/confirm-cod", response_model=PaymentResponse)
def confirm_cod_payment(
    req: CODConfirmRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Authoritatively confirms a pending buyer order using Cash on Delivery (COD)."""
    order = db.query(Order).filter(Order.id == req.order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

    if order.buyer_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only confirm Cash on Delivery for your own orders.",
        )

    if order.status != OrderStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Order cannot be confirmed for COD because it is already {order.status.value}.",
        )

    order.status = OrderStatus.CONFIRMED
    order.confirmed_at = datetime.now(timezone.utc)

    # Cash on Delivery: Order is placed/confirmed for delivery, but payment is PENDING until cash is collected
    payment_record = Payment(
        order_id=order.id,
        buyer_id=current_user.id,
        razorpay_order_id=f"cod_{uuid.uuid4().hex[:12]}",
        amount=order.total_amount,
        currency="INR",
        status=PaymentStatus.PENDING,
        razorpay_payment_id="pay_cod_pending_collection",
    )
    db.add(payment_record)
    db.commit()
    db.refresh(payment_record)

    BlockchainService.append_ledger_block(
        db=db,
        transaction_type="ORDER_COD_PLACED",
        data_payload={
            "order_id": order.id,
            "payment_id": payment_record.id,
            "payment_method": "CASH_ON_DELIVERY",
            "amount": float(payment_record.amount),
            "payment_status": payment_record.status.value,
            "buyer_id": current_user.id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        },
    )

    return payment_record


@router.get("/order/{order_id}", response_model=PaymentResponse)
def get_payment_by_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieves the latest payment status for an order with owner-participant authorization."""
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Associated order not found")

    if current_user.role != UserRole.ADMIN and current_user.id not in (order.buyer_id, order.farmer_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. You can only view payments for orders you participate in.",
        )

    payment = (
        db.query(Payment)
        .filter(Payment.order_id == order_id)
        .order_by(Payment.created_at.desc())
        .first()
    )
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No payment record found for this order",
        )
    return payment
