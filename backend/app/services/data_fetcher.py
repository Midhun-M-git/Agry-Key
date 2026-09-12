import openmeteo_requests
import requests_cache
from retry_requests import retry
from datetime import datetime, timezone
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
        """Fetch climate aggregates, current conditions, and a seven-day forecast."""
        # Note: In a full production app, this would query the historical archive
        # for a 20-year baseline. For this implementation, we use the free forecast API
        # as a proxy for current seasonal conditions.
        
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": [
                "temperature_2m",
                "relative_humidity_2m",
                "wind_speed_10m",
                "precipitation",
                "weather_code",
            ],
            "daily": [
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "wind_speed_10m_max",
                "weather_code",
                "precipitation_probability_max",
            ],
            "timezone": "auto",
            "past_days": 30,
            "forecast_days": 7,
        }
        
        try:
            responses = self.openmeteo.weather_api(self.climate_url, params=params)
            response = responses[0]
            
            daily = response.Daily()
            daily_temperature_2m_max = daily.Variables(0).ValuesAsNumpy()
            daily_temperature_2m_min = daily.Variables(1).ValuesAsNumpy()
            daily_precipitation_sum = daily.Variables(2).ValuesAsNumpy()
            daily_wind_speed_max = daily.Variables(3).ValuesAsNumpy()
            daily_weather_code = daily.Variables(4).ValuesAsNumpy()
            daily_precipitation_probability = daily.Variables(5).ValuesAsNumpy()

            forecast_start = max(0, len(daily_temperature_2m_max) - 7)
            forecast = []
            for index in range(forecast_start, len(daily_temperature_2m_max)):
                forecast_date = datetime.fromtimestamp(
                    daily.Time() + index * daily.Interval(), tz=timezone.utc
                ).date().isoformat()
                forecast.append(
                    {
                        "date": forecast_date,
                        "temperature_max_c": round(float(daily_temperature_2m_max[index]), 1),
                        "temperature_min_c": round(float(daily_temperature_2m_min[index]), 1),
                        "precipitation_mm": round(float(daily_precipitation_sum[index]), 1),
                        "precipitation_probability_percent": int(
                            daily_precipitation_probability[index]
                        ),
                        "wind_speed_max_kmh": round(float(daily_wind_speed_max[index]), 1),
                        "weather_code": int(daily_weather_code[index]),
                    }
                )

            avg_max_temp = float(daily_temperature_2m_max.mean())
            total_rainfall = float(daily_precipitation_sum.sum())
            current = response.Current()
            current_conditions = {
                "temperature_c": round(float(current.Variables(0).Value()), 1),
                "humidity_percent": int(current.Variables(1).Value()),
                "wind_speed_kmh": round(float(current.Variables(2).Value()), 1),
                "precipitation_mm": round(float(current.Variables(3).Value()), 1),
                "weather_code": int(current.Variables(4).Value()),
            }
            
            return {
                "avg_max_temperature_c": round(avg_max_temp, 2),
                "total_precipitation_mm": round(total_rainfall, 2),
                "climate_condition": "Favorable" if avg_max_temp < 35 else "Heat Stress Risk",
                "current": current_conditions,
                "forecast": forecast,
                "alerts": self._build_weather_alerts(forecast),
            }
        except Exception as e:
            print(f"Error fetching climate data: {e}")
            return {
                "avg_max_temperature_c": None,
                "total_precipitation_mm": None,
                "climate_condition": "Unknown",
                "current": None,
                "forecast": [],
                "alerts": [],
            }

    @staticmethod
    def _build_weather_alerts(forecast: List[Dict[str, Any]]) -> List[Dict[str, str]]:
        """Build agricultural alerts from forecast thresholds."""
        alerts = []
        for day in forecast:
            if day["temperature_min_c"] <= 0:
                alerts.append(
                    {
                        "type": "frost",
                        "severity": "high",
                        "date": day["date"],
                        "message": "Frost risk: protect sensitive crops and irrigation lines.",
                    }
                )
            if day["precipitation_mm"] >= 50:
                alerts.append(
                    {
                        "type": "heavy_rain",
                        "severity": "high",
                        "date": day["date"],
                        "message": "Heavy rain expected: improve field drainage and postpone spraying.",
                    }
                )
            if day["temperature_max_c"] >= 35:
                alerts.append(
                    {
                        "type": "heat_stress",
                        "severity": "high",
                        "date": day["date"],
                        "message": "Heat stress risk: irrigate early and monitor livestock and crops.",
                    }
                )
        return alerts

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
