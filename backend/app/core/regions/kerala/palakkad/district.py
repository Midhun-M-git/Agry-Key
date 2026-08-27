"""Palakkad District Provider (Kerala).

All sources are PINPOINTED to Palakkad district specifically.
The Data Checker Agent fetches from these exact primary sources for Palakkad.
Nothing is averaged at state level — Palakkad farmers get Palakkad-specific rates.
"""

from typing import Any, Dict, List
from app.core.regions.base import BaseDistrictProvider


class PalakkadDistrictProvider(BaseDistrictProvider):

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def district_name(self) -> str:
        return "Palakkad"

    @property
    def language_code(self) -> str:
        return "ml"

    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        """Pinpointed mandi/market sources for Palakkad district only."""
        return [
            {
                "name": "Palakkad APMC Market",
                "sector": "CROPS",
                "source_type": "AGMARKNET",
                "mandi_code": "KL-PKD-001",
                "notes": "Covers paddy, banana, tapioca, vegetables"
            },
            {
                "name": "MILMA Palakkad Dairy Co-operative",
                "sector": "DAIRY",
                "source_type": "MILMA",
                "mandi_code": None,
                "notes": "Raw milk procurement price for Palakkad dairy farmers"
            },
            {
                "name": "Matsyafed Palakkad Inland Fisheries",
                "sector": "FISH",
                "source_type": "MATSYAFED",
                "mandi_code": None,
                "notes": "Inland fish (freshwater) pricing for Palakkad ponds/lakes"
            },
            {
                "name": "Kerala Poultry Fed - Palakkad Unit",
                "sector": "POULTRY",
                "source_type": "KEPCO",
                "mandi_code": None,
                "notes": "Broiler and layer egg live rates for Palakkad"
            },
        ]

    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        """Pinpointed economic input cost sources for Palakkad district only."""
        return [
            {
                "index_type": "FUEL",
                "source_name": "PPAC — Palakkad District Pump Rate",
                "fetch_url": "https://ppac.gov.in",
                "notes": "Diesel rate specific to Palakkad (state VAT applied by Kerala)"
            },
            {
                "index_type": "FERTILIZER",
                "source_name": "mFMS Portal — Palakkad Depot / KVK Palakkad",
                "fetch_url": "https://mfms.utiitsl.com",
                "notes": "IFFCO/KRIBHCO retail MRP at nearest Palakkad depot"
            },
            {
                "index_type": "LABOUR",
                "source_name": "Kerala Agricultural Workers Wage Board — Palakkad",
                "fetch_url": "https://nrega.nic.in",
                "notes": "Daily wage rate: paddy planting / harvesting season, Palakkad taluk"
            },
            {
                "index_type": "ELECTRICITY",
                "source_name": "KSEB Palakkad Section — KERC Agricultural Tariff",
                "fetch_url": "https://kseb.in",
                "notes": "Agricultural pump tariff per unit for Palakkad farmers"
            },
            {
                "index_type": "FEED",
                "source_name": "MILMA Palakkad / Matsyafed — Input Feed Prices",
                "fetch_url": "https://milma.com",
                "notes": "Cattle feed and fish feed input cost at Palakkad co-op"
            },
            {
                "index_type": "TRANSPORT",
                "source_name": "PPAC fuel rate × distance to Palakkad APMC",
                "fetch_url": "",
                "notes": "Computed: diesel rate × kg-to-market distance for Palakkad farmers"
            },
            {
                "index_type": "CLIMATE",
                "source_name": "IMD Palakkad Meteorological Station",
                "fetch_url": "https://mausam.imd.gov.in",
                "notes": "20-year baseline: rainfall, temperature, humidity pinpointed to Palakkad"
            },
        ]

    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        """Soil testing labs & taluk soil classification profiles for Palakkad."""
        return [
            {
                "facility_type": "SOIL_TESTING_LAB",
                "facility_name": "District Soil Testing Laboratory — Palakkad",
                "location": "Pattambi / Palakkad Town",
                "source_portal": "Soil Health Card (SHC) Portal — https://soilhealth.dac.gov.in",
            },
            {
                "facility_type": "KVK_CENTER",
                "facility_name": "Krishi Vigyan Kendra (KVK) Pattambi, Palakkad",
                "affiliation": "Kerala Agricultural University (KAU)",
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Chittur / Palakkad / Alathur",
                "predominant_soil_type": "RIVERINE_ALLUVIAL",
                "typical_ph_range": [5.8, 6.8],
                "typical_crops": ["Paddy", "Banana", "Vegetables"],
                "notes": "Developer field survey teams collect village-level samples stored in `district_soil_surveys` table."
            },
            {
                "facility_type": "REGIONAL_SOIL_PROFILE",
                "taluk": "Mannarkkad / Attappady",
                "predominant_soil_type": "RED_LOAMY",
                "typical_ph_range": [5.2, 6.2],
                "typical_crops": ["Rubber", "Spices", "Millets"],
                "notes": "Attappady tribal belt / hill slope soil profile."
            },
        ]
