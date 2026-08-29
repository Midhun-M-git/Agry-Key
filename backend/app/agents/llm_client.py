from huggingface_hub import InferenceClient
from app.core.config import settings

class LLMClient:
    """
    Client for interacting with Hugging Face's Serverless Inference API.
    Used by the Advisory and Verifier agents to generate intelligent responses.
    """
    
    def __init__(self):
        # We use a highly capable open-source model like Llama-3 or Qwen2.5
        # that is hosted for free on Hugging Face Serverless API.
        self.model_id = "meta-llama/Meta-Llama-3-8B-Instruct" 
        
        # Initialize the client. If the key is just the sample, it might fail in production,
        # but will work if the user provides a real HF token.
        self.client = InferenceClient(
            model=self.model_id,
            token=settings.HUGGINGFACE_API_KEY
        )
        
    def generate_response(self, prompt: str, system_message: str = "") -> str:
        """
        Sends a prompt to the LLM and returns the text response.
        """
        messages = []
        if system_message:
            messages.append({"role": "system", "content": system_message})
            
        messages.append({"role": "user", "content": prompt})
        
        try:
            print(f"[LLM-Client] Sending request to {self.model_id}...")
            response = self.client.chat_completion(
                messages=messages,
                max_tokens=500,
                temperature=0.3  # Low temperature for factual, analytical advice
            )
            return response.choices[0].message.content
        except Exception as e:
            print(f"[LLM-Client] Error calling Hugging Face API: {e}")
            return (
                "Fallback Advisory: Maintain current farming operations. "
                "Ensure proper irrigation and monitor for pests. "
                "(Detailed AI analysis currently unavailable)"
            )

llm_client = LLMClient()
