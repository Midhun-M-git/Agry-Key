"""Tests for Dynamic Regional Plugin System and Soil Survey Loader."""

from app.core.regions import district_registry
from app.core.regions.base import BaseDistrictProvider


def test_district_registry_loads_palakkad():
    provider = district_registry.get_provider("palakkad")
    assert provider is not None
    assert isinstance(provider, BaseDistrictProvider)
    assert provider.state_name == "Kerala"
    assert provider.district_name == "Palakkad"
    assert provider.language_code == "ml"


def test_district_registry_loads_coimbatore():
    provider = district_registry.get_provider("coimbatore")
    assert provider is not None
    assert isinstance(provider, BaseDistrictProvider)
    assert provider.state_name == "Tamil Nadu"
    assert provider.district_name == "Coimbatore"
    assert provider.language_code == "ta"


def test_district_registry_loads_slang_pack():
    slang = district_registry.get_slang_pack("palakkad")
    assert slang is not None
    assert "slang_mapping" in slang


def test_district_registry_loads_soil_survey_template():
    soil_data = district_registry.get_soil_survey("palakkad")
    assert soil_data is not None
    assert soil_data["state"] == "Kerala"
    assert soil_data["district"] == "Palakkad"
    assert len(soil_data["panchayaths_and_taluks"]) == 1
    assert "ph_level" in soil_data["panchayaths_and_taluks"][0]


def test_unsupported_district_returns_none():
    assert district_registry.get_provider("unknown_district") is None
    assert district_registry.get_slang_pack("unknown_district") is None
    assert district_registry.get_soil_survey("unknown_district") is None
