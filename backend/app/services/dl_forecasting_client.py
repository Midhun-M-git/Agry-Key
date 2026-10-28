import time
import os
import sys
from typing import Dict, Any, List
import requests
try:
    import httpx
except ImportError:
    httpx = None
try:
    from app.core.config import settings
    DEFAULT_URL = settings.DL_FORECAST_SERVICE_URL
    DEFAULT_TOKEN = settings.DL_FORECAST_SERVICE_TOKEN
except Exception:
    DEFAULT_URL = os.getenv("DL_FORECAST_SERVICE_URL", "")
    DEFAULT_TOKEN = os.getenv("DL_FORECAST_SERVICE_TOKEN", "")

# Attempt to load the local forecasting model directly to eliminate external 404s/timeouts
try:
    microservice_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "dl_microservice"))
    if microservice_path not in sys.path:
        sys.path.insert(0, microservice_path)
    from model import forecasting_model as local_forecaster
except Exception as _e:
    local_forecaster = None


class DLForecastingClient:
    """
    Client that communicates with the Deep Learning microservice or runs the
    local time-series forecasting model directly with intelligent daily caching.
    """

    def __init__(self):
        self.url = DEFAULT_URL
        self.token = DEFAULT_TOKEN
        self._cache: Dict[str, tuple] = {}
        self.CACHE_TTL_SECONDS = 43200  # 12 hours

    def _get_cache_key(self, district: str, commodity: str) -> str:
        return f"{district.lower().strip()}_{commodity.lower().strip()}"

    def get_price_forecast(self, district: str, commodity: str) -> Dict[str, Any]:
        """
        Fetches the 30-day forecast for a specific commodity in a district.
        """
        cache_key = self._get_cache_key(district, commodity)

        # 1. Check in-memory Cache
        if cache_key in self._cache:
            timestamp, cached_data = self._cache[cache_key]
            if (time.time() - timestamp) < self.CACHE_TTL_SECONDS:
                return cached_data

        # 2. Remote Deep Learning microservice call (if configured)
        if self.url:
            try:
                headers = {
                    "Authorization": f"Bearer {self.token}",
                    "Content-Type": "application/json",
                }
                response = requests.post(
                    self.url,
                    json={"district": district, "commodity": commodity},
                    headers=headers,
                    timeout=2.0,
                )
                if response.status_code == 200:
                    data = response.json()
                    self._cache[cache_key] = (time.time(), data)
                    return data
            except requests.exceptions.Timeout:
                return self._fallback_forecast(commodity, district)
            except Exception:
                pass

        # 3. Direct local model execution (zero latency, zero network dropouts)
        if local_forecaster:
            try:
                prediction = local_forecaster.predict(district=district, commodity=commodity)
                self._cache[cache_key] = (time.time(), prediction)
                return prediction
            except Exception as e:
                print(f"[DL-Client] Local prediction error: {e}")

        # 4. Built-in agricultural seasonal price forecaster
        return self._compute_seasonal_forecast(district, commodity)

    def _fallback_forecast(self, commodity: str, district: str = "") -> Dict[str, Any]:
        """Fail closed when inference engine is unavailable."""
        return {
            "status": "unavailable",
            "reason": "Insufficient historical data for accurate forecasting",
            "commodity": commodity,
            "district": district,
            "horizon_days": 30,
        }

    def _compute_seasonal_forecast(self, district: str, commodity: str) -> Dict[str, Any]:
        """Returns unavailable rather than generating synthetic seasonal forecasts."""
        return {
            "status": "unavailable",
            "reason": "Insufficient historical data for accurate forecasting",
            "commodity": commodity,
            "district": district,
            "horizon_days": 30,
        }


dl_forecasting_client = DLForecastingClient()
