"""add community posts, comments, and likes

Revision ID: a0b1c2d3e4f5
Revises: f9a8b7c6d5e4
Create Date: 2026-09-12 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "a0b1c2d3e4f5"
down_revision: Union[str, Sequence[str], None] = "f9a8b7c6d5e4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "community_posts",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("author_id", sa.Integer(), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("district", sa.String(length=100), nullable=True),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["author_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_community_posts_id", "community_posts", ["id"], unique=False)
    op.create_index("ix_community_posts_author_id", "community_posts", ["author_id"], unique=False)
    op.create_index("ix_community_posts_district", "community_posts", ["district"], unique=False)

    op.create_table(
        "community_comments",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("post_id", sa.Integer(), nullable=False),
        sa.Column("author_id", sa.Integer(), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["author_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["post_id"], ["community_posts.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_community_comments_id", "community_comments", ["id"], unique=False)
    op.create_index("ix_community_comments_post_id", "community_comments", ["post_id"], unique=False)
    op.create_index("ix_community_comments_author_id", "community_comments", ["author_id"], unique=False)

    op.create_table(
        "community_post_likes",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("post_id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["post_id"], ["community_posts.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("post_id", "user_id", name="uq_community_post_like_user"),
    )
    op.create_index("ix_community_post_likes_id", "community_post_likes", ["id"], unique=False)
    op.create_index("ix_community_post_likes_post_id", "community_post_likes", ["post_id"], unique=False)
    op.create_index("ix_community_post_likes_user_id", "community_post_likes", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_community_post_likes_user_id", table_name="community_post_likes")
    op.drop_index("ix_community_post_likes_post_id", table_name="community_post_likes")
    op.drop_index("ix_community_post_likes_id", table_name="community_post_likes")
    op.drop_table("community_post_likes")
    op.drop_index("ix_community_comments_author_id", table_name="community_comments")
    op.drop_index("ix_community_comments_post_id", table_name="community_comments")
    op.drop_index("ix_community_comments_id", table_name="community_comments")
    op.drop_table("community_comments")
    op.drop_index("ix_community_posts_district", table_name="community_posts")
    op.drop_index("ix_community_posts_author_id", table_name="community_posts")
    op.drop_index("ix_community_posts_id", table_name="community_posts")
    op.drop_table("community_posts")
