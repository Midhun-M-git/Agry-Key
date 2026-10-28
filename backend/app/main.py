from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.middleware.rate_limit import RateLimitMiddleware
from app.routers import (
    admin,
    advisory,
    auth,
    blockchain,
    community,
    geo,
    health,
    i18n,
    marketplace,
    market,
    notifications,
    onboarding,
    orders,
    payment,
    schemes,
    services,
    soil,
    weather,
)

from app.core.database import Base, engine, SessionLocal
from app.routers.schemes import seed_schemes


@asynccontextmanager
async def lifespan(_app: FastAPI):
    db = SessionLocal()
    try:
        # Production Lockdown: Fail-closed if demo seed data or demo users are detected in production
        if str(settings.ENVIRONMENT).lower() == "production":
            import logging
            import sys
            from sqlalchemy import text, inspect
            logger = logging.getLogger("app.main")
            inspector = inspect(engine)
            table_names = inspector.get_table_names()

            for table_name in table_names:
                columns = [c["name"] for c in inspector.get_columns(table_name)]
                if "source_id" in columns:
                    count = db.execute(
                        text(f"SELECT COUNT(*) FROM {table_name} WHERE source_id = 'demo_seed'")
                    ).scalar() or 0
                    if count > 0:
                        logger.critical(
                            f"CRITICAL: Production startup aborted! Table '{table_name}' contains {count} demo_seed rows. "
                            "Production environment must not boot with demo data in the database."
                        )
                        sys.exit(1)

            # Check demo users and orders backstop
            if "users" in table_names:
                demo_users_count = db.execute(
                    text("SELECT COUNT(*) FROM users WHERE phone_number IN ('+919876543210', '+919876543220') "
                         "OR full_name IN ('Ravi Kumar', 'Organic Green Mart')")
                ).scalar() or 0
                if demo_users_count > 0:
                    logger.critical(
                        f"CRITICAL: Production startup aborted! 'users' table contains {demo_users_count} known demo user accounts. "
                        "Production environment must not boot with demo accounts."
                    )
                    sys.exit(1)

        seed_schemes(db)
        yield
    finally:
        db.close()


app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
)

origins = (
    settings.CORS_ORIGINS
    if isinstance(settings.CORS_ORIGINS, list)
    else [settings.CORS_ORIGINS]
)
is_wildcard = origins == ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=not is_wildcard,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(RateLimitMiddleware, max_requests=120, window_seconds=60)

# Include Routers
app.include_router(health.router, prefix=settings.API_V1_STR)
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(auth.router, prefix="/api")  # Supports /api/auth/request-otp and /api/auth/verify-otp
app.include_router(geo.router, prefix=settings.API_V1_STR)
app.include_router(i18n.router, prefix=settings.API_V1_STR)
app.include_router(onboarding.router, prefix=settings.API_V1_STR)
app.include_router(advisory.router, prefix=f"{settings.API_V1_STR}/advisory", tags=["advisory"])
app.include_router(weather.router, prefix=settings.API_V1_STR)
app.include_router(marketplace.router, prefix=settings.API_V1_STR)
app.include_router(market.router, prefix=settings.API_V1_STR)
app.include_router(orders.router, prefix=settings.API_V1_STR)
app.include_router(payment.router, prefix=settings.API_V1_STR)
app.include_router(blockchain.router, prefix=settings.API_V1_STR)
app.include_router(admin.router, prefix=settings.API_V1_STR)
app.include_router(schemes.router, prefix=settings.API_V1_STR)
app.include_router(notifications.router, prefix=settings.API_V1_STR)
app.include_router(community.router, prefix=settings.API_V1_STR)
app.include_router(soil.router, prefix=settings.API_V1_STR)
app.include_router(services.router, prefix=settings.API_V1_STR)

# Backward-compatible alias mounts without /api/v1 prefix
app.include_router(community.router)
app.include_router(market.router)
app.include_router(marketplace.router)
app.include_router(orders.router)
app.include_router(soil.router)



@app.get("/")
def root():
    return {
        "name": settings.PROJECT_NAME,
        "docs": "/docs",
        "health": f"{settings.API_V1_STR}/health",
    }


@app.exception_handler(Exception)
async def unhandled_exception_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


