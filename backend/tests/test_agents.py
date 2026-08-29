import pytest
from unittest.mock import patch, MagicMock
from app.agents.data_checker import data_checker_agent
from app.services.dl_forecasting_client import dl_forecasting_client
from app.agents.advisory import advisory_agent
from app.agents.verifier import verifier_agent

def test_data_checker_structure():
    """Sanity Check: Ensures DataChecker returns the correct nested structure."""
    with patch('app.services.data_fetcher.DataFetcherService.fetch_climate_baseline') as mock_climate:
        mock_climate.return_value = {"avg_max_temperature_c": 31.0, "total_precipitation_mm": 200, "climate_condition": "Favorable"}
        
        result = data_checker_agent.gather_district_data("Palakkad", 10.7, 76.6)
        
        assert "environment" in result
        assert "economics" in result
        assert result["district"] == "Palakkad"
        assert result["environment"]["climate"]["climate_condition"] == "Favorable"

def test_dl_client_fallback_mechanism():
    """Regression/Sanity: Ensures DL Client doesn't crash on timeout and returns STABLE fallback."""
    # Force a timeout exception using requests.exceptions.Timeout
    import requests
    with patch('requests.post', side_effect=requests.exceptions.Timeout("Connection Timeout")):
        result = dl_forecasting_client.get_price_forecast("Palakkad", "Paddy")
        
        assert result["commodity"] == "Paddy"
        assert result["predicted_trend_30_days"] == "STABLE"
        assert "Fallback" in result["message"]

def test_advisory_synergy_logic():
    """Unit Test: Verifies the business logic for calculating synergies."""
    mock_portfolio = {
        "plots": [{"crops_currently_grown": ["Paddy"]}],
        "livestock": [{"animal_type": "Cow"}],
        "poultry": [],
        "aquaculture": []
    }
    
    synergies = advisory_agent._calculate_synergies(mock_portfolio)
    assert len(synergies) == 1
    assert "Cow dung" in synergies[0]

def test_verifier_slang_loading():
    """Unit Test: Verifies the fallback slang dictionary loads correctly."""
    with patch('os.path.exists', return_value=False):
        slang = verifier_agent._load_regional_slang("Kerala", "Palakkad")
        assert "field" in slang
        assert slang["field"] == "Padam"
