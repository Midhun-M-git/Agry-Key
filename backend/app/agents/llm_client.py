import time

import google.generativeai as genai

from app.core.config import settings


class LLMClient:
    """
    Client for interacting with Google's Gemini API.
    Used by the Advisory and Verifier agents to generate intelligent responses.
    """

    FALLBACK_RESPONSE = (
        "Fallback Advisory: Maintain current farming operations. "
        "Ensure proper irrigation and monitor for pests. "
        "(Detailed AI analysis currently unavailable)"
    )

    def __init__(self, model_id: str = "gemini-1.5-flash", max_retries: int = 3):
        self.model_id = model_id
        self.max_retries = max(1, max_retries)
        self.api_key = settings.GEMINI_API_KEY.strip()
        self.model = None

        if self._has_configured_key():
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel(model_name=self.model_id)

    def _has_configured_key(self) -> bool:
        return bool(self.api_key and self.api_key != "sample_gemini_key")

    def generate_response(self, prompt: str, system_message: str = "") -> str:
        """Generate a response from Gemini, retrying transient failures."""
        if not self.model:
            return self.FALLBACK_RESPONSE

        contents = f"{system_message}\n\n{prompt}" if system_message else prompt

        for attempt in range(self.max_retries):
            try:
                response = self.model.generate_content(
                    contents,
                    generation_config={
                        "max_output_tokens": 500,
                        "temperature": 0.3,
                    },
                )
                response_text = getattr(response, "text", "").strip()
                if response_text:
                    return response_text
                raise ValueError("Gemini returned an empty response")
            except Exception as exc:
                print(
                    f"[LLM-Client] Gemini request failed "
                    f"(attempt {attempt + 1}/{self.max_retries}): {exc}"
                )
                if attempt < self.max_retries - 1:
                    time.sleep(2**attempt)

        return self.FALLBACK_RESPONSE


llm_client = LLMClient()
