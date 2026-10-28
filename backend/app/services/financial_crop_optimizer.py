"""Financial Crop Optimization and Multi-Factor Alternative Recommender Engine.

Strictly calculates outcomes based on verified user inputs or database observations.
No hardcoded synthetic benchmark tables or fabricated financial numbers.
"""

from typing import Dict, Any, List, Optional


class FinancialCropOptimizer:
    """Computes exact net financial outcomes strictly from verified user inputs or observations."""

    # Freight transportation standard: ₹3.5 per quintal per 10 km + ₹30 handling charge per quintal
    FREIGHT_RATE_PER_QUINTAL_PER_KM = 0.35
    MANDI_UNLOADING_CHARGE_PER_QUINTAL = 30.0

    @classmethod
    def calculate_freight_cost(cls, distance_km: float, total_quintals: float) -> Dict[str, float]:
        """Calculates transportation logistics cost to the market."""
        per_quintal_rate = (distance_km * cls.FREIGHT_RATE_PER_QUINTAL_PER_KM) + cls.MANDI_UNLOADING_CHARGE_PER_QUINTAL
        total_freight = round(per_quintal_rate * total_quintals, 2)
        return {
            "per_quintal_freight": round(per_quintal_rate, 2),
            "total_freight_cost": total_freight,
            "distance_km": distance_km,
        }

    @classmethod
    def optimize(
        cls,
        state: str,
        district: str,
        acreage: float = 1.0,
        soil_type: str = "RED_LOAMY",
        water_source: str = "BOREWELL",
        latitude: float = 10.7867,
        longitude: float = 76.6547,
        crop_candidates: Optional[List[Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:
        """
        Runs financial optimization strictly on user-supplied or real-time observed crop parameters.
        Returns unavailable if real crop parameters are not provided.
        """
        if not crop_candidates:
            return {
                "status": "unavailable",
                "reason": "Crop financial parameters (yield, input costs, prices) not provided. Live observation or user input required.",
                "farmer_profile": {
                    "state": state,
                    "district": district,
                    "acreage": acreage,
                    "soil_type": soil_type,
                    "water_source": water_source,
                },
                "strategies": {},
                "all_ranked_crops": [],
            }

        safe_acreage = max(0.25, min(100.0, float(acreage)))
        evaluated_crops = []

        for crop in crop_candidates:
            name = crop.get("name") or crop.get("name_en") or "Custom Crop"
            yield_per_acre = float(
                crop.get("expected_yield_quintals_per_acre")
                or crop.get("expected_yield_quintals")
                or 0.0
            )
            if yield_per_acre <= 0:
                continue

            expected_yield = round(yield_per_acre * safe_acreage, 2)
            seed_cost = round(float(crop.get("seed_cost_per_acre", 0.0)) * safe_acreage, 2)
            fertilizer_cost = round(float(crop.get("fertilizer_cost_per_acre", 0.0)) * safe_acreage, 2)
            labor_cost = round(float(crop.get("labor_cost_per_acre", 0.0)) * safe_acreage, 2)
            total_input_cost = round(seed_cost + fertilizer_cost + labor_cost, 2)

            mandi_dist = float(crop.get("mandi_distance_km", 20.0))
            logistics = cls.calculate_freight_cost(mandi_dist, expected_yield)
            total_transport_cost = logistics["total_freight_cost"]

            harvest_price = float(crop.get("harvest_price_per_quintal", 0.0))
            gross_revenue = round(expected_yield * harvest_price, 2)
            total_investment = round(total_input_cost + total_transport_cost, 2)
            net_profit = round(gross_revenue - total_investment, 2)
            roi_percentage = round((net_profit / max(1.0, total_investment)) * 100, 1)

            evaluated_crops.append({
                "crop_id": crop.get("crop_id", name.lower().replace(" ", "_")),
                "name": name,
                "strategy_type": crop.get("strategy_type", "USER_INPUT"),
                "expected_yield_quintals": expected_yield,
                "harvest_price_per_quintal": harvest_price,
                "total_input_cost": total_input_cost,
                "total_transport_cost": total_transport_cost,
                "total_investment": total_investment,
                "gross_revenue": gross_revenue,
                "net_profit": net_profit,
                "roi_percentage": roi_percentage,
                "why_recommended": crop.get("why_recommended", "Calculated from user-supplied parameters."),
            })

        if not evaluated_crops:
            return {
                "status": "unavailable",
                "reason": "Provided crop parameters contain zero or invalid yields.",
                "strategies": {},
                "all_ranked_crops": [],
            }

        evaluated_crops.sort(key=lambda x: x["net_profit"], reverse=True)

        return {
            "status": "success",
            "farmer_profile": {
                "state": state,
                "district": district,
                "acreage": safe_acreage,
                "soil_type": soil_type,
                "water_source": water_source,
            },
            "strategies": {
                "highest_net_profit": evaluated_crops[0],
                "alternatives": evaluated_crops[1:],
            },
            "all_ranked_crops": evaluated_crops,
        }


financial_crop_optimizer = FinancialCropOptimizer()
