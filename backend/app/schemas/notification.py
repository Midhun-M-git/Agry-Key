"""Request and response schemas for notifications and alert subscriptions."""

from datetime import datetime
from typing import Any, Dict, List

from pydantic import BaseModel

from app.models.notification import AlertType


class NotificationResponse(BaseModel):
    id: int
    alert_type: AlertType
    title: str
    message: str
    payload: Dict[str, Any]
    is_read: bool
    created_at: datetime


class NotificationSubscriptionRequest(BaseModel):
    alert_types: List[AlertType]


class NotificationSubscriptionResponse(BaseModel):
    alert_types: List[AlertType]