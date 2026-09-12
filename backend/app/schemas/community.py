"""Request and response schemas for community discussions."""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class PostCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=5000)
    district: Optional[str] = Field(default=None, max_length=100)
    image_url: Optional[str] = Field(default=None, max_length=500)


class CommentCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class CommentResponse(BaseModel):
    id: int
    post_id: int
    author_id: int
    author_name: Optional[str]
    content: str
    created_at: datetime


class PostResponse(BaseModel):
    id: int
    author_id: int
    author_name: Optional[str]
    content: str
    district: Optional[str]
    image_url: Optional[str]
    like_count: int
    comment_count: int
    liked_by_current_user: bool
    created_at: datetime
    updated_at: datetime
    comments: List[CommentResponse] = []


class PostFeedResponse(BaseModel):
    items: List[PostResponse]
    page: int
    page_size: int
    total: int
    pages: int


class LikeResponse(BaseModel):
    liked: bool
    like_count: int