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


class TtsRequest(BaseModel):
    """Text to read aloud — the Hindi price rationale, per PRD §6 step 4.

    `max_length` is a cost guard, not a model limit: TTS is billed per
    character and this endpoint is reachable by any signed-in user. 1000
    characters comfortably covers a price rationale or a listing description
    (itself capped at 600 by TRD §4.1).
    """

    text: str = Field(min_length=1, max_length=1000)
    language_code: str = "hi"
    # Sarvam selects a named voice; Bhashini takes a gender. Both are
    # optional — each service falls back to its own default.
    speaker: str | None = None
    gender: Literal["female", "male"] = "female"


class TtsResponse(BaseModel):
    """Base64 audio rather than a raw body.

    Costs ~33% more bytes than streaming the audio, which is acceptable for a
    one-sentence rationale, and keeps `source` in the payload so the client
    can tell an online readback from the `flutter_tts` fallback — the same
    shape every other AI response uses.
    """

    audio: str
    content_type: str
    language_code: str
    source: Literal["sarvam", "bhashini"]
