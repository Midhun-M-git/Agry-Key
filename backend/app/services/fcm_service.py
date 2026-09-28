"""Firebase Cloud Messaging (FCM) Push Notification Dispatcher."""

import logging
from typing import Any, Dict, Optional
import httpx
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.notification import AlertType, Notification

logger = logging.getLogger(__name__)


class FCMService:
    """Dispatches real push notifications via Google FCM HTTP v1 / legacy protocols."""

    @classmethod
    def send_push_notification(
        cls,
        user_id: int,
        title: str,
        body: str,
        fcm_device_token: Optional[str] = None,
        alert_type: AlertType = AlertType.SYSTEM,
        data_payload: Optional[Dict[str, Any]] = None,
        db: Optional[Session] = None,
    ) -> Dict[str, Any]:
        """Dispatches push notification and persists notification record."""
        # 1. Persist notification to DB if session provided
        notification_record = None
        if db:
            notification_record = Notification(
                user_id=user_id,
                alert_type=alert_type,
                title=title,
                message=body,
                payload=data_payload or {},
                is_read=False,
            )
            db.add(notification_record)
            db.commit()
            db.refresh(notification_record)

        # 2. If FCM server key and device token are configured, dispatch real push
        if settings.FCM_SERVER_KEY and fcm_device_token:
            try:
                headers = {
                    "Authorization": f"key={settings.FCM_SERVER_KEY}",
                    "Content-Type": "application/json",
                }
                payload = {
                    "to": fcm_device_token,
                    "notification": {
                        "title": title,
                        "body": body,
                        "sound": "default",
                    },
                    "data": data_payload or {},
                }
                with httpx.Client(timeout=5.0) as client:
                    resp = client.post("https://fcm.googleapis.com/fcm/send", json=payload, headers=headers)
                    if resp.status_code == 200:
                        return {"success": True, "dispatched": True, "notification_id": notification_record.id if notification_record else None}
                    else:
                        logger.warning(f"FCM push failed with status {resp.status_code}: {resp.text}")
            except Exception as e:
                logger.error(f"FCM exception during dispatch: {e}")

        return {
            "success": True,
            "dispatched": False,
            "mode": "in_app_persisted",
            "notification_id": notification_record.id if notification_record else None,
        }
