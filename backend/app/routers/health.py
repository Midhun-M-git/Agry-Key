"""System health and infrastructure monitoring API endpoints."""

from datetime import datetime, timezone
import logging
from typing import Optional
from fastapi import APIRouter, Depends, status
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/health", tags=["Health"])

SEEDED_PROVENANCE_TABLES = [
    "users",
    "marketplace_products",
    "orders",
    "payments",
    "market_price_trends",
]

KNOWN_DEMO_PHONES = [
    "+919876543210",
    "+919876543220",
    "+919876543218",
    "9876543210",
    "9876543220",
    "9876543218",
]

KNOWN_DEMO_EMAILS = [
    "farmer@example.com",
    "buyer@example.com",
    "demo@agrikey.com",
]

_startup_lockdown_error: Optional[str] = None
_provenance_verified_at_startup: bool = False


def verify_startup_provenance(db: Session, force: bool = False) -> Optional[str]:
    """Verify database provenance once at startup and cache the result."""
    global _startup_lockdown_error, _provenance_verified_at_startup
    if _provenance_verified_at_startup and not force:
        return _startup_lockdown_error

    if not getattr(settings, "is_deployed", False):
        _startup_lockdown_error = None
        _provenance_verified_at_startup = True
        return None

    # 1. Multi-table demo_seed provenance check
    for tbl in SEEDED_PROVENANCE_TABLES:
        try:
            count = db.execute(
                text(f"SELECT COUNT(*) FROM {tbl} WHERE source_id = 'demo_seed'")
            ).scalar() or 0
            if count > 0:
                msg = f"Readiness lockdown: Table '{tbl}' contains {count} demo_seed rows."
                logger.critical(msg)
                _startup_lockdown_error = msg
                _provenance_verified_at_startup = True
                return msg
        except Exception as e:
            logger.warning(f"Could not inspect provenance on {tbl}: {e}")

    # 2. Known demo credentials backstop
    try:
        placeholders = ", ".join(f":p{i}" for i in range(len(KNOWN_DEMO_PHONES)))
        params = {f"p{i}": p for i, p in enumerate(KNOWN_DEMO_PHONES)}
        demo_phone_count = db.execute(
            text(f"SELECT COUNT(*) FROM users WHERE phone_number IN ({placeholders})"),
            params,
        ).scalar() or 0
        if demo_phone_count > 0:
            msg = f"Readiness lockdown: Database contains {demo_phone_count} demo user accounts."
            logger.critical(msg)
            _startup_lockdown_error = msg
            _provenance_verified_at_startup = True
            return msg
    except Exception as e:
        logger.warning(f"Could not inspect demo phone backstop: {e}")

    _startup_lockdown_error = None
    _provenance_verified_at_startup = True
    return None


@router.get("/liveness")
def liveness_check():
    """Liveness probe confirming the server process is responsive."""
    return {
        "status": "alive",
        "service": settings.PROJECT_NAME,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@router.get("/readiness")
def readiness_check(db: Session = Depends(get_db)):
    """Readiness probe verifying operational database connectivity with fast cached provenance."""
    try:
        db.execute(text("SELECT 1"))
        if getattr(settings, "is_deployed", False):
            if not _provenance_verified_at_startup:
                verify_startup_provenance(db)
            if _startup_lockdown_error:
                return JSONResponse(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    content={
                        "status": "not_ready",
                        "service": settings.PROJECT_NAME,
                        "timestamp": datetime.now(timezone.utc).isoformat(),
                        "error": _startup_lockdown_error,
                    },
                )

        return {
            "status": "ready",
            "service": settings.PROJECT_NAME,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "database": "connected",
        }
    except Exception as exc:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "not_ready",
                "service": settings.PROJECT_NAME,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "error": "Database connection failed",
                "detail": str(exc),
            },
        )


@router.get("")
def health_check(db: Session = Depends(get_db)):
    """Comprehensive health check for Database and core backend components.
    Constant/fabricated statuses removed; only reflects verifiable real checks."""
    db_ok = True
    db_err = None
    try:
        db.execute(text("SELECT 1"))
    except Exception as exc:
        db_ok = False
        db_err = str(exc)

    resp_data = {
        "status": "ok" if db_ok else "degraded",
        "service": settings.PROJECT_NAME,
        "environment": getattr(settings, "ENVIRONMENT", "development"),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "components": {
            "database": "ok" if db_ok else "error",
        },
    }
    if not db_ok:
        resp_data["database_error"] = db_err
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content=resp_data,
        )

    return resp_data
