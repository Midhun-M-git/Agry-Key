"""Kerala State Data Provider Plugin."""

from typing import List
from app.core.regions.base import BaseStateProvider


class KeralaStateProvider(BaseStateProvider):
    """State-level provider for Kerala."""

    @property
    def state_name(self) -> str:
        return "Kerala"

    @property
    def default_language_code(self) -> str:
        return "ml"

    def get_supported_districts(self) -> List[str]:
        return ["Palakkad", "Thrissur", "Kozhikode", "Kannur", "Wayanad", "Malappuram", "Ernakulam"]
