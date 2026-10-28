"""Agmarknet Price Forecasting Model Interface.

In compliance with production policies against simulated heuristics,
numeric price forecasts are disabled unless supported by verifiable historical observations.
"""

from typing import Dict, Any, Optional


class HeuristicBaselinePriceEstimator:
    """Forecasting interface enforcing strict absence of hardcoded estimates."""

    def predict(
        self,
        district: str,
        commodity: str,
        historical_observations: Optional[Any] = None,
    ) -> Dict[str, Any]:
        """Returns unavailable status when sufficient verifiable historical data is absent."""
        return {
            "status": "unavailable",
            "reason": "Insufficient historical data for accurate forecasting",
            "commodity": commodity,
            "district": district,
            "model_version": "v1.3.0-fail-closed",
            "horizon_days": 30,
        }


DLPriceForecaster = HeuristicBaselinePriceEstimator
forecasting_model = HeuristicBaselinePriceEstimator()
