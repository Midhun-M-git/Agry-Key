"""District Provider for Malappuram (Kerala)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class MalappuramDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def district_name(self) -> str:
        return "Malappuram"

    @property
    def language_code(self) -> str:
        return "ml"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Manjeri / Tirur Market",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "MALAPPURAM-001",
                "notes": "Primary APMC mandi serving Malappuram"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Malappuram District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Malappuram"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Malappuram Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Tavanur, KAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Tirur / Ponnani / Ernad",
                "predominant_soil_type": "LATERITE",
                "typical_ph_range": [5.3, 6.2],
                "typical_crops": ["Arecanut", "Coconut", "Rubber", "Paddy"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
