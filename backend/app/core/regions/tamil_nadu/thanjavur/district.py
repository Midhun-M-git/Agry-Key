"""District Provider for Thanjavur (Tamil Nadu)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class ThanjavurDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Tamil Nadu"

    @property
    def district_name(self) -> str:
        return "Thanjavur"

    @property
    def language_code(self) -> str:
        return "ta"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Thanjavur Delta Regulated Market",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "THANJAVUR-001",
                "notes": "Primary APMC mandi serving Thanjavur"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Thanjavur District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Thanjavur"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Thanjavur Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Needamangalam / Thanjavur, TNAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Kumbakonam / Papanasam",
                "predominant_soil_type": "CAUVERY_DELTA_ALLUVIAL",
                "typical_ph_range": [6.8, 7.8],
                "typical_crops": ["Paddy (Kuruvai/Samba)", "Blackgram", "Sugarcane", "Groundnut"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
