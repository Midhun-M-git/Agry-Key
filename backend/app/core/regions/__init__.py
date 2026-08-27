"""Dynamic District Provider & Regional Data Registry.

Folder structure convention for regional developers:

    app/core/regions/
    └── <state>/
        ├── <state>.py              ← State-level provider
        └── <district>/
            ├── district.py         ← District dataset provider
            ├── slang.json          ← Regional dialect slang pack
            └── soil_survey.json    ← Ground soil survey dataset (added by regional survey developers)

The registry auto-discovers and registers any new state/district
and automatically loads all JSON datasets (`slang.json`, `soil_survey.json`)
added by regional developers — no code changes required!
"""

import json
import importlib.util
from pathlib import Path
from typing import Dict, List, Optional, Any

from app.core.regions.base import BaseDistrictProvider


class DistrictRegionRegistry:
    """Auto-discovers and registers all state/district providers and regional survey data."""

    def __init__(self):
        self._providers: Dict[str, BaseDistrictProvider] = {}
        self._slang_packs: Dict[str, dict] = {}
        self._soil_surveys: Dict[str, dict] = {}
        self._scan()

    def _scan(self):
        regions_dir = Path(__file__).parent
        for state_dir in sorted(regions_dir.iterdir()):
            if not state_dir.is_dir() or state_dir.name.startswith("_"):
                continue
            for district_dir in sorted(state_dir.iterdir()):
                if not district_dir.is_dir() or district_dir.name.startswith("_"):
                    continue
                district_key = district_dir.name.lower()
                self._try_load_district(district_key, district_dir)
                self._try_load_slang(district_key, district_dir)
                self._try_load_soil_survey(district_key, district_dir)

    def _try_load_district(self, district_key: str, district_dir: Path):
        district_file = district_dir / "district.py"
        if not district_file.exists():
            return
        try:
            module_name = f"regions.{district_dir.parent.name}.{district_dir.name}.district"
            spec = importlib.util.spec_from_file_location(module_name, district_file)
            if spec and spec.loader:
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                for attr_name in dir(module):
                    attr = getattr(module, attr_name)
                    if (
                        isinstance(attr, type)
                        and issubclass(attr, BaseDistrictProvider)
                        and attr is not BaseDistrictProvider
                    ):
                        self._providers[district_key] = attr()
        except Exception:
            pass

    def _try_load_slang(self, district_key: str, district_dir: Path):
        slang_file = district_dir / "slang.json"
        if not slang_file.exists():
            return
        try:
            with open(slang_file, "r", encoding="utf-8") as f:
                self._slang_packs[district_key] = json.load(f)
        except Exception:
            pass

    def _try_load_soil_survey(self, district_key: str, district_dir: Path):
        soil_file = district_dir / "soil_survey.json"
        if not soil_file.exists():
            return
        try:
            with open(soil_file, "r", encoding="utf-8") as f:
                self._soil_surveys[district_key] = json.load(f)
        except Exception:
            pass

    def get_provider(self, district: str) -> Optional[BaseDistrictProvider]:
        return self._providers.get(district.lower())

    def get_slang_pack(self, district: str) -> Optional[dict]:
        return self._slang_packs.get(district.lower())

    def get_soil_survey(self, district: str) -> Optional[dict]:
        """Returns regional ground soil survey data added by regional developers."""
        return self._soil_surveys.get(district.lower())

    def list_supported_districts(self) -> List[str]:
        return list(self._providers.keys())


district_registry = DistrictRegionRegistry()
