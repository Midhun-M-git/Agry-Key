"""District Provider for Tirunelveli (Tamil Nadu)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class TirunelveliDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Tamil Nadu"

    @property
    def district_name(self) -> str:
        return "Tirunelveli"

    @property
    def language_code(self) -> str:
        return "ta"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Tirunelveli Regulated Market",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "TIRUNELVELI-001",
                "notes": "Primary APMC mandi serving Tirunelveli"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Tirunelveli District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Tirunelveli"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Tirunelveli Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Ambasamudram, TNAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Ambasamudram / Tenkasi",
                "predominant_soil_type": "RED_SANDY_LOAM",
                "typical_ph_range": [6.2, 7.5],
                "typical_crops": ["Paddy", "Banana", "Pulses", "Chilli"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
