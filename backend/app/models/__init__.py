"""Centralized Model Registry."""

from app.models.user import User, FarmerProfile, GeoRegionLanguageMap
from app.models.farm import AgriculturalPlot, LivestockUnit, PoultryUnit, AquacultureUnit
from app.models.climate import HistoricalClimateData, MonthlyClimateBaseline
from app.models.economics import (
    FertilizerPriceIndex,
    FuelPriceIndex,
    FeedPriceIndex,
    LabourRateIndex,
    ElectricityTariffIndex,
    TransportCostIndex,
    MarketPriceTrend,
)
from app.models.soil import DistrictSoilSurvey, FarmerSoilHealthCard
from app.models.blockchain import (
    OfficialFertilizerMRP,
    VerifiedProduceStock,
    SynergyAdvisoryAudit,
)
from app.models.activity import FarmerActivityLog
from app.models.service import VeterinaryService

__all__ = [
    "User",
    "FarmerProfile",
    "GeoRegionLanguageMap",
    "AgriculturalPlot",
    "LivestockUnit",
    "PoultryUnit",
    "AquacultureUnit",
    "HistoricalClimateData",
    "MonthlyClimateBaseline",
    "FertilizerPriceIndex",
    "FuelPriceIndex",
    "FeedPriceIndex",
    "LabourRateIndex",
    "ElectricityTariffIndex",
    "TransportCostIndex",
    "MarketPriceTrend",
    "DistrictSoilSurvey",
    "FarmerSoilHealthCard",
    "OfficialFertilizerMRP",
    "VerifiedProduceStock",
    "SynergyAdvisoryAudit",
    "FarmerActivityLog",
    "VeterinaryService",
]
