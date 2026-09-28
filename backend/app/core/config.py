"""App environment configuration settings powered by Pydantic Settings."""

from typing import List, Union
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Global configuration settings for Agry-Key backend."""
    
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

    WEATHER_API_KEY: str = Field(default="sample_weather_key")
    GEMINI_API_KEY: str = Field(default="sample_gemini_key")
    OTP_PROVIDER: str = Field(default="development")
    SMS_API_KEY: str = Field(default="")
    SMS_OTP_TEMPLATE_ID: str = Field(default="")
    SMS_PROVIDER: str = Field(default="msg91")
    TWILIO_ACCOUNT_SID: str = Field(default="")
    TWILIO_AUTH_TOKEN: str = Field(default="")
    TWILIO_FROM_NUMBER: str = Field(default="")
    
    # Hugging Face API keys and Microservice URLs
    HUGGINGFACE_API_KEY: str = Field(default="sample_hf_key")
    DL_FORECAST_SERVICE_URL: str = Field(default="https://agry-key-dl-space.hf.space/api/predict")
    DL_FORECAST_SERVICE_TOKEN: str = Field(default="secret-service-token-123")

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
        env_file=(".env", "backend/.env", "../backend/.env"),
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
