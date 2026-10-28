"""add_scheme_verification_metadata_and_nullable_grades

Revision ID: 3c59462803f9
Revises: ff2d84f67abe
Create Date: 2026-10-28 22:02:03.951463

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '3c59462803f9'
down_revision: Union[str, Sequence[str], None] = 'ff2d84f67abe'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    with op.batch_alter_table('government_schemes', schema=None) as batch_op:
        batch_op.add_column(sa.Column('source_url', sa.String(length=500), nullable=True))
        batch_op.add_column(sa.Column('last_checked_at', sa.DateTime(timezone=True), nullable=True))
        batch_op.add_column(sa.Column('checked_by', sa.String(length=100), nullable=True))
        batch_op.add_column(sa.Column('verification_status', sa.String(length=20), server_default='unverified', nullable=False))
        batch_op.add_column(sa.Column('translations', sa.JSON(), nullable=True))

    with op.batch_alter_table('marketplace_products', schema=None) as batch_op:
        batch_op.alter_column('sector',
               existing_type=sa.String(length=30),
               nullable=True)
        batch_op.alter_column('quality_grade',
               existing_type=sa.String(length=10),
               nullable=True)


def downgrade() -> None:
    """Downgrade schema."""
    with op.batch_alter_table('marketplace_products', schema=None) as batch_op:
        batch_op.alter_column('quality_grade',
               existing_type=sa.String(length=10),
               nullable=False)
        batch_op.alter_column('sector',
               existing_type=sa.String(length=30),
               nullable=False)

    with op.batch_alter_table('government_schemes', schema=None) as batch_op:
        batch_op.drop_column('translations')
        batch_op.drop_column('verification_status')
        batch_op.drop_column('checked_by')
        batch_op.drop_column('last_checked_at')
        batch_op.drop_column('source_url')
