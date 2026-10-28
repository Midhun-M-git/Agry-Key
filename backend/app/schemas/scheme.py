"""Request and response schemas for government schemes."""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class SchemeResponse(BaseModel):
    id: int
    code: str
    name: str
    level: str
    state: Optional[str]
    category: str
    sector: str
    description: str
    benefits: List[str]
    eligibility: List[str]
    application_process: List[str]
    documents: List[str]
    official_url: Optional[str] = None
    source_url: Optional[str] = None
    last_checked_at: Optional[datetime] = None
    checked_by: Optional[str] = None
    verification_status: str = "unverified"
    translations: Optional[dict] = None
    is_active: bool = True