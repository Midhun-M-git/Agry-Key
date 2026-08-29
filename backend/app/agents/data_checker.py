from typing import Dict, Any
from app.services.data_fetcher import data_fetcher_service

class DataCheckerAgent:
    """
    The Gatherer: Responsible for collecting all primary environmental and economic
    data required for the Advisory Engine.
    """

    def __init__(self):
        self.fetcher = data_fetcher_service

    def gather_district_data(self, district: str, latitude: float, longitude: float) -> Dict[str, Any]:
        """
        Gathers all real-time and historical data for a specific district/location.
        """
        print(f"[DataChecker] Gathering intelligence for {district} at ({latitude}, {longitude})...")
        
        # 1. Fetch Climate Baseline
        climate_data = self.fetcher.fetch_climate_baseline(latitude, longitude)
        
        # 2. Fetch Live Market Prices (Mocked for now)
        market_prices = self.fetcher.fetch_mock_mandi_prices(district)
        
        # 3. Fetch Input Costs (Fuel, Labour, Fertilizer)
        input_costs = self.fetcher.fetch_mock_input_costs(district)
        
        return {
            "district": district,
            "coordinates": {"lat": latitude, "lng": longitude},
            "environment": {
                "climate": climate_data
            },
            "economics": {
                "market_prices": market_prices,
                "input_costs": input_costs
            }
        }

data_checker_agent = DataCheckerAgent()
