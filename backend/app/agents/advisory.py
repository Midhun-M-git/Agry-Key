from typing import Dict, Any, List
from app.agents.llm_client import llm_client
from app.services.dl_forecasting_client import dl_forecasting_client
from app.agents.data_checker import data_checker_agent

class AdvisoryAgent:
    """
    The Strategist: Calculates net profit, identifies synergies between farm
    activities (e.g. dairy manure for crops), and queries the LLM for a final strategy.
    """

    def __init__(self):
        self.llm = llm_client
        self.dl_client = dl_forecasting_client
        self.data_checker = data_checker_agent

    def generate_strategy(self, farmer_profile_id: int, district: str, lat: float, lng: float, farm_portfolio: Dict[str, Any]) -> str:
        """
        Main pipeline to generate a farming strategy.
        """
        # 1. Gather primary intelligence
        intelligence = self.data_checker.gather_district_data(district, lat, lng)
        
        # 2. Get DL Forecasts for the crops the farmer grows
        forecasts = []
        if "plots" in farm_portfolio:
            for plot in farm_portfolio["plots"]:
                for crop in plot.get("crops_currently_grown", []):
                    forecast = self.dl_client.get_price_forecast(district, crop)
                    forecasts.append(forecast)
                    
        # 3. Identify Synergies (Hardcoded heuristic examples)
        synergies = self._calculate_synergies(farm_portfolio)
        
        # 4. Construct prompt for the LLM
        prompt = self._construct_prompt(intelligence, forecasts, synergies, farm_portfolio)
        
        system_msg = (
            "You are an expert agricultural economist and agronomist advising an Indian farmer. "
            "Be highly analytical, concise, and provide actionable financial advice based on the data provided."
        )
        
        # 5. Generate Strategy
        raw_strategy = self.llm.generate_response(prompt, system_message=system_msg)
        return raw_strategy
        
    def _calculate_synergies(self, portfolio: Dict[str, Any]) -> List[str]:
        synergies = []
        has_cattle = any(l.get("animal_type", "").lower() in ["cow", "buffalo"] for l in portfolio.get("livestock", []))
        has_crops = len(portfolio.get("plots", [])) > 0
        has_poultry = len(portfolio.get("poultry", [])) > 0
        has_aqua = len(portfolio.get("aquaculture", [])) > 0
        
        if has_cattle and has_crops:
            synergies.append("Cow dung can be used as organic fertilizer for the crops, saving on urea costs.")
        if has_poultry and has_aqua:
            synergies.append("Poultry droppings can be used as feed for aquaculture ponds, creating a circular system.")
            
        return synergies

    def _construct_prompt(self, intel: Dict, forecasts: List[Dict], synergies: List[str], portfolio: Dict) -> str:
        climate = intel["environment"]["climate"]
        costs = intel["economics"]["input_costs"]
        
        prompt = f"""
        Generate a farming strategy for a farmer in {intel['district']}.
        
        FARM PORTFOLIO:
        {portfolio}
        
        ENVIRONMENT:
        - Avg Max Temp: {climate['avg_max_temperature_c']}C
        - Total Rain (30d): {climate['total_precipitation_mm']}mm
        - Condition: {climate['climate_condition']}
        
        INPUT COSTS:
        - Diesel: Rs {costs['diesel_price_per_liter']}/L
        - Labour: Rs {costs['labour_rate_per_day']}/day
        - Urea: Rs {costs['urea_bag_price']}/bag
        
        MARKET FORECASTS:
        {forecasts}
        
        SYNERGIES IDENTIFIED:
        {synergies}
        
        Please provide a 3-point strategy focusing on:
        1. Profit maximization based on price forecasts.
        2. Cost reduction using the synergies.
        3. Climate resilience based on the current environment.
        """
        return prompt

advisory_agent = AdvisoryAgent()
