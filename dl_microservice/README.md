---
title: Agry-Key DL Price Forecasting
emoji: 
colorFrom: green
colorTo: blue
sdk: docker
app_port: 7860
pinned: false
---

# Agry-Key DL Price Forecasting Microservice

Autonomous time-series agricultural price forecasting engine powered by FastAPI and Agmarknet historical trend modeling.

## API Endpoint

- `POST /api/predict`
  - Headers: `Authorization: Bearer <DL_SERVICE_TOKEN>`
  - Body: `{"district": "Palakkad", "commodity": "Paddy"}`
  - Returns: `{"commodity": "Paddy", "predicted_trend_30_days": "UP", "confidence_score": 0.92, ...}`
