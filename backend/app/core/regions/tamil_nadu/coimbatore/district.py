"""Coimbatore District Provider (Tamil Nadu).

All sources are PINPOINTED to Coimbatore district specifically.
The Data Checker Agent fetches from these exact primary sources for Coimbatore.
Nothing is averaged at state level — Coimbatore farmers get Coimbatore-specific rates.
"""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class CoimbatoreDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Tamil Nadu"

    @property
    def district_name(self) -> str:
        return "Coimbatore"

    @property
    def language_code(self) -> str:
        return "ta"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        """Pinpointed mandi/market sources for Coimbatore district only."""
        return [
            {
                "name": "Coimbatore APMC Market (Ukkadam)",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "TN-CBE-001",
                "notes": "Covers maize, cotton, vegetables, coconut"
            },
            {
                "name": "Aavin Coimbatore Dairy Co-operative",
                "sector": "DAIRY",
                "source_type": "AAVIN",
                "mandi_code": None,
                "notes": "Raw milk procurement price at Coimbatore Aavin centre"
            },
            {
                "name": "TNFDC Coimbatore Fish Market",
                "sector": "FISH",
                "source_type": "TNFDC",
                "mandi_code": None,
                "notes": "Freshwater and marine fish pricing at Coimbatore market"
            },
            {
                "name": "TN Poultry Fed — Coimbatore",
                "sector": "POULTRY",
                "source_type": "TNPF",
                "mandi_code": None,
                "notes": "Live broiler, layer egg rates pinpointed to Coimbatore zone"
            },
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        """Pinpointed economic input cost sources for Coimbatore district only."""
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Coimbatore District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "Diesel rate specific to Coimbatore (state VAT applied by Tamil Nadu)"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Coimbatore Depot / KVK Coimbatore",
                "fetch_url": "https://mfms.utiitsl.com",
                "notes": "IFFCO/KRIBHCO retail MRP at nearest Coimbatore depot"
            },
            {
                "index_type": "LABOUR",
                "source_name": "TN Agricultural Workers Wage Board — Coimbatore",
                "fetch_url": "https://nrega.nic.in",
                "notes": "Daily wage rate: maize/cotton harvesting season, Coimbatore taluk"
            },
            {
                "index_type": "ELECTRICITY",
                "source_name": "TANGEDCO Coimbatore — TNERC Agricultural Tariff",
                "fetch_url": "https://www.tangedco.gov.in",
                "notes": "Agricultural pump tariff per unit for Coimbatore farmers"
            },
            {
                "index_type": "FEED",
                "source_name": "Aavin Coimbatore / TNFDC — Input Feed Prices",
                "fetch_url": "https://aavinmilk.com",
                "notes": "Cattle feed and fish feed input cost at Coimbatore co-op"
            },
            {
                "index_type": "TRANSPORT",
                "source_name": "PPAC fuel rate × distance to Coimbatore APMC (Ukkadam)",
                "fetch_url": "",
                "notes": "Computed: diesel rate × kg-to-market distance for Coimbatore farmers"
            },
            {
                "index_type": "CLIMATE",
                "source_name": "IMD Coimbatore Meteorological Station",
                "fetch_url": "https://mausam.imd.gov.in",
                "notes": "20-year baseline: rainfall, temperature, humidity pinpointed to Coimbatore"
            },
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        """Soil testing labs & taluk soil classification profiles for Coimbatore."""
        return [
            {
                "facility_type": "SOIL_TESTING_LAB",
                "facility_name": "Soil Testing Laboratory — TNAU Coimbatore",
                "location": "Tamil Nadu Agricultural University (TNAU), Coimbatore",
                "source_portal": "Soil Health Card (SHC) Portal — https://soilhealth.dac.gov.in",
            },
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "Krishi Vigyan Kendra (KVK) TNAU, Coimbatore",
                "affiliation": "TNAU / ICAR",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Pollachi / Anaimalai",
                "predominant_soil_type": "BLACK_COTTON_SOIL",
                "typical_ph_range": [7.2, 8.4],
                "typical_crops": ["Coconut", "Maize", "Cotton", "Groundnut"],
                "notes": "Developer field survey teams collect village-level samples stored in `district_soil_surveys` table."
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Mettupalayam / Annur",
                "predominant_soil_type": "RED_LOAMY",
                "typical_ph_range": [6.5, 7.5],
                "typical_crops": ["Vegetables", "Bananas", "Turmeric"],
                "notes": "Foothill soil profile near Western Ghats."
            },
        ]
