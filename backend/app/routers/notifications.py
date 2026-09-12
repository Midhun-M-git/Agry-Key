"""User notification and agricultural alert subscription routes."""

from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.notification import AlertType, Notification, NotificationSubscription
from app.models.user import User
from app.routers.auth import get_current_user
from app.schemas.notification import (
    NotificationResponse,
    NotificationSubscriptionRequest,
    NotificationSubscriptionResponse,
)

router = APIRouter(prefix="/notifications", tags=["Notifications"])


def _to_response(notification: Notification) -> NotificationResponse:
    return NotificationResponse(
        id=notification.id,
        alert_type=notification.alert_type,
        title=notification.title,
        message=notification.message,
        payload=notification.payload or {},
        is_read=notification.is_read,
        created_at=notification.created_at,
    )


@router.get("", response_model=list[NotificationResponse])
def list_notifications(
    unread_only: bool = Query(default=False),
    alert_type: Optional[AlertType] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Return the current user's newest notifications."""
    query = db.query(Notification).filter(Notification.user_id == current_user.id)
    if unread_only:
        query = query.filter(Notification.is_read.is_(False))
    if alert_type:
        query = query.filter(Notification.alert_type == alert_type)
    notifications = query.order_by(Notification.created_at.desc()).limit(limit).all()
    return [_to_response(notification) for notification in notifications]


@router.post("/mark-read/{notification_id}", response_model=NotificationResponse)
def mark_notification_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Mark one notification as read if it belongs to the current user."""
    notification = (
        db.query(Notification)
        .filter(Notification.id == notification_id, Notification.user_id == current_user.id)
        .first()
    )
    if not notification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return _to_response(notification)


@router.post("/subscribe", response_model=NotificationSubscriptionResponse)
def subscribe_to_alerts(
    req: NotificationSubscriptionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Replace the current user's alert subscriptions with the requested types."""
    alert_types = list(dict.fromkeys(req.alert_types))
    (
        db.query(NotificationSubscription)
        .filter(NotificationSubscription.user_id == current_user.id)
        .delete(synchronize_session=False)
    )
    db.add_all(
        NotificationSubscription(user_id=current_user.id, alert_type=alert_type)
        for alert_type in alert_types
    )
    db.commit()
    return NotificationSubscriptionResponse(alert_types=alert_types)