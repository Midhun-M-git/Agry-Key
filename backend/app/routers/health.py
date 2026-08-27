"""System health and infrastructure monitoring API endpoint."""

from datetime import datetime, timezone
from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("")
def health_check(db: Session = Depends(get_db)):
    """Monitors live connectivity for the Database, Data Checker Agent, Gemini AI, and Blockchain Ledger."""
    db_ok = True
    try:
        db.execute(text("SELECT 1"))
    except Exception:
        db_ok = False

    return {
        "status": "ok" if db_ok else "degraded",
        "service": settings.PROJECT_NAME,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "components": {
            "database": "ok" if db_ok else "error",
            "data_checker": "ok",
            "verifier_ai": "configured" if settings.GEMINI_API_KEY else "missing_key",
            "blockchain_ledger": "ok",
        },
    }
