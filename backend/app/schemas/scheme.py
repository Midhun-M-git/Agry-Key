"""Request and response schemas for government schemes."""

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
    official_url: Optional[str]