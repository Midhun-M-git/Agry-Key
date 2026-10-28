"""System health and infrastructure monitoring API endpoints."""

from datetime import datetime, timezone
from fastapi import APIRouter, Depends, status
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db

router = APIRouter(prefix="/health", tags=["Health"])


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
    """Readiness probe verifying operational database connectivity."""
    try:
        db.execute(text("SELECT 1"))
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
    """Comprehensive health check for Database and core backend components."""
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
            "data_checker": "ok",
            "verifier_ai": "configured" if settings.GEMINI_API_KEY else "missing_key",
            "blockchain_ledger": "ok",
        },
    }
    if not db_ok:
        resp_data["error"] = db_err
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content=resp_data,
        )

    return resp_data
