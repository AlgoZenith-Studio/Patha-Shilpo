from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Patha-Shilpa Backend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    ENV: str = "development"

    # AI API Keys
    FAL_KEY: Optional[str] = None
    SARVAM_API_KEY: Optional[str] = None
    BHASHINI_API_KEY: Optional[str] = None
    BHASHINI_USER_ID: Optional[str] = None
    GEMINI_API_KEY: Optional[str] = None

    # Firebase Admin SDK Credentials
    FIREBASE_CREDENTIALS_JSON: Optional[str] = None

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
