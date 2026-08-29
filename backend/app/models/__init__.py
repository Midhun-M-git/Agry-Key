"""Centralized Model Registry."""

from app.models.user import User, FarmerProfile
from app.models.farm import AgriculturalPlot, LivestockUnit, PoultryUnit, AquacultureUnit
from app.models.climate import HistoricalClimateData, SuggestionAuditLog
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
    BlockchainLedgerBlock,
)
from app.models.activity import (
    CropRecord,
    LivestockRecord,
    PoultryRecord,
    AquacultureRecord,
)
from app.models.service import VeterinaryService

__all__ = [
    "User",
    "FarmerProfile",
    "AgriculturalPlot",
    "LivestockUnit",
    "PoultryUnit",
    "AquacultureUnit",
    "HistoricalClimateData",
    "SuggestionAuditLog",
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
    "BlockchainLedgerBlock",
    "CropRecord",
    "LivestockRecord",
    "PoultryRecord",
    "AquacultureRecord",
    "VeterinaryService",
]
