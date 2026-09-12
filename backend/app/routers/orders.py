"""Order placement, fulfillment, cancellation, and tracking routes."""

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.marketplace import Product
from app.models.order import Order, OrderStatus
from app.models.user import User, UserRole
from app.routers.auth import get_current_user
from app.schemas.order import OrderCreate, OrderResponse, OrderStatusUpdate, TrackingEvent

router = APIRouter(prefix="/orders", tags=["Orders"])

_STATUS_SEQUENCE = [
    OrderStatus.PENDING,
    OrderStatus.CONFIRMED,
    OrderStatus.SHIPPED,
    OrderStatus.DELIVERED,
]


def _require_role(current_user: User, role: UserRole) -> None:
    if current_user.role != role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Only {role.value.lower()}s can perform this action",
        )


def _get_order_for_user(order_id: int, current_user: User, db: Session) -> Order:
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order or current_user.id not in (order.buyer_id, order.farmer_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return order


def _tracking(order: Order) -> list[TrackingEvent]:
    timestamps = {
        OrderStatus.PENDING: order.created_at,
        OrderStatus.CONFIRMED: order.confirmed_at,
        OrderStatus.SHIPPED: order.shipped_at,
        OrderStatus.DELIVERED: order.delivered_at,
    }
    if order.status == OrderStatus.CANCELLED:
        return [
            TrackingEvent(status=OrderStatus.PENDING, timestamp=order.created_at, completed=True),
            TrackingEvent(status=OrderStatus.CANCELLED, timestamp=order.cancelled_at, completed=True),
        ]

    current_index = _STATUS_SEQUENCE.index(order.status)
    return [
        TrackingEvent(
            status=tracking_status,
            timestamp=timestamps[tracking_status],
            completed=index <= current_index,
        )
        for index, tracking_status in enumerate(_STATUS_SEQUENCE)
    ]


def _to_response(order: Order, db: Session) -> OrderResponse:
    buyer = db.query(User).filter(User.id == order.buyer_id).first()
    farmer = db.query(User).filter(User.id == order.farmer_id).first()
    return OrderResponse(
        id=order.id,
        buyer_id=order.buyer_id,
        buyer_name=buyer.full_name if buyer else None,
        farmer_id=order.farmer_id,
        farmer_name=farmer.full_name if farmer else None,
        product_id=order.product_id,
        product_name=order.product_name,
        quantity=order.quantity,
        unit=order.unit,
        price_per_unit=order.price_per_unit,
        total_amount=order.total_amount,
        delivery_address=order.delivery_address,
        notes=order.notes,
        status=order.status,
        created_at=order.created_at,
        updated_at=order.updated_at,
        tracking=_tracking(order),
    )


@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    req: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Place an order for an active marketplace product."""
    _require_role(current_user, UserRole.BUYER)
    product = (
        db.query(Product)
        .filter(Product.id == req.product_id, Product.is_active.is_(True))
        .first()
    )
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    if req.quantity > product.quantity:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Insufficient product quantity")

    product.quantity -= req.quantity
    order = Order(
        buyer_id=current_user.id,
        farmer_id=product.farmer_id,
        product_id=product.id,
        product_name=product.name,
        quantity=req.quantity,
        unit=product.unit,
        price_per_unit=product.price_per_unit,
        total_amount=round(req.quantity * product.price_per_unit, 2),
        delivery_address=req.delivery_address,
        notes=req.notes,
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return _to_response(order, db)


@router.get("", response_model=list[OrderResponse])
def list_orders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List orders belonging to the current buyer or farmer."""
    if current_user.role == UserRole.BUYER:
        query = db.query(Order).filter(Order.buyer_id == current_user.id)
    elif current_user.role == UserRole.FARMER:
        query = db.query(Order).filter(Order.farmer_id == current_user.id)
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Unsupported order role")
    orders = query.order_by(Order.created_at.desc()).all()
    return [_to_response(order, db) for order in orders]


@router.get("/{order_id}", response_model=OrderResponse)
def get_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return order details and its fulfillment tracking timeline."""
    return _to_response(_get_order_for_user(order_id, current_user, db), db)


@router.put("/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    req: OrderStatusUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Advance an order through the farmer-controlled fulfillment lifecycle."""
    _require_role(current_user, UserRole.FARMER)
    order = _get_order_for_user(order_id, current_user, db)
    if order.status == OrderStatus.CANCELLED or req.status == OrderStatus.CANCELLED:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Cancelled orders cannot change status")
    if req.status not in _STATUS_SEQUENCE or _STATUS_SEQUENCE.index(req.status) != _STATUS_SEQUENCE.index(order.status) + 1:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Invalid order status transition")

    now = datetime.now(timezone.utc)
    order.status = req.status
    if req.status == OrderStatus.CONFIRMED:
        order.confirmed_at = now
    elif req.status == OrderStatus.SHIPPED:
        order.shipped_at = now
    elif req.status == OrderStatus.DELIVERED:
        order.delivered_at = now
    db.commit()
    db.refresh(order)
    return _to_response(order, db)


@router.post("/{order_id}/cancel", response_model=OrderResponse)
def cancel_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Cancel a pending buyer order and return its quantity to the listing."""
    _require_role(current_user, UserRole.BUYER)
    order = _get_order_for_user(order_id, current_user, db)
    if order.status != OrderStatus.PENDING:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Only pending orders can be cancelled")

    product = db.query(Product).filter(Product.id == order.product_id).first()
    if product:
        product.quantity += order.quantity
    order.status = OrderStatus.CANCELLED
    order.cancelled_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(order)
    return _to_response(order, db)