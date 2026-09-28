"""District Provider for Thrissur (Kerala)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class ThrissurDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def district_name(self) -> str:
        return "Thrissur"

    @property
    def language_code(self) -> str:
        return "ml"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Thrissur APMC",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "THRISSUR-001",
                "notes": "Primary APMC mandi serving Thrissur"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Thrissur District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Thrissur"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Thrissur Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Vellanikkara, KAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Chalakudy / Mukundapuram",
                "predominant_soil_type": "LATERITE",
                "typical_ph_range": [5.2, 6.2],
                "typical_crops": ["Paddy", "Nutmeg", "Coconut", "Banana"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
