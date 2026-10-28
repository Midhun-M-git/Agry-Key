try:
    import httpx
except ImportError:
    httpx = None
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List, Optional


def to_unit_aware_quintal_price(modal_price: float, price_unit: str) -> Optional[float]:
    """
    Converts commodity prices to per-quintal standard only when unit is mass-based.
    Returns None when unit is piece, count, or volume (litre), avoiding corrupted conversions.
    """
    u = (price_unit or "").strip().lower()
    if u in ("quintal", "qtl", "100kg"):
        return round(float(modal_price), 2)
    if u in ("kg", "kilogram"):
        return round(float(modal_price) * 100.0, 2)
    if u in ("tonne", "ton", "metric ton"):
        return round(float(modal_price) / 10.0, 2)
    return None

class DataFetcherService:
    """Service to fetch real-time and historical data from official APIs."""

    def __init__(self):
        self.forecast_url = "https://api.open-meteo.com/v1/forecast"

    def fetch_climate_baseline(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Fetch real-time climate conditions and a seven-day forecast."""
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code",
            "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,weather_code,precipitation_probability_max",
            "timezone": "auto",
            "forecast_days": 7,
        }
        
        headers = {
            "User-Agent": "AgryKey-Agriculture/1.0 (https://agrykey.in; support@agrykey.in)",
            "Accept": "application/json",
        }
        
        data = None
        if httpx is not None:
            try:
                with httpx.Client(timeout=10.0, headers=headers) as client:
                    resp = client.get(self.forecast_url, params=params)
                    resp.raise_for_status()
                    data = resp.json()
            except Exception as e:
                print(f"[DataFetcher] httpx weather request failed: {e}. Trying urllib fallback...")

        if data is None:
            try:
                import urllib.parse
                import urllib.request
                import json
                qs = urllib.parse.urlencode(params)
                req = urllib.request.Request(
                    f"{self.forecast_url}?{qs}",
                    headers=headers,
                )
                with urllib.request.urlopen(req, timeout=10) as response:
                    if response.getcode() == 200:
                        data = json.loads(response.read().decode("utf-8"))
            except Exception as ur_err:
                print(f"[DataFetcher] urllib weather request failed: {ur_err}")

        if data and "current" in data:
            current_raw = data.get("current", {})
            daily_raw = data.get("daily", {})

            curr_temp = current_raw.get("temperature_2m")
            curr_hum = current_raw.get("relative_humidity_2m")
            if curr_temp is None or curr_hum is None:
                # Fails closed if critical observational fields are missing
                return {
                    "status": "unavailable",
                    "message": "Live meteorological fields are incomplete or invalid.",
                    "is_live": False,
                    "current": None,
                    "forecast": [],
                    "alerts": [],
                    "avg_max_temperature_c": None,
                    "total_precipitation_mm": None,
                    "climate_condition": "Unknown",
                }

            daily_max = daily_raw.get("temperature_2m_max", [])
            daily_min = daily_raw.get("temperature_2m_min", [])
            daily_precip = daily_raw.get("precipitation_sum", [])
            daily_wind = daily_raw.get("wind_speed_10m_max", [])
            daily_code = daily_raw.get("weather_code", [])
            daily_prob = daily_raw.get("precipitation_probability_max", [])
            daily_time = daily_raw.get("time", [])

            forecast = []
            for i in range(len(daily_time)):
                forecast.append(
                    {
                        "date": daily_time[i],
                        "temperature_max_c": round(float(daily_max[i]), 1) if (i < len(daily_max) and daily_max[i] is not None) else None,
                        "temperature_min_c": round(float(daily_min[i]), 1) if (i < len(daily_min) and daily_min[i] is not None) else None,
                        "precipitation_mm": round(float(daily_precip[i]), 1) if (i < len(daily_precip) and daily_precip[i] is not None) else 0.0,
                        "precipitation_probability_percent": int(daily_prob[i]) if (i < len(daily_prob) and daily_prob[i] is not None) else None,
                        "wind_speed_max_kmh": round(float(daily_wind[i]), 1) if (i < len(daily_wind) and daily_wind[i] is not None) else None,
                        "weather_code": int(daily_code[i]) if (i < len(daily_code) and daily_code[i] is not None) else None,
                    }
                )

            valid_max = [float(x) for x in daily_max if x is not None]
            valid_precip = [float(x) for x in daily_precip if x is not None]
            avg_max_temp = float(sum(valid_max) / len(valid_max)) if valid_max else None
            total_rainfall = float(sum(valid_precip)) if valid_precip else 0.0

            current_conditions = {
                "temperature_c": round(float(curr_temp), 1),
                "humidity_percent": int(curr_hum),
                "wind_speed_kmh": round(float(current_raw.get("wind_speed_10m", 0.0)), 1),
                "precipitation_mm": round(float(current_raw.get("precipitation", 0.0)), 1),
                "weather_code": int(current_raw.get("weather_code", 1)),
            }
            
            return {
                "provider": "Open-Meteo Weather Model",
                "data_type": "gridded_numerical_model",
                "timestamp": current_raw.get("time") or datetime.now(timezone.utc).isoformat(),
                "avg_max_temperature_c": round(avg_max_temp, 2) if avg_max_temp is not None else None,
                "total_precipitation_mm": round(total_rainfall, 2),
                "climate_condition": ("Favorable" if avg_max_temp < 35 else "Heat Stress Risk") if avg_max_temp is not None else "Unknown",
                "current": current_conditions,
                "forecast": forecast,
                "alerts": self._build_weather_alerts(forecast),
                "is_live": True,
            }

        # Strict Fail-Closed: Never fabricate synthetic temperature/precipitation when external satellite/API feed fails
        print("[DataFetcher] Live weather observation feed unavailable. Returning unavailable status.")
        return {
            "status": "unavailable",
            "message": "Live weather observations currently unavailable.",
            "is_live": False,
            "current": None,
            "forecast": [],
            "alerts": [],
            "avg_max_temperature_c": None,
            "total_precipitation_mm": None,
            "climate_condition": "Unknown",
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

    def fetch_mandi_prices(self, district: str) -> List[Dict[str, Any]]:
        """Fetch verified Agmarknet APMC mandi prices from database or live fetcher."""
        from app.core.database import SessionLocal
        from app.models.economics import MarketPriceTrend
        from app.services.agmarknet_fetcher import agmarknet_fetcher

        db = SessionLocal()
        try:
            records = (
                db.query(MarketPriceTrend)
                .filter(MarketPriceTrend.district.ilike(district.strip()))
                .all()
            )
            if records:
                results = []
                for r in records:
                    results.append({
                        "commodity": r.commodity_name,
                        "price_per_quintal": to_unit_aware_quintal_price(r.modal_price, r.price_unit),
                        "modal_price": r.modal_price,
                        "price_unit": r.price_unit,
                        "mandi": r.mandi_name,
                        "trend": "UP" if r.modal_price >= (r.min_price + r.max_price) / 2 else "STABLE",
                        "official_source": r.official_source,
                        "is_fresh": agmarknet_fetcher.is_data_fresh(r.fetched_at),
                    })
                return results
        except Exception as e:
            print(f"[DataFetcher] Error querying DB mandi prices: {e}")
        finally:
            db.close()

        # Fallback to agmarknet_fetcher service
        live_records = agmarknet_fetcher.fetch_live_mandi_prices(district=district)
        return [
            {
                "commodity": r["commodity_name"],
                "price_per_quintal": to_unit_aware_quintal_price(r["modal_price"], r["price_unit"]),
                "modal_price": r["modal_price"],
                "price_unit": r["price_unit"],
                "mandi": r["mandi_name"],
                "trend": "UP",
                "official_source": r["official_source"],
                "is_fresh": True,
            }
            for r in live_records
        ]



    def fetch_input_costs(self, district: str) -> Dict[str, float]:
        """Fetches live input costs (Fuel from PPAC, Fertilizer from mFMS, Labour) from verified database tables."""
        from app.core.database import SessionLocal
        from app.models.economics import FuelPriceIndex, FertilizerPriceIndex, LabourRateIndex

        db = SessionLocal()
        try:
            # 1. Fuel from PPAC
            fuel = (
                db.query(FuelPriceIndex)
                .filter(FuelPriceIndex.district.ilike(district.strip()))
                .first()
            )
            diesel = float(fuel.diesel_rate_per_liter) if fuel else None

            # 2. Fertilizer from mFMS
            urea = (
                db.query(FertilizerPriceIndex)
                .filter(FertilizerPriceIndex.fertilizer_type.ilike("%urea%"))
                .first()
            )
            urea_mrp = float(urea.official_mrp_per_bag) if urea else None

            # 3. Labour rates
            labour = (
                db.query(LabourRateIndex)
                .filter(LabourRateIndex.district.ilike(district.strip()))
                .first()
            )
            labour_rate = float(labour.rate_per_day_inr) if labour else None

            return {
                "diesel_price_per_liter": diesel,
                "urea_bag_price": urea_mrp,
                "labour_rate_per_day": labour_rate,
                "status": "available" if (diesel and urea_mrp and labour_rate) else "unavailable",
            }
        except Exception as e:
            print(f"[DataFetcher] Error querying input costs: {e}")
            return {
                "diesel_price_per_liter": None,
                "urea_bag_price": None,
                "labour_rate_per_day": None,
                "status": "unavailable",
            }
        finally:
            db.close()



data_fetcher_service = DataFetcherService()
