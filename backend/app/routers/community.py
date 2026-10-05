"""Community discussion, comment, and like API routes."""

from math import ceil
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.community import Comment, Post, PostLike
from app.models.user import User
from app.routers.auth import get_current_user, get_optional_user
from app.schemas.community import (
    CommentCreate,
    CommentResponse,
    LikeResponse,
    PostCreate,
    PostFeedResponse,
    PostResponse,
)

router = APIRouter(prefix="/community", tags=["Community"])


def _get_post(post_id: int, db: Session) -> Post:
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community post not found")
    return post


def _author_name(author_id: int, db: Session) -> Optional[str]:
    author = db.query(User).filter(User.id == author_id).first()
    return author.full_name if author else None


def _comment_response(comment: Comment, db: Session) -> CommentResponse:
    return CommentResponse(
        id=comment.id,
        post_id=comment.post_id,
        author_id=comment.author_id,
        author_name=_author_name(comment.author_id, db),
        content=comment.content,
        created_at=comment.created_at,
    )


def _post_response(
    post: Post, current_user: Optional[User], db: Session, include_comments: bool = False
) -> PostResponse:
    like_count = db.query(func.count(PostLike.id)).filter(PostLike.post_id == post.id).scalar() or 0
    comment_count = db.query(func.count(Comment.id)).filter(Comment.post_id == post.id).scalar() or 0
    liked = False
    if current_user:
        liked = (
            db.query(PostLike)
            .filter(PostLike.post_id == post.id, PostLike.user_id == current_user.id)
            .first()
            is not None
        )
    comments = []
    if include_comments:
        comments = [
            _comment_response(comment, db)
            for comment in db.query(Comment)
            .filter(Comment.post_id == post.id)
            .order_by(Comment.created_at.asc())
            .all()
        ]
    return PostResponse(
        id=post.id,
        author_id=post.author_id,
        author_name=_author_name(post.author_id, db) or "Kisan Mitra",
        content=post.content,
        district=post.district,
        image_url=post.image_url,
        like_count=int(like_count),
        comment_count=int(comment_count),
        liked_by_current_user=liked,
        created_at=post.created_at,
        updated_at=post.updated_at,
        comments=comments,
    )


def _seed_community_posts_if_empty(db: Session) -> None:
    """Seed helpful farmer advisory discussions if community table is empty."""
    if db.query(Post).count() > 0:
        return
    admin_user = db.query(User).first()
    admin_id = admin_user.id if admin_user else 1

    sample_posts = [
        {
            "content": "Rice crop showing yellow leaves and brown spots in Palakkad. Any organic solution to control blast?",
            "district": "Palakkad",
            "comments": [
                "Spray Pseudomonas fluorescens at 10g per liter of water during morning hours.",
                "Ensure proper drainage and avoid excess nitrogen fertilizer for the next 2 weeks.",
            ],
        },
        {
            "content": "Tomato wholesale price reached ₹38/kg in local APMC Mandi today! Strong demand for hybrid varieties.",
            "district": "Wayanad",
            "comments": [
                "Great news! Prices were down last month.",
            ],
        },
        {
            "content": "Best organic fertilizer schedule for Nendran banana plantation before monsoon arrival?",
            "district": "Thrissur",
            "comments": [
                "Apply 10 kg cow dung manure per pit along with 500g neem cake and wood ash.",
            ],
        },
    ]

    for p in sample_posts:
        post = Post(author_id=admin_id, content=p["content"], district=p["district"])
        db.add(post)
        db.flush()
        for c in p["comments"]:
            comment = Comment(post_id=post.id, author_id=admin_id, content=c)
            db.add(comment)
    db.commit()


@router.post("/posts", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
def create_post(
    req: PostCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a community post for the authenticated user."""
    post = Post(author_id=current_user.id, **req.model_dump())
    db.add(post)
    db.commit()
    db.refresh(post)
    return _post_response(post, current_user, db)


@router.get("/posts", response_model=PostFeedResponse)
def list_posts(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    district: Optional[str] = Query(default=None),
    current_user: Optional[User] = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    """Return a paginated community feed, optionally limited to a district."""
    _seed_community_posts_if_empty(db)
    query = db.query(Post)
    if district:
        query = query.filter(Post.district.ilike(district.strip()))
    total = query.count()
    posts = (
        query.order_by(Post.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    return PostFeedResponse(
        items=[_post_response(post, current_user, db) for post in posts],
        page=page,
        page_size=page_size,
        total=total,
        pages=ceil(total / page_size) if total else 0,
    )


@router.get("/posts/{post_id}", response_model=PostResponse)
def get_post(
    post_id: int,
    current_user: Optional[User] = Depends(get_optional_user),
    db: Session = Depends(get_db),
):
    """Return a post with its comments and engagement state."""
    return _post_response(_get_post(post_id, db), current_user, db, include_comments=True)


@router.post("/posts/{post_id}/comments", response_model=CommentResponse, status_code=status.HTTP_201_CREATED)
def add_comment(
    post_id: int,
    req: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add a comment to an existing community post."""
    _get_post(post_id, db)
    comment = Comment(post_id=post_id, author_id=current_user.id, content=req.content)
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return _comment_response(comment, db)


@router.post("/posts/{post_id}/like", response_model=LikeResponse)
def like_post(
    post_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Like a post; repeated requests from one user are idempotent."""
    _get_post(post_id, db)
    existing = (
        db.query(PostLike)
        .filter(PostLike.post_id == post_id, PostLike.user_id == current_user.id)
        .first()
    )
    if not existing:
        db.add(PostLike(post_id=post_id, user_id=current_user.id))
        db.commit()
    like_count = db.query(func.count(PostLike.id)).filter(PostLike.post_id == post_id).scalar() or 0
    return LikeResponse(liked=True, like_count=int(like_count))