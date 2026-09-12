import pytest
from unittest.mock import patch, MagicMock
from app.agents.data_checker import data_checker_agent
from app.agents import llm_client as llm_client_module
from app.agents.llm_client import llm_client
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


def test_advisory_and_verifier_call_llm():
    intelligence = {
        "district": "Palakkad",
        "environment": {
            "climate": {
                "avg_max_temperature_c": 31.0,
                "total_precipitation_mm": 200,
                "climate_condition": "Favorable",
            }
        },
        "economics": {
            "input_costs": {
                "diesel_price_per_liter": 94.5,
                "labour_rate_per_day": 850.0,
                "urea_bag_price": 266.5,
            }
        },
    }
    portfolio = {"plots": [{"crops_currently_grown": ["Paddy"]}]}

    with patch.object(
        advisory_agent.data_checker,
        "gather_district_data",
        return_value=intelligence,
    ), patch.object(
        advisory_agent.dl_client,
        "get_price_forecast",
        return_value={"commodity": "Paddy", "predicted_trend_30_days": "UP"},
    ), patch.object(
        advisory_agent.llm,
        "generate_response",
        return_value="advisory response",
    ) as advisory_llm:
        assert (
            advisory_agent.generate_strategy(1, "Palakkad", 10.7, 76.6, portfolio)
            == "advisory response"
        )
        advisory_llm.assert_called_once()

    with patch.object(
        verifier_agent.llm,
        "generate_response",
        return_value="verified response",
    ) as verifier_llm:
        assert (
            verifier_agent.verify_and_localize("advisory response", "Kerala", "Palakkad")
            == "verified response"
        )
        verifier_llm.assert_called_once()


def test_llm_retries_then_returns_fallback():
    client = object.__new__(llm_client_module.LLMClient)
    client.model = MagicMock()
    client.max_retries = 2
    client.model.generate_content.side_effect = RuntimeError("temporary failure")

    with patch("app.agents.llm_client.time.sleep") as sleep:
        result = client.generate_response("prompt")

    assert result == llm_client_module.LLMClient.FALLBACK_RESPONSE
    assert client.model.generate_content.call_count == 2
    assert sleep.call_count == 1
