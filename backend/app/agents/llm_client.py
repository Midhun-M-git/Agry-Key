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

    UNAVAILABLE_RESPONSE = "Advisory unavailable: AI analysis could not be generated."
    FALLBACK_RESPONSE = UNAVAILABLE_RESPONSE

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

    def _has_configured_hf(self) -> bool:
        return bool(
            settings.LLM_PROVIDER in ["huggingface", "hf"]
            and settings.HUGGINGFACE_API_KEY
            and settings.HUGGINGFACE_API_KEY != "sample_hf_key"
            and settings.HF_INFERENCE_ENDPOINT_URL.strip()
        )

    def generate_response(self, prompt: str, system_message: str = "") -> str:
        """Generate a response using configured Hugging Face GPU or Gemini, retrying on transient errors."""
        # 1. Use Hugging Face if explicitly configured with a valid key
        if self._has_configured_hf():
            endpoint_url = settings.HF_INFERENCE_ENDPOINT_URL.strip()
            for attempt in range(self.max_retries):
                try:
                    resp = self._call_hf_or_openai_endpoint(endpoint_url, prompt, system_message)
                    if resp:
                        return resp
                except Exception as exc:
                    print(f"[LLM-Client] HF/GPU request failed (attempt {attempt + 1}/{self.max_retries}): {exc}")
                    if attempt < self.max_retries - 1:
                        time.sleep(2**attempt)

        # 2. Use Local LLM (Ollama) if selected
        elif settings.LLM_PROVIDER in ["ollama", "local"]:
            endpoint_url = settings.LOCAL_LLM_URL.strip()
            if endpoint_url:
                for attempt in range(self.max_retries):
                    try:
                        resp = self._call_hf_or_openai_endpoint(endpoint_url, prompt, system_message)
                        if resp:
                            return resp
                    except Exception as exc:
                        print(f"[LLM-Client] Local LLM request failed (attempt {attempt + 1}/{self.max_retries}): {exc}")
                        if attempt < self.max_retries - 1:
                            time.sleep(2**attempt)

        # 3. Use Gemini LLM if configured
        if getattr(self, "model", None):
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

        # Fail closed: never fabricate advice when AI provider fails
        return self.UNAVAILABLE_RESPONSE

    def _generate_intelligent_agricultural_strategy(self, prompt: str) -> str:
        """
        Synthesizes an intelligent, actionable 3-point agricultural strategy
        analyzing the actual prompt inputs (district, environment, input costs, forecasts, synergies).
        """
        p_low = prompt.lower()
        district = "your region"
        if "farmer in " in prompt:
            try:
                district = prompt.split("farmer in ")[1].split(".")[0].strip()
            except Exception:
                pass

        # Extract temperature and rain
        temp = "favorable"
        if "avg max temp: " in prompt:
            try:
                temp = prompt.split("avg max temp: ")[1].split("c")[0].strip() + "°C"
            except Exception:
                pass

        # Check for synergies
        has_synergy = "cow dung" in p_low or "poultry" in p_low or "synergies identified:" in p_low and "[]" not in p_low

        strategy = (
            f"### Integrated Agricultural Advisory for {district}\n\n"
            f"*(Baseline agronomic guidance — automated LLM generation unavailable)*\n\n"
            f"**1. Harvest Timing & Collective Marketing**\n"
            f"• Explore staggered harvesting and collective marketing through local Farmer Producer Organizations (FPOs) "
            f"or e-NAM mandis where available to avoid distress sales during peak harvest gluts.\n\n"
            f"**2. Cost Management & Soil Nutrition**\n"
        )

        if has_synergy:
            strategy += (
                f"• Capitalize on internal circular farm resources: properly compost available livestock manure "
                f"to supplement crop nutrition, following recommended package of practices to reduce chemical fertilizer "
                f"dependency while maintaining soil organic matter.\n"
            )
        else:
            strategy += (
                f"• Follow soil-test-based fertilizer schedules: split nitrogen/urea application across vegetative "
                f"growth phases and incorporate well-decomposed farmyard manure (FYM) to improve nutrient uptake.\n"
            )

        strategy += (
            f"\n**3. Climate & Environmental Resilience ({temp})**\n"
            f"• Utilize efficient irrigation methods (drip or sprinkler) during morning or evening hours to minimize evapotranspiration losses. "
            f"Apply organic crop residue mulching to conserve root-zone soil moisture and protect against heat stress. "
            f"Ensure field boundary drainage trenches are clear ahead of unseasonal rains."
        )

        return strategy


llm_client = LLMClient()
