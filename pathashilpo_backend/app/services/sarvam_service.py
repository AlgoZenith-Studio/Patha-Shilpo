"""Sarvam AI client — ASR, TTS and translation (TRD.md §8.3).

Sarvam is the **primary** speech provider for both directions; Bhashini is
the fallback for languages and dialects it covers poorly. Unlike Bhashini,
every call here is a single request with a static URL, which is why this
client is so much shorter.

Raises `SarvamError` for every failure mode, including a missing API key, so
callers can treat "not configured" and "provider down" identically and fall
through to the next tier.
"""

import base64
import logging

import httpx

from app.core.config import get_settings

logger = logging.getLogger(__name__)

BASE_URL = "https://api.sarvam.ai"

# Per the §8.5 failure matrix. TTS is tighter than ASR/translate because it
# runs while the artisan waits to hear the price rationale read aloud —
# falling to the device voice quickly beats a long silence.
ASR_TIMEOUT = 10.0
TTS_TIMEOUT = 8.0
TRANSLATE_TIMEOUT = 10.0


class SarvamError(Exception):
    """Any Sarvam failure. Callers treat this as 'try the next tier'."""


def _headers() -> dict:
    settings = get_settings()
    if not settings.SARVAM_API_KEY:
        raise SarvamError("SARVAM_API_KEY not configured")
    return {"api-subscription-key": settings.SARVAM_API_KEY}


async def _post(path: str, payload: dict, timeout: float) -> dict:
    """One Sarvam call, with uniform error handling.

    Never lets the response body reach the exception message — a provider
    error can echo the submitted payload, which for ASR is the artisan's
    audio and for TTS is their listing text (§5.6).
    """
    try:
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                f"{BASE_URL}{path}", headers=_headers(), json=payload
            )
            response.raise_for_status()
            return response.json()
    except SarvamError:
        raise
    except (httpx.HTTPError, ValueError) as exc:
        logger.warning(
            "Sarvam %s failed (%s); falling through to the next tier",
            path,
            type(exc).__name__,
        )
        raise SarvamError(f"Sarvam {path} failed: {type(exc).__name__}") from exc


_LANG_MAP = {
    "hi": "hi-IN",
    "bn": "bn-IN",
    "en": "en-IN",
    "gu": "gu-IN",
    "mr": "mr-IN",
    "ta": "ta-IN",
    "te": "te-IN",
    "kn": "kn-IN",
    "ml": "ml-IN",
    "pa": "pa-IN",
    "od": "od-IN",
}


def normalize_language(code: str) -> str:
    cleaned = code.strip().lower()
    return _LANG_MAP.get(cleaned, code if "-" in code else f"{cleaned}-IN")


async def transcribe(audio_bytes: bytes, language_code: str) -> dict:
    """Speech-to-text. Returns {transcript, language_code, confidence}."""
    lang = normalize_language(language_code)
    try:
        async with httpx.AsyncClient(timeout=ASR_TIMEOUT) as client:
            files = {"file": ("audio.wav", audio_bytes, "audio/wav")}
            data = {"model": "saaras:v3", "language_code": lang}
            response = await client.post(
                f"{BASE_URL}/speech-to-text",
                headers=_headers(),
                files=files,
                data=data,
            )
            response.raise_for_status()
            res = response.json()
            return {
                "transcript": res.get("transcript", ""),
                "language_code": res.get("language_code", language_code),
                "confidence": float(res.get("confidence", 0.0) or 0.0),
            }
    except SarvamError:
        raise
    except (httpx.HTTPError, ValueError) as exc:
        logger.warning(
            "Sarvam /speech-to-text failed (%s); falling through to the next tier",
            type(exc).__name__,
        )
        raise SarvamError(f"Sarvam /speech-to-text failed: {type(exc).__name__}") from exc


async def synthesize(
    text: str,
    language_code: str,
    speaker: str | None = None,
) -> bytes:
    """Text-to-speech. Returns raw audio bytes."""
    if not text.strip():
        raise SarvamError("Cannot synthesize empty text")

    lang = normalize_language(language_code)
    payload: dict = {
        "text": text,
        "language_code": lang,
        "model": "bulbul:v3",
    }
    if speaker:
        payload["speaker"] = speaker

    data = await _post("/text-to-speech", payload, TTS_TIMEOUT)

    # Sarvam returns {'audios': ['<base64>']} or {'audio': '<base64>'}
    audio_b64 = None
    audios = data.get("audios") or []
    if audios:
        audio_b64 = audios[0]
    elif data.get("audio"):
        audio_b64 = data.get("audio")

    if not audio_b64:
        raise SarvamError("Sarvam TTS response missing audio")

    try:
        return base64.b64decode(audio_b64)
    except (ValueError, TypeError) as exc:
        raise SarvamError("Sarvam TTS audio was not valid base64") from exc


async def translate(text: str, source_language: str, target_language: str) -> str:
    """Machine translation. Returns the translated text."""
    if not text.strip():
        return ""

    data = await _post(
        "/translate",
        {
            "input": text,
            "source_language_code": normalize_language(source_language),
            "target_language_code": normalize_language(target_language),
            "model": "mayura:v1",
        },
        TRANSLATE_TIMEOUT,
    )

    return data.get("translated_text", "")

