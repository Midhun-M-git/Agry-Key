"""App environment configuration settings powered by Pydantic Settings."""

import os
from typing import List, Union
from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Global configuration settings for Agry-Key backend."""
    
    ENVIRONMENT: str = Field(default="production")
    ALLOW_MOCK_PAYMENT: bool = Field(default=False)
    PROJECT_NAME: str = "Agry-Key Backend"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = Field(
        default="c8b0e7d5f32a4e9b8f1d6c7b5a3e2f1d9a8c7b6e5d4c3b2a1f0e9d8c7b6a5f4e",
        min_length=32,
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200

    DATABASE_URL: str = "sqlite:///./agry_key.db"
    CORS_ORIGINS: Union[str, List[str]] = "*"

    @property
    def is_deployed(self) -> bool:
        """True for any deployed environment (staging, production, etc.); False only for local development/test."""
        return str(self.ENVIRONMENT).lower() not in ("development", "dev", "test", "testing", "local")

    @model_validator(mode="after")
    def validate_production_guards(self) -> "Settings":
        if self.is_deployed:
            if self.ALLOW_MOCK_PAYMENT:
                raise ValueError("ALLOW_MOCK_PAYMENT cannot be True in a deployed environment.")
            if self.OTP_PROVIDER.lower() in ("development", "dev", "mock"):
                raise ValueError(
                    f"OTP_PROVIDER cannot be '{self.OTP_PROVIDER}' in a deployed environment. "
                    "A verified carrier SMS integration (Twilio / Fast2SMS) must be configured."
                )
            if self.OTP_PROVIDER.lower() == "twilio":
                if not (self.TWILIO_VERIFY_SERVICE_SID or (self.TWILIO_ACCOUNT_SID and self.TWILIO_AUTH_TOKEN)):
                    raise ValueError(
                        "In a deployed environment, Twilio credentials (TWILIO_VERIFY_SERVICE_SID or "
                        "TWILIO_ACCOUNT_SID + TWILIO_AUTH_TOKEN) must be provided."
                    )
        return self

    @field_validator("SECRET_KEY")
    @classmethod
    def validate_secret_key(cls, v: str, info) -> str:
        known_defaults = {
            "c8b0e7d5f32a4e9b8f1d6c7b5a3e2f1d9a8c7b6e5d4c3b2a1f0e9d8c7b6a5f4e",
            "replace-with-a-random-secret-at-least-32-characters-long",
        }
        env = str(info.data.get("ENVIRONMENT", "development")).lower()
        is_deployed = env not in ("development", "dev", "test", "testing", "local")
        if is_deployed and v in known_defaults:
            raise ValueError(
                "In a deployed environment, SECRET_KEY must be a cryptographically secure value "
                "provided via the SECRET_KEY environment variable, not the default repository placeholder."
            )
        return v

    WEATHER_API_KEY: str = Field(default="sample_weather_key")
    GEMINI_API_KEY: str = Field(default="sample_gemini_key")
    OTP_PROVIDER: str = Field(default="twilio")
    SMS_API_KEY: str = Field(default="")
    SMS_OTP_TEMPLATE_ID: str = Field(default="")
    SMS_PROVIDER: str = Field(default="twilio")
    TWILIO_ACCOUNT_SID: str = Field(default="")
    TWILIO_AUTH_TOKEN: str = Field(default="")
    TWILIO_FROM_NUMBER: str = Field(default="")
    TWILIO_VERIFY_SERVICE_SID: str = Field(default="")
    
    # Hugging Face API keys, Microservice URLs, and GPU LLM Endpoints
    HUGGINGFACE_API_KEY: str = Field(default="sample_hf_key")
    DL_FORECAST_SERVICE_URL: str = Field(default="https://agry-key-dl-space.hf.space/api/predict")
    DL_FORECAST_SERVICE_TOKEN: str = Field(default="secret-service-token-123")
    
    # LLM Configuration (supports Hugging Face Serverless/GPU, Gemini, or local Ollama)
    LLM_PROVIDER: str = Field(default="huggingface")
    HF_INFERENCE_ENDPOINT_URL: str = Field(default="https://router.huggingface.co/v1")
    HF_MODEL_ID: str = Field(default="Qwen/Qwen2.5-72B-Instruct")
    LOCAL_LLM_URL: str = Field(default="http://localhost:11434/v1")

    # Payment Gateway (Razorpay)
    RAZORPAY_KEY_ID: str = Field(default="")
    RAZORPAY_KEY_SECRET: str = Field(default="")

    # Push Notifications
    FCM_SERVER_KEY: str = Field(default="")


    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        """Parses CORS origins string or list into a clean list of allowed origins."""
        if isinstance(v, str):
            if v == "*":
                return ["*"]
            return [i.strip() for i in v.split(",")]
        return v

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def normalize_database_url(cls, v: str) -> str:
        """Accept common PostgreSQL URLs while keeping SQLite as the dev default."""
        if v.startswith("postgres://"):
            return "postgresql+psycopg2://" + v[len("postgres://"):]
        if v.startswith("postgresql://"):
            return "postgresql+psycopg2://" + v[len("postgresql://"):]
        return v

    model_config = SettingsConfigDict(
        env_file=None if os.environ.get("ENVIRONMENT", "").lower() in ("test", "testing") else (".env", "backend/.env", "../backend/.env"),
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
