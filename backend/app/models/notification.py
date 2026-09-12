"""User notifications and alert subscriptions."""

from datetime import datetime, timezone
from enum import Enum
from typing import Any, Dict

from sqlalchemy import Boolean, DateTime, Enum as SqlEnum, ForeignKey, Integer, JSON, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class AlertType(str, Enum):
    WEATHER_WARNING = "weather_warning"
    DISEASE_OUTBREAK = "disease_outbreak"
    SCHEME_DEADLINE = "scheme_deadline"
    PRICE_ALERT = "price_alert"


class Notification(Base):
    """An alert delivered to one user."""

    __tablename__ = "notifications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    alert_type: Mapped[AlertType] = mapped_column(SqlEnum(AlertType), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(150), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    payload: Mapped[Dict[str, Any]] = mapped_column(JSON, nullable=False, default=dict)
    is_read: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, index=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )


class NotificationSubscription(Base):
    """A user's subscription to one agricultural alert type."""

    __tablename__ = "notification_subscriptions"
    __table_args__ = (
        UniqueConstraint("user_id", "alert_type", name="uq_notification_subscription_user_type"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    alert_type: Mapped[AlertType] = mapped_column(SqlEnum(AlertType), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False
    )