from typing import Literal

from pydantic import BaseModel, Field


class ListingRequest(BaseModel):
    transcript: str
    craft_type: str
    material: str | None = None
    colors: list[str] = Field(default_factory=list)
    hours_of_work: int | None = None


class ListingResponse(BaseModel):
    title: str
    title_hi: str
    description: str
    description_hi: str
    tags: list[str]
    colors: list[str]
    material: str
    craft_type: str
    generated_by: Literal["gemini", "template"]


class VoiceResponse(BaseModel):
    transcript: str
    language_code: str
    confidence: float
    tier: Literal[1, 2]
    source: Literal["sarvam", "bhashini"]


class ImageResponse(BaseModel):
    image_url: str
    background_removed: bool
    enhanced: bool
    quality_score: float
    degraded: bool
