import json
import os
from app.agents.llm_client import llm_client

class VerifierAgent:
    """
    The Auditor: Uses the LLM in a second pass to audit the Advisory Agent's output.
    Ensures the advice is safe, culturally appropriate, and injects regional slang.
    """

    def __init__(self):
        self.llm = llm_client

    def verify_and_localize(self, raw_strategy: str, state: str, district: str) -> str:
        """
        Audits the raw strategy and localizes it using the regional slang pack.
        """
        # Load slang pack for the district (Fallback if not found)
        slang_mapping = self._load_regional_slang(state, district)
        
        system_msg = (
            "You are a strict agricultural auditor and a native translator. "
            "Your job is to read the provided farming strategy and ensure it contains NO dangerous advice "
            "(e.g., using banned chemicals). Then, rewrite the strategy in English but heavily inject "
            "the provided regional slang/vocabulary so it sounds like it was written by a local farmer."
        )
        
        prompt = f"""
        RAW STRATEGY:
        {raw_strategy}
        
        REGIONAL SLANG DICTIONARY for {district}, {state}:
        {json.dumps(slang_mapping, indent=2)}
        
        TASKS:
        1. If the strategy suggests anything scientifically dangerous or illegal in India, remove it.
        2. Rewrite the strategy using the regional slang dictionary replacing standard English words where applicable.
        3. Keep the output concise and ready to be read aloud by a Voice Engine.
        """
        
        print(f"[Verifier] Auditing and localizing strategy for {district}...")
        final_strategy = self.llm.generate_response(prompt, system_message=system_msg)
        return final_strategy

    def _load_regional_slang(self, state: str, district: str) -> dict:
        """
        Attempts to load the slang.json for the region.
        """
        # We will mock the Palakkad/Coimbatore slang if the file doesn't exist for safety
        base_path = f"app/core/regions/{state.lower()}/{district.lower()}/slang.json"
        
        if os.path.exists(base_path):
            try:
                with open(base_path, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception:
                pass
                
        # Mock fallback based on our Phase 2 planning
        if district.lower() == "palakkad":
            return {
                "field": "Padam",
                "cow": "Pasu",
                "water": "Vellam",
                "fertilizer": "Valam",
                "harvest": "Koythu",
                "profit": "Laabham"
            }
        return {}

verifier_agent = VerifierAgent()
