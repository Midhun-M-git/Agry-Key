import time
import httpx
import google.generativeai as genai
from app.core.config import settings


class LLMClient:
    """
    Client for interacting with LLM providers:
    - Hugging Face GPU Inference Endpoints / Spaces (Qwen 2.5, DeepSeek-R1, Llama 3.3)
    - Local LLM via vLLM / Ollama
    - Google Gemini API
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

        if self._has_configured_gemini_key():
            try:
                genai.configure(api_key=self.api_key)
                self.model = genai.GenerativeModel(model_name=self.model_id)
            except Exception as e:
                print(f"[LLM-Client] Gemini configuration warning: {e}")

    def _has_configured_gemini_key(self) -> bool:
        return bool(self.api_key and self.api_key != "sample_gemini_key")

    def _call_hf_or_openai_endpoint(self, endpoint_url: str, prompt: str, system_message: str = "") -> str:
        """Call a Hugging Face Inference Endpoint, vLLM, or local Ollama OpenAI-compatible server."""
        headers = {"Content-Type": "application/json"}
        hf_token = settings.HUGGINGFACE_API_KEY
        if hf_token and hf_token != "sample_hf_key":
            headers["Authorization"] = f"Bearer {hf_token}"

        # Ensure url points to /chat/completions or /v1/chat/completions
        url = endpoint_url.rstrip("/")
        if not url.endswith("/chat/completions"):
            if not url.endswith("/v1"):
                url = f"{url}/v1/chat/completions"
            else:
                url = f"{url}/chat/completions"

        messages = []
        if system_message:
            messages.append({"role": "system", "content": system_message})
        messages.append({"role": "user", "content": prompt})

        payload = {
            "model": settings.HF_MODEL_ID,
            "messages": messages,
            "max_tokens": 800,
            "temperature": 0.3,
        }

        with httpx.Client(timeout=25.0) as client:
            resp = client.post(url, headers=headers, json=payload)
            resp.raise_for_status()
            data = resp.json()
            # Standard OpenAI / vLLM / TGI structure
            choices = data.get("choices", []) if isinstance(data, dict) else []
            if choices and "message" in choices[0]:
                return choices[0]["message"].get("content", "").strip()
            # Hugging Face Inference list structure: [{"generated_text": "..."}]
            if isinstance(data, list) and len(data) > 0 and isinstance(data[0], dict):
                if "generated_text" in data[0]:
                    return data[0]["generated_text"].strip()
            # Hugging Face dict structure: {"generated_text": "..."}
            if isinstance(data, dict) and "generated_text" in data:
                return data["generated_text"].strip()
            raise ValueError(f"Unexpected response structure: {data}")

    def generate_response(self, prompt: str, system_message: str = "") -> str:
        """Generate a response using configured Hugging Face GPU or Gemini, retrying on transient errors."""
        # 1. Check if Hugging Face or Local GPU endpoint is specified
        endpoint_url = settings.HF_INFERENCE_ENDPOINT_URL.strip()
        if not endpoint_url and settings.LLM_PROVIDER in ["ollama", "local"]:
            endpoint_url = settings.LOCAL_LLM_URL.strip()

        if endpoint_url:
            for attempt in range(self.max_retries):
                try:
                    resp = self._call_hf_or_openai_endpoint(endpoint_url, prompt, system_message)
                    if resp:
                        return resp
                except Exception as exc:
                    print(f"[LLM-Client] HF/GPU request failed (attempt {attempt + 1}/{self.max_retries}): {exc}")
                    if attempt < self.max_retries - 1:
                        time.sleep(2**attempt)

        # 2. Try Gemini LLM if configured
        if self.model:
            contents = f"{system_message}\n\n{prompt}" if system_message else prompt
            for attempt in range(self.max_retries):
                try:
                    response = self.model.generate_content(
                        contents,
                        generation_config={
                            "max_output_tokens": 800,
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
