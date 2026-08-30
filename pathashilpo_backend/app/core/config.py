from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # AI services
    GEMINI_API_KEY: str = ""
    BHASHINI_API_KEY: str = ""
    BHASHINI_USER_ID: str = ""
    SARVAM_API_KEY: str = ""
    FAL_KEY: str = ""

    # Firebase
    FIREBASE_SERVICE_ACCOUNT: str = ""
    FIREBASE_PROJECT_ID: str = ""

    # App
    ENV: str = "dev"
    PORT: int = 8000
    CORS_ORIGINS: str = "http://localhost:3000"

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
