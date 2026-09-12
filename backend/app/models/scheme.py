"""Government agriculture scheme records."""

from typing import List, Optional

from sqlalchemy import JSON, Boolean, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Scheme(Base):
    """A central or state government scheme available to farmers."""

    __tablename__ = "government_schemes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    code: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    level: Mapped[str] = mapped_column(String(20), nullable=False, default="CENTRAL")
    state: Mapped[Optional[str]] = mapped_column(String(50), nullable=True, index=True)
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    sector: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    benefits: Mapped[List[str]] = mapped_column(JSON, nullable=False, default=list)
    eligibility: Mapped[List[str]] = mapped_column(JSON, nullable=False, default=list)
    application_process: Mapped[List[str]] = mapped_column(JSON, nullable=False, default=list)
    documents: Mapped[List[str]] = mapped_column(JSON, nullable=False, default=list)
    official_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True, index=True)