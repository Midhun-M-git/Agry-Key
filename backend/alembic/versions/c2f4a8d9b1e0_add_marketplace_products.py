"""add marketplace products

Revision ID: c2f4a8d9b1e0
Revises: 7e3c0ece8abe
Create Date: 2026-09-12 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "c2f4a8d9b1e0"
down_revision: Union[str, Sequence[str], None] = "7e3c0ece8abe"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "marketplace_products",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("farmer_id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("crop_type", sa.String(length=50), nullable=False),
        sa.Column("district", sa.String(length=100), nullable=False),
        sa.Column("quantity", sa.Float(), nullable=False),
        sa.Column("unit", sa.String(length=20), nullable=False),
        sa.Column("price_per_unit", sa.Float(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["farmer_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_marketplace_products_id", "marketplace_products", ["id"], unique=False)
    op.create_index(
        "ix_marketplace_products_farmer_id", "marketplace_products", ["farmer_id"], unique=False
    )
    op.create_index(
        "ix_marketplace_products_crop_type", "marketplace_products", ["crop_type"], unique=False
    )
    op.create_index(
        "ix_marketplace_products_district", "marketplace_products", ["district"], unique=False
    )
    op.create_index(
        "ix_marketplace_products_is_active", "marketplace_products", ["is_active"], unique=False
    )


def downgrade() -> None:
    op.drop_index("ix_marketplace_products_is_active", table_name="marketplace_products")
    op.drop_index("ix_marketplace_products_district", table_name="marketplace_products")
    op.drop_index("ix_marketplace_products_crop_type", table_name="marketplace_products")
    op.drop_index("ix_marketplace_products_farmer_id", table_name="marketplace_products")
    op.drop_index("ix_marketplace_products_id", table_name="marketplace_products")
    op.drop_table("marketplace_products")
