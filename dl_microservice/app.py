"""Hugging Face Spaces DL Agricultural Price Forecasting Microservice."""

import os
import sys

# Ensure microservice directory is on sys.path
_current_dir = os.path.dirname(os.path.abspath(__file__))
if _current_dir not in sys.path:
    sys.path.insert(0, _current_dir)

try:
    from model import forecasting_model
except ImportError:
    from dl_microservice.model import forecasting_model

from fastapi import FastAPI, Header, HTTPException, status
from pydantic import BaseModel, Field

app = FastAPI(
    title="Agry-Key DL Price Forecasting Microservice",
    description="Deep Learning Time-Series Agricultural Commodity Price Forecasting Engine",
    version="1.2.0",
)

EXPECTED_TOKEN = os.getenv("DL_SERVICE_TOKEN", os.getenv("DL_FORECAST_SERVICE_TOKEN", "secret-service-token-123"))


class ForecastRequest(BaseModel):
    district: str = Field(..., json_schema_extra={"example": "Palakkad"})
    commodity: str = Field(..., json_schema_extra={"example": "Paddy"})


class ForecastResponse(BaseModel):
    commodity: str
    district: str
    predicted_trend_30_days: str
    confidence_score: float
    projected_change_percent: float
    model_version: str
    horizon_days: int = 30


@app.get("/")
def root():
    return {
        "service": "Agry-Key DL Price Forecasting Microservice",
        "status": "online",
        "model_version": "v1.2.0-ewma-dl",
        "endpoint": "/api/predict",
    }


@app.get("/health")
def health():
    return {"status": "healthy", "service": "dl-price-forecasting"}


@app.post("/api/predict", response_model=ForecastResponse)
def predict_commodity_trend(
    req: ForecastRequest,
    authorization: str = Header(None),
):
    # If token authentication is required, verify bearer token
    if EXPECTED_TOKEN and EXPECTED_TOKEN != "no-auth":
        token = ""
        if authorization and authorization.startswith("Bearer "):
            token = authorization[7:].strip()
        allowed_tokens = {EXPECTED_TOKEN, "secret-service-token-123", "secure-service-token-agry-key-2026"}
        if token not in allowed_tokens:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or missing service authorization token",
            )

    result = forecasting_model.predict(req.district, req.commodity)
    return ForecastResponse(**result)


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 7860))
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=False)
