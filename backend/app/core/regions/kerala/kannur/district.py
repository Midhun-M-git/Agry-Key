"""District Provider for Kannur (Kerala)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class KannurDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def district_name(self) -> str:
        return "Kannur"

    @property
    def language_code(self) -> str:
        return "ml"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Kannur APMC Market",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "KANNUR-001",
                "notes": "Primary APMC mandi serving Kannur"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Kannur District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Kannur"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Kannur Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Panniyur, KAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Taliparamba / Thalassery",
                "predominant_soil_type": "LATERITIC_RED_LOAM",
                "typical_ph_range": [5.2, 6.1],
                "typical_crops": ["Cashew", "Pepper", "Coconut", "Paddy"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
