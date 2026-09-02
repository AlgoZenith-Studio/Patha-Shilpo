"""POST /api/v1/ai/voice — Sarvam → Bhashini → 502 (TRD.md §8.5)."""

import pytest

from app.services import bhashini_service, sarvam_service
from app.services.bhashini_service import BhashiniError
from app.services.sarvam_service import SarvamError

ENDPOINT = "/api/v1/ai/voice"


def _audio_file(content: bytes = b"fake-audio-bytes"):
    return {"file": ("audio.m4a", content, "audio/m4a")}


def _result(transcript: str, confidence: float = 0.9) -> dict:
    return {
        "transcript": transcript,
        "language_code": "hi",
        "confidence": confidence,
    }


def test_sarvam_success_returns_tier_1(client, monkeypatch):
    async def fake_transcribe(audio, language):
        return _result("यह चंदेरी साड़ी है")

    monkeypatch.setattr(sarvam_service, "transcribe", fake_transcribe)

    response = client.post(ENDPOINT, files=_audio_file(), data={"source_language": "hi"})

    assert response.status_code == 200
    body = response.json()
    assert body["source"] == "sarvam"
    assert body["tier"] == 1
    assert body["transcript"] == "यह चंदेरी साड़ी है"


def test_falls_back_to_bhashini_when_sarvam_errors(client, monkeypatch):
    async def failing_sarvam(audio, language):
        raise SarvamError("provider down")

    async def fake_bhashini(audio, language):
        return _result("बुनाई", confidence=0.8)

    monkeypatch.setattr(sarvam_service, "transcribe", failing_sarvam)
    monkeypatch.setattr(bhashini_service, "transcribe", fake_bhashini)

    response = client.post(ENDPOINT, files=_audio_file(), data={"source_language": "hi"})

    assert response.status_code == 200
    assert response.json()["source"] == "bhashini"


def test_empty_transcript_falls_through_to_bhashini(client, monkeypatch):
    """A 200 with an empty transcript is a failure, not a success.

    Without this the artisan gets a blank listing from a provider that
    technically answered.
    """

    async def silent_sarvam(audio, language):
        return _result("   ")

    async def fake_bhashini(audio, language):
        return _result("चंदेरी")

    monkeypatch.setattr(sarvam_service, "transcribe", silent_sarvam)
    monkeypatch.setattr(bhashini_service, "transcribe", fake_bhashini)

    response = client.post(ENDPOINT, files=_audio_file(), data={"source_language": "hi"})

    assert response.status_code == 200
    assert response.json()["source"] == "bhashini"


def test_both_providers_failing_returns_502(client, monkeypatch):
    async def failing_sarvam(audio, language):
        raise SarvamError("down")

    async def failing_bhashini(audio, language):
        raise BhashiniError("not configured")

    monkeypatch.setattr(sarvam_service, "transcribe", failing_sarvam)
    monkeypatch.setattr(bhashini_service, "transcribe", failing_bhashini)

    response = client.post(ENDPOINT, files=_audio_file(), data={"source_language": "hi"})

    assert response.status_code == 502
    assert "on-device ASR" in response.json()["detail"]


def test_both_returning_empty_transcripts_returns_502(client, monkeypatch):
    async def silent(audio, language):
        return _result("")

    monkeypatch.setattr(sarvam_service, "transcribe", silent)
    monkeypatch.setattr(bhashini_service, "transcribe", silent)

    response = client.post(ENDPOINT, files=_audio_file(), data={"source_language": "hi"})

    assert response.status_code == 502


def test_empty_audio_is_rejected(client):
    response = client.post(
        ENDPOINT, files=_audio_file(b""), data={"source_language": "hi"}
    )

    assert response.status_code == 400


def test_missing_source_language_is_rejected(client):
    response = client.post(ENDPOINT, files=_audio_file())

    assert response.status_code == 422
