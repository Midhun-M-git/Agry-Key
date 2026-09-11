"""Database connection manager and SQLAlchemy session lifecycle handlers."""

from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import settings


class Base(DeclarativeBase):
    """Base declarative class for all SQLAlchemy ORM models."""
    pass


is_sqlite = settings.DATABASE_URL.startswith("sqlite")
engine_options = {"pool_pre_ping": True}

if is_sqlite:
    # SQLite is the zero-setup local development database.
    engine_options["connect_args"] = {"check_same_thread": False}

engine = create_engine(settings.DATABASE_URL, **engine_options)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    """Provides a transactional database session for FastAPI request lifecycles."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
