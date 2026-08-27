"""Abstract Base Classes for State and District Data Providers.

Folder Convention (all contributors must follow):

    app/core/regions/
    └── <state>/
        ├── <state>.py              ← State-level provider (language, district list)
        └── <district>/
            ├── district.py         ← District dataset provider (source declarations)
            └── slang.json          ← Regional dialect slang pack

No real data (prices, contacts, names) belongs here.
All data is fetched live by the Data Checker Agent from official primary sources,
or populated into DB tables by developer field survey teams.
"""

from abc import ABC, abstractmethod
from typing import Any, Dict, List


class BaseStateProvider(ABC):
    """Declares state-level language and district coverage."""

    @property
    @abstractmethod
    def state_name(self) -> str:
        pass

    @property
    @abstractmethod
    def default_language_code(self) -> str:
        pass

    @abstractmethod
    def get_supported_districts(self) -> List[str]:
        pass


class BaseDistrictProvider(ABC):
    """Declares district-level data source registrations.

    Each method returns a list of source descriptors — not actual data.
    Actual data is fetched live by the Data Checker Agent or uploaded from
    developer ground field surveys into database tables:

    Database Table           ↔ District Source / Survey Declaration
    ───────────────────────────────────────────────────────────────
    DistrictSoilSurvey      ← Developer ground field survey data & local KVK lab
    FarmerSoilHealthCard    ← Farmer's Soil Health Card (SHC) portal lookup
    FertilizerPriceIndex    ← fertilizer MRP source (varies by state subsidy)
    FuelPriceIndex          ← PPAC district diesel/petrol rate
    LabourRateIndex         ← state minimum wage / MGNREGA rate
    ElectricityTariffIndex  ← SERC agricultural pump tariff
    FeedPriceIndex          ← livestock / poultry / aquaculture feed costs
    TransportCostIndex      ← fuel-rate × distance-to-mandi model
    MarketPriceTrend        ← Agmarknet / NDDB / Matsyafed / KEPCO live prices
    HistoricalClimateData   ← IMD / Open-Meteo 20-year district baseline
    VeterinaryService       ← live on-duty doctor lookup from DB table
    """

    @property
    @abstractmethod
    def state_name(self) -> str:
        pass

    @property
    @abstractmethod
    def district_name(self) -> str:
        pass

    @property
    @abstractmethod
    def language_code(self) -> str:
        pass

    @abstractmethod
    def get_market_source_declarations(self) -> List[Dict[str, str]]:
        """Declares which official mandi/source feeds apply to this district."""
        pass

    @abstractmethod
    def get_economic_source_declarations(self) -> List[Dict[str, str]]:
        """Declares which economic rate sources apply to this district."""
        pass

    @abstractmethod
    def get_soil_profile_declarations(self) -> List[Dict[str, Any]]:
        """Declares local soil testing labs, KVK centers, and taluk soil type defaults.
        
        Field survey teams will populate exact soil test measurements into the
        `district_soil_surveys` database table per village/Panchayath.
        """
        pass
