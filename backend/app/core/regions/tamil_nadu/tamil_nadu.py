"""Tamil Nadu State Provider."""

from typing import List
from app.core.regions.base import BaseStateProvider


class TamilNaduStateProvider(BaseStateProvider):
    """State-level provider for Tamil Nadu."""

    @property
    def state_name(self) -> str:
        return "Tamil Nadu"

    @property
    def default_language_code(self) -> str:
        return "ta"

    def get_supported_districts(self) -> List[str]:
        return ["Coimbatore", "Tiruppur", "Erode", "Karur", "Madurai", "Salem", "Chennai"]
