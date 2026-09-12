"""add notifications and subscriptions

Revision ID: f9a8b7c6d5e4
Revises: e8f7a6b5c4d3
Create Date: 2026-09-12 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "f9a8b7c6d5e4"
down_revision: Union[str, Sequence[str], None] = "e8f7a6b5c4d3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


alert_type = sa.Enum(
    "WEATHER_WARNING",
    "DISEASE_OUTBREAK",
    "SCHEME_DEADLINE",
    "PRICE_ALERT",
    name="alerttype",
)


def upgrade() -> None:
    op.create_table(
        "notifications",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("alert_type", alert_type, nullable=False),
        sa.Column("title", sa.String(length=150), nullable=False),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("payload", sa.JSON(), nullable=False),
        sa.Column("is_read", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_notifications_id", "notifications", ["id"], unique=False)
    op.create_index("ix_notifications_user_id", "notifications", ["user_id"], unique=False)
    op.create_index("ix_notifications_alert_type", "notifications", ["alert_type"], unique=False)
    op.create_index("ix_notifications_is_read", "notifications", ["is_read"], unique=False)

    op.create_table(
        "notification_subscriptions",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("alert_type", alert_type, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "user_id", "alert_type", name="uq_notification_subscription_user_type"
        ),
    )
    op.create_index(
        "ix_notification_subscriptions_id", "notification_subscriptions", ["id"], unique=False
    )
    op.create_index(
        "ix_notification_subscriptions_user_id",
        "notification_subscriptions",
        ["user_id"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_notification_subscriptions_user_id", table_name="notification_subscriptions")
    op.drop_index("ix_notification_subscriptions_id", table_name="notification_subscriptions")
    op.drop_table("notification_subscriptions")
    op.drop_index("ix_notifications_is_read", table_name="notifications")
    op.drop_index("ix_notifications_alert_type", table_name="notifications")
    op.drop_index("ix_notifications_user_id", table_name="notifications")
    op.drop_index("ix_notifications_id", table_name="notifications")
    op.drop_table("notifications")
    alert_type.drop(op.get_bind(), checkfirst=True)
