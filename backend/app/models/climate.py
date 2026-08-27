from datetime import datetime, timezone
from sqlalchemy import DateTime, Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class HistoricalClimateData(Base):
    __tablename__ = "historical_climate_data"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    district: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    month: Mapped[int] = mapped_column(Integer, nullable=False)  # 1 to 12
    avg_rainfall_mm_20yr: Mapped[float] = mapped_column(Float, nullable=False)
    avg_temp_min_c: Mapped[float] = mapped_column(Float, nullable=False)
    avg_temp_max_c: Mapped[float] = mapped_column(Float, nullable=False)
    drought_risk_score: Mapped[float] = mapped_column(Float, default=0.0)  # 0.0 (low) to 1.0 (severe)


class SuggestionAuditLog(Base):
    __tablename__ = "suggestion_audit_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    farmer_profile_id: Mapped[int] = mapped_column(Integer, nullable=False)
    query_text: Mapped[str] = mapped_column(Text, nullable=False)
    advisory_recommendation: Mapped[str] = mapped_column(Text, nullable=False)
    verifier_audit_passed: Mapped[bool] = mapped_column(default=True)
    verifier_feedback: Mapped[str] = mapped_column(Text, nullable=True)
    spoken_audio_url: Mapped[str] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
