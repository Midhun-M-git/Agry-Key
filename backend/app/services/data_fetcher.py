import openmeteo_requests
import requests_cache
from retry_requests import retry
from typing import Dict, Any, List

class DataFetcherService:
    """Service to fetch real-time and historical data from official APIs."""

    def __init__(self):
        # Setup the Open-Meteo API client with cache and retry on error
        cache_session = requests_cache.CachedSession('.cache', expire_after=3600)
        retry_session = retry(cache_session, retries=5, backoff_factor=0.2)
        self.openmeteo = openmeteo_requests.Client(session=retry_session)
        self.climate_url = "https://historical-forecast-api.open-meteo.com/v1/forecast"

    def fetch_climate_baseline(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Fetches typical climate data (temp, rain) for the given coordinates."""
        # Note: In a full production app, this would query the historical archive
        # for a 20-year baseline. For this implementation, we use the free forecast API
        # as a proxy for current seasonal conditions.
        
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "daily": ["temperature_2m_max", "temperature_2m_min", "precipitation_sum"],
            "timezone": "auto",
            "past_days": 30,
            "forecast_days": 14
        }
        
        try:
            responses = self.openmeteo.weather_api(self.climate_url, params=params)
            response = responses[0]
            
            daily = response.Daily()
            daily_temperature_2m_max = daily.Variables(0).ValuesAsNumpy()
            daily_precipitation_sum = daily.Variables(2).ValuesAsNumpy()
            
            avg_max_temp = float(daily_temperature_2m_max.mean())
            total_rainfall = float(daily_precipitation_sum.sum())
            
            return {
                "avg_max_temperature_c": round(avg_max_temp, 2),
                "total_precipitation_mm": round(total_rainfall, 2),
                "climate_condition": "Favorable" if avg_max_temp < 35 else "Heat Stress Risk"
            }
        except Exception as e:
            print(f"Error fetching climate data: {e}")
            return {
                "avg_max_temperature_c": 32.5,
                "total_precipitation_mm": 150.0,
                "climate_condition": "Unknown"
            }

    def fetch_mock_mandi_prices(self, district: str) -> List[Dict[str, Any]]:
        """Mocks the Agmarknet API response for a given district."""
        # This will be replaced by actual scraping/API calls in the future.
        if district.lower() == "palakkad":
            return [
                {"commodity": "Paddy", "price_per_quintal": 2800.00, "trend": "UP"},
                {"commodity": "Banana", "price_per_quintal": 3200.00, "trend": "STABLE"},
                {"commodity": "Raw Milk", "price_per_liter": 46.00, "trend": "STABLE"}
            ]
        elif district.lower() == "coimbatore":
            return [
                {"commodity": "Coconut", "price_per_quintal": 3500.00, "trend": "DOWN"},
                {"commodity": "Maize", "price_per_quintal": 2200.00, "trend": "UP"},
                {"commodity": "Cotton", "price_per_quintal": 7200.00, "trend": "UP"}
            ]
        return []

    def fetch_mock_input_costs(self, district: str) -> Dict[str, float]:
        """Mocks input costs (Fuel, Labour, Fertilizer)."""
        return {
            "diesel_price_per_liter": 94.50 if district.lower() == "palakkad" else 92.30,
            "labour_rate_per_day": 850.00 if district.lower() == "palakkad" else 700.00,
            "urea_bag_price": 266.50
        }

data_fetcher_service = DataFetcherService()
