from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.marketplace import Product
from app.models.user import User, UserRole
from app.routers.auth import get_current_user
from app.schemas.marketplace import ProductCreate, ProductResponse, ProductUpdate

router = APIRouter(prefix="/marketplace", tags=["Marketplace"])

_SECTOR_EXPIRY_DAYS = {
    "AQUACULTURE": 2,
    "FISH": 2,
    "DAIRY": 2,
    "MILK": 2,
    "LIVESTOCK": 3,
    "MEAT": 3,
    "POULTRY": 7,
    "EGGS": 7,
    "CROPS": 30,
}



def _require_farmer(current_user: User) -> None:
    if current_user.role != UserRole.FARMER:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only farmers can manage product listings",
        )


def _get_owned_product(product_id: int, current_user: User, db: Session) -> Product:
    product = (
        db.query(Product)
        .filter(Product.id == product_id, Product.farmer_id == current_user.id)
        .first()
    )
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product listing not found",
        )
    return product


def _to_response(product: Product, db: Session) -> ProductResponse:
    farmer = db.query(User).filter(User.id == product.farmer_id).first()
    return ProductResponse(
        **{
            column.name: getattr(product, column.name)
            for column in Product.__table__.columns
            if column.name != "farmer_id"
        },
        farmer_id=product.farmer_id,
        farmer_name=farmer.full_name if farmer else None,
    )


@router.post("/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
@router.post("/listings", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    req: ProductCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a produce listing owned by the authenticated farmer."""
    _require_farmer(current_user)
    data = req.model_dump()
    if not data.get("expires_at"):
        sec = data.get("sector", "CROPS").upper()
        days = _SECTOR_EXPIRY_DAYS.get(sec, 14)
        data["expires_at"] = datetime.now(timezone.utc) + timedelta(days=days)

    product = Product(farmer_id=current_user.id, **data)
    db.add(product)
    db.commit()
    db.refresh(product)
    return _to_response(product, db)


@router.get("/products", response_model=list[ProductResponse])
@router.get("/listings", response_model=list[ProductResponse])
def list_products(
    district: Optional[str] = Query(default=None),
    crop_type: Optional[str] = Query(default=None),
    sector: Optional[str] = Query(default=None),
    quality_grade: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    """Browse active product listings, optionally filtered by district, crop, sector, and grade."""
    now = datetime.now(timezone.utc)
    query = db.query(Product).filter(
        Product.is_active.is_(True),
        (Product.expires_at.is_(None)) | (Product.expires_at >= now),
    )
    if district:
        query = query.filter(Product.district.ilike(district.strip()))
    if crop_type:
        query = query.filter(Product.crop_type.ilike(crop_type.strip()))
    if sector:
        query = query.filter(Product.sector.ilike(sector.strip()))
    if quality_grade:
        query = query.filter(Product.quality_grade.ilike(quality_grade.strip()))
    products = query.order_by(Product.created_at.desc()).all()
    return [_to_response(product, db) for product in products]


@router.get("/my-listings", response_model=list[ProductResponse])
def get_my_listings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List all active product listings owned by the logged-in farmer."""
    _require_farmer(current_user)
    products = db.query(Product).filter(
        Product.farmer_id == current_user.id,
        Product.is_active.is_(True),
    ).order_by(Product.created_at.desc()).all()
    return [_to_response(product, db) for product in products]


@router.get("/products/{product_id}", response_model=ProductResponse)
@router.get("/listings/{product_id}", response_model=ProductResponse)

def get_product(product_id: int, db: Session = Depends(get_db)):
    """Return one active product listing."""
    product = (
        db.query(Product)
        .filter(Product.id == product_id, Product.is_active.is_(True))
        .first()
    )
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product listing not found")
    return _to_response(product, db)


@router.put("/products/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    req: ProductUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update an active product listing owned by the authenticated farmer."""
    _require_farmer(current_user)
    product = _get_owned_product(product_id, current_user, db)
    if not product.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product listing not found")
    for field, value in req.model_dump(exclude_unset=True).items():
        setattr(product, field, value)
    db.commit()
    db.refresh(product)
    return _to_response(product, db)


@router.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Remove a listing from the marketplace without deleting its audit record."""
    _require_farmer(current_user)
    product = _get_owned_product(product_id, current_user, db)
    product.is_active = False
    db.commit()