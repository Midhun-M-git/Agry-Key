"""Centralized Model Registry."""

from app.models.user import User, FarmerProfile, OTPRecord
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
from app.models.service import VeterinaryService, GeoRegionLanguageMap
from app.models.marketplace import Product
from app.models.order import Order, OrderStatus
from app.models.scheme import Scheme
from app.models.notification import AlertType, Notification, NotificationSubscription
from app.models.community import Comment, Post, PostLike

__all__ = [
    "User",
    "FarmerProfile",
    "OTPRecord",
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
    "GeoRegionLanguageMap",
    "Product",
    "Order",
    "OrderStatus",
    "Scheme",
    "AlertType",
    "Notification",
    "NotificationSubscription",
    "Post",
    "Comment",
    "PostLike",
]
