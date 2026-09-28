"""Admin operations and system status monitoring router."""

from datetime import datetime, timezone
from typing import Any, Dict
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.regions import district_registry
from app.models.blockchain import BlockchainLedgerBlock, VerifiedProduceStock
from app.models.marketplace import Product
from app.models.order import Order, OrderStatus
from app.models.user import FarmerProfile, User, UserRole
from app.routers.auth import get_current_user

router = APIRouter(prefix="/admin", tags=["Admin Operations"])


def _require_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required to access operational status.",
        )
    return current_user


@router.get("/status")
def get_admin_status(
    admin_user: User = Depends(_require_admin),
    db: Session = Depends(get_db),
) -> Dict[str, Any]:
    """Returns operational metrics and health overview across the Agry-Key platform."""
    total_users = db.query(func.count(User.id)).scalar() or 0
    total_farmers = db.query(func.count(FarmerProfile.id)).scalar() or 0
    active_listings = db.query(func.count(Product.id)).filter(Product.is_active.is_(True)).scalar() or 0
    total_orders = db.query(func.count(Order.id)).scalar() or 0
    total_revenue = db.query(func.sum(Order.total_amount)).filter(Order.status == OrderStatus.DELIVERED).scalar() or 0.0

    blockchain_blocks = db.query(func.count(BlockchainLedgerBlock.block_index)).scalar() or 0
    verified_produce_count = db.query(func.count(VerifiedProduceStock.id)).scalar() or 0
    supported_districts = district_registry.list_supported_districts()

    return {
        "status": "HEALTHY",
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "metrics": {
            "total_registered_users": total_users,
            "total_farmer_profiles": total_farmers,
            "active_marketplace_listings": active_listings,
            "total_orders": total_orders,
            "fulfilled_gross_merchandise_value_inr": round(float(total_revenue), 2),
            "blockchain_block_height": blockchain_blocks,
            "verified_produce_batches": verified_produce_count,
            "supported_districts_count": len(supported_districts),
            "supported_districts": supported_districts,
        },
    }
