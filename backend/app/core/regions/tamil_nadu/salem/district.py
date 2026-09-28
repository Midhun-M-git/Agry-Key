"""District Provider for Salem (Tamil Nadu)."""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class SalemDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Tamil Nadu"

    @property
    def district_name(self) -> str:
        return "Salem"

    @property
    def language_code(self) -> str:
        return "ta"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "name": "Salem Regulated Market",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "SALEM-001",
                "notes": "Primary APMC mandi serving Salem"
            }
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Salem District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "PPAC retail fuel rate for Salem"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Salem Depot",
                "fetch_url": "https://fert.gov.in",
                "notes": "Statutory fertilizer MRP index"
            }
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        return [
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "KVK Sandhiyur, TNAU",
                "affiliation": "ICAR / State Agricultural University",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Attur / Omalur",
                "predominant_soil_type": "RED_LOAMY",
                "typical_ph_range": [6.5, 7.8],
                "typical_crops": ["Mango", "Tapioca", "Sorghum", "Cotton"],
                "notes": "Ground soil survey data collected by field survey teams."
            }
        ]
