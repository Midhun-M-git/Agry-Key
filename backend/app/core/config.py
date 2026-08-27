"""App environment configuration settings powered by Pydantic Settings."""

from typing import List, Union
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Global configuration settings for Agry-Key backend."""
    
    PROJECT_NAME: str = "Agry-Key Backend"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "agry-key-super-secret-key-change-in-production-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200

    DATABASE_URL: str = "sqlite:///./agry_key.db"
    CORS_ORIGINS: Union[str, List[str]] = "*"

    WEATHER_API_KEY: str = Field(default="sample_weather_key")
    GEMINI_API_KEY: str = Field(default="sample_gemini_key")

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        """Parses CORS origins string or list into a clean list of allowed origins."""
        if isinstance(v, str):
            if v == "*":
                return ["*"]
            return [i.strip() for i in v.split(",")]
        return v

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
