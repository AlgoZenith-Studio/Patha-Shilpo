import base64

import httpx

from app.core.config import get_settings

BASE_URL = "https://api.sarvam.ai"
TIMEOUT = 10.0


class SarvamError(Exception):
    pass


def _headers() -> dict:
    settings = get_settings()
    if not settings.SARVAM_API_KEY:
        raise SarvamError("SARVAM_API_KEY not configured")
    return {"api-subscription-key": settings.SARVAM_API_KEY}


async def transcribe(audio_bytes: bytes, language_code: str) -> dict:
    """Speech-to-text. Returns {transcript, language_code, confidence}."""
    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            response = await client.post(
                f"{BASE_URL}/speech-to-text",
                headers=_headers(),
                json={
                    "audio": base64.b64encode(audio_bytes).decode("ascii"),
                    "language_code": language_code,
                },
            )
            response.raise_for_status()
            data = response.json()
    except (httpx.HTTPError, SarvamError) as exc:
        raise SarvamError(str(exc)) from exc

    return {
        "transcript": data.get("transcript", ""),
        "language_code": data.get("language_code", language_code),
        "confidence": float(data.get("confidence", 0.0)),
    }


async def synthesize(text: str, language_code: str, speaker: str | None = None) -> bytes:
    """Text-to-speech. Returns raw audio bytes."""
    payload = {"text": text, "language_code": language_code}
    if speaker:
        payload["speaker"] = speaker

    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            response = await client.post(
                f"{BASE_URL}/text-to-speech",
                headers=_headers(),
                json=payload,
            )
            response.raise_for_status()
            data = response.json()
    except (httpx.HTTPError, SarvamError) as exc:
        raise SarvamError(str(exc)) from exc

    audio_b64 = data.get("audio") or data.get("audios", [None])[0]
    if not audio_b64:
        raise SarvamError("Sarvam TTS response missing audio")
    return base64.b64decode(audio_b64)


async def translate(text: str, source_language: str, target_language: str) -> str:
    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            response = await client.post(
                f"{BASE_URL}/translate",
                headers=_headers(),
                json={
                    "input": text,
                    "source_language": source_language,
                    "target_language": target_language,
                },
            )
            response.raise_for_status()
            data = response.json()
    except (httpx.HTTPError, SarvamError) as exc:
        raise SarvamError(str(exc)) from exc

    return data.get("translated_text", "")
