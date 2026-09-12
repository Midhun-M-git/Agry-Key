"""add government schemes

Revision ID: e8f7a6b5c4d3
Revises: d7e6f5a4b3c2
Create Date: 2026-09-12 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "e8f7a6b5c4d3"
down_revision: Union[str, Sequence[str], None] = "d7e6f5a4b3c2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "government_schemes",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("code", sa.String(length=50), nullable=False),
        sa.Column("name", sa.String(length=150), nullable=False),
        sa.Column("level", sa.String(length=20), nullable=False),
        sa.Column("state", sa.String(length=50), nullable=True),
        sa.Column("category", sa.String(length=50), nullable=False),
        sa.Column("sector", sa.String(length=50), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("benefits", sa.JSON(), nullable=False),
        sa.Column("eligibility", sa.JSON(), nullable=False),
        sa.Column("application_process", sa.JSON(), nullable=False),
        sa.Column("documents", sa.JSON(), nullable=False),
        sa.Column("official_url", sa.String(length=500), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("code"),
    )
    op.create_index("ix_government_schemes_id", "government_schemes", ["id"], unique=False)
    op.create_index("ix_government_schemes_code", "government_schemes", ["code"], unique=False)
    op.create_index("ix_government_schemes_state", "government_schemes", ["state"], unique=False)
    op.create_index("ix_government_schemes_category", "government_schemes", ["category"], unique=False)
    op.create_index("ix_government_schemes_sector", "government_schemes", ["sector"], unique=False)
    op.create_index("ix_government_schemes_is_active", "government_schemes", ["is_active"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_government_schemes_is_active", table_name="government_schemes")
    op.drop_index("ix_government_schemes_sector", table_name="government_schemes")
    op.drop_index("ix_government_schemes_category", table_name="government_schemes")
    op.drop_index("ix_government_schemes_state", table_name="government_schemes")
    op.drop_index("ix_government_schemes_code", table_name="government_schemes")
    op.drop_index("ix_government_schemes_id", table_name="government_schemes")
    op.drop_table("government_schemes")
