"""District Provider for Ernakulam (Kerala)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class ErnakulamDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def district_name(self) -> str:
        return "Ernakulam"

    @property
    def language_code(self) -> str:
        return "ml"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Vazhakulam Pineapple Market / Cochin APMC",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "ERNAKULAM-001",
                "notes": "Primary APMC mandi serving Ernakulam"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Ernakulam District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Ernakulam"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Ernakulam Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Ernakulam, ICAR-CMFRI",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Aluva / Muvattupuzha",
                "predominant_soil_type": "RIVERINE_ALLUVIAL",
                "typical_ph_range": [5.5, 6.5],
                "typical_crops": ["Pineapple", "Rubber", "Shrimp", "Paddy"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
