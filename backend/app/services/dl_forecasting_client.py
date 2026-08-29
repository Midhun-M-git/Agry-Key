import time
import requests
from typing import Dict, Any, List
from app.core.config import settings

class DLForecastingClient:
    """
    A robust client that communicates with the Deep Learning microservice
    hosted on Hugging Face Spaces (or any external DL inference engine).
    
    Includes caching (so we don't spam the DL engine for daily data) and
    fallback mechanisms in case the DL Space is sleeping or offline.
    """

    def __init__(self):
        self.url = settings.DL_FORECAST_SERVICE_URL
        self.headers = {
            "Authorization": f"Bearer {settings.DL_FORECAST_SERVICE_TOKEN}",
            "Content-Type": "application/json"
        }
        # Simple in-memory cache for daily prices: { "district_commodity": (timestamp, data) }
        self._cache: Dict[str, tuple] = {}
        self.CACHE_TTL_SECONDS = 43200  # 12 hours (Agricultural prices change daily)

    def _get_cache_key(self, district: str, commodity: str) -> str:
        return f"{district.lower()}_{commodity.lower()}"

    def get_price_forecast(self, district: str, commodity: str) -> Dict[str, Any]:
        """
        Fetches the 30-day forecast for a specific commodity in a district.
        """
        cache_key = self._get_cache_key(district, commodity)
        
        # 1. Check Cache
        if cache_key in self._cache:
            timestamp, cached_data = self._cache[cache_key]
            if (time.time() - timestamp) < self.CACHE_TTL_SECONDS:
                print(f"[DL-Client] Returning cached forecast for {commodity} in {district}")
                return cached_data

        # 2. Make Network Request with strict Timeout
        payload = {
            "district": district,
            "commodity": commodity
        }
        
        try:
            print(f"[DL-Client] Hitting DL Microservice for {commodity} in {district}...")
            response = requests.post(
                self.url,
                json=payload,
                headers=self.headers,
                timeout=8.0  # 8 seconds max wait before fallback
            )
            
            if response.status_code == 200:
                data = response.json()
                # 3. Save to Cache
                self._cache[cache_key] = (time.time(), data)
                return data
            else:
                print(f"[DL-Client] Microservice returned {response.status_code}. Using fallback.")
                return self._fallback_forecast(commodity)
                
        except requests.exceptions.Timeout:
            print(f"[DL-Client] Microservice timeout (cold start?). Using fallback.")
            return self._fallback_forecast(commodity)
        except requests.exceptions.RequestException as e:
            print(f"[DL-Client] Connection error: {e}. Using fallback.")
            return self._fallback_forecast(commodity)

    def _fallback_forecast(self, commodity: str) -> Dict[str, Any]:
        """
        Graceful degradation: If the DL engine is offline, we return a 
        neutral 'STABLE' trend so the Advisory Agent can still function.
        """
        return {
            "commodity": commodity,
            "predicted_trend_30_days": "STABLE",
            "confidence_score": 0.50,
            "message": "Fallback heuristics applied due to inference engine timeout."
        }

dl_forecasting_client = DLForecastingClient()
