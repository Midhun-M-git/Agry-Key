"""Government agriculture schemes API routes and seed loader."""

import json
from pathlib import Path
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.scheme import Scheme
from app.schemas.scheme import SchemeResponse

router = APIRouter(prefix="/schemes", tags=["Government Schemes"])
_SEED_FILE = Path(__file__).parents[1] / "data" / "schemes_seed.json"


def seed_schemes(db: Session) -> int:
    """Insert bundled schemes once and return the number of new records."""
    with _SEED_FILE.open("r", encoding="utf-8") as seed_file:
        seed_records = json.load(seed_file)

    inserted = 0
    for record in seed_records:
        if db.query(Scheme).filter(Scheme.code == record["code"]).first():
            continue
        db.add(Scheme(**record))
        inserted += 1
    if inserted:
        db.commit()
    return inserted


@router.get("", response_model=list[SchemeResponse])
def list_schemes(
    state: Optional[str] = Query(default=None),
    category: Optional[str] = Query(default=None),
    sector: Optional[str] = Query(default=None),
    db: Session = Depends(get_db),
):
    """List active schemes, optionally filtered by state, category, and sector."""
    query = db.query(Scheme).filter(Scheme.is_active.is_(True))
    if state:
        state_filter = state.strip()
        query = query.filter(
            (Scheme.state.is_(None)) | (Scheme.state.ilike(state_filter))
        )
    if category:
        query = query.filter(Scheme.category.ilike(category.strip()))
    if sector:
        query = query.filter(Scheme.sector.ilike(sector.strip()))
    return query.order_by(Scheme.level, Scheme.name).all()


@router.get("/{scheme_id}", response_model=SchemeResponse)
def get_scheme(scheme_id: int, db: Session = Depends(get_db)):
    """Return eligibility, benefits, documents, and application steps for a scheme."""
    scheme = (
        db.query(Scheme)
        .filter(Scheme.id == scheme_id, Scheme.is_active.is_(True))
        .first()
    )
    if not scheme:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Government scheme not found",
        )
    return scheme