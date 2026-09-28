"""District Provider for Kozhikode (Kerala)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class KozhikodeDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def district_name(self) -> str:
        return "Kozhikode"

    @property
    def language_code(self) -> str:
        return "ml"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Kozhikode APMC Central Mandi",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "KOZHIKODE-001",
                "notes": "Primary APMC mandi serving Kozhikode"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Kozhikode District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Kozhikode"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Kozhikode Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Peruvannamuzhi, ICAR-IISR",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Koyilandy / Vadakara",
                "predominant_soil_type": "COASTAL_ALLUVIAL",
                "typical_ph_range": [5.4, 6.3],
                "typical_crops": ["Coconut", "Pepper", "Ginger", "Turmeric"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
