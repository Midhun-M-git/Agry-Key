"""District Provider for Madurai (Tamil Nadu)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class MaduraiDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Tamil Nadu"

    @property
    def district_name(self) -> str:
        return "Madurai"

    @property
    def language_code(self) -> str:
        return "ta"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Madurai Central Market (Mattuthavani)",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "MADURAI-001",
                "notes": "Primary APMC mandi serving Madurai"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Madurai District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Madurai"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Madurai Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Madurai, Agricultural College TNAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Melur / Vadipatti",
                "predominant_soil_type": "BLACK_COTTON_SOIL",
                "typical_ph_range": [7.2, 8.4],
                "typical_crops": ["Paddy", "Jasmine", "Pulses", "Millets"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
