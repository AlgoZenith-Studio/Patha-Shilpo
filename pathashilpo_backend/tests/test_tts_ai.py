"""POST /api/v1/ai/tts — Sarvam → Bhashini → 502 (TRD.md §8.5).

The 502 is the interesting case: it is how the client learns to speak the
text with `flutter_tts` instead, so it must stay a clean, fast answer.
"""

import base64

from app.services import bhashini_service, sarvam_service
from app.services.bhashini_service import BhashiniError
from app.services.sarvam_service import SarvamError

ENDPOINT = "/api/v1/ai/tts"

AUDIO = b"RIFF....WAVEfmt fake-audio"
PAYLOAD = {"text": "इस साड़ी की कीमत दो हज़ार रुपये है।", "language_code": "hi"}


def test_sarvam_success_returns_base64_audio(client, monkeypatch):
    async def fake_synthesize(text, language_code, speaker=None):
        return AUDIO

    monkeypatch.setattr(sarvam_service, "synthesize", fake_synthesize)

    response = client.post(ENDPOINT, json=PAYLOAD)

    assert response.status_code == 200
    body = response.json()
    assert body["source"] == "sarvam"
    assert body["language_code"] == "hi"
    assert body["content_type"] == "audio/wav"
    assert base64.b64decode(body["audio"]) == AUDIO


def test_falls_back_to_bhashini(client, monkeypatch):
    async def failing_sarvam(text, language_code, speaker=None):
        raise SarvamError("no key")

    async def fake_bhashini(text, language_code, gender="female"):
        return AUDIO

    monkeypatch.setattr(sarvam_service, "synthesize", failing_sarvam)
    monkeypatch.setattr(bhashini_service, "synthesize", fake_bhashini)

    response = client.post(ENDPOINT, json=PAYLOAD)

    assert response.status_code == 200
    assert response.json()["source"] == "bhashini"


def test_both_unavailable_returns_502(client, monkeypatch):
    """This is today's real behaviour — no Bhashini key is configured."""

    async def failing_sarvam(text, language_code, speaker=None):
        raise SarvamError("down")

    async def failing_bhashini(text, language_code, gender="female"):
        raise BhashiniError("BHASHINI_API_KEY not configured")

    monkeypatch.setattr(sarvam_service, "synthesize", failing_sarvam)
    monkeypatch.setattr(bhashini_service, "synthesize", failing_bhashini)

    response = client.post(ENDPOINT, json=PAYLOAD)

    assert response.status_code == 502
    assert "on-device TTS" in response.json()["detail"]


def test_speaker_is_passed_to_sarvam(client, monkeypatch):
    seen = {}

    async def fake_synthesize(text, language_code, speaker=None):
        seen["speaker"] = speaker
        return AUDIO

    monkeypatch.setattr(sarvam_service, "synthesize", fake_synthesize)

    client.post(ENDPOINT, json={**PAYLOAD, "speaker": "meera"})

    assert seen["speaker"] == "meera"


def test_gender_is_passed_to_bhashini(client, monkeypatch):
    seen = {}

    async def failing_sarvam(text, language_code, speaker=None):
        raise SarvamError("down")

    async def fake_bhashini(text, language_code, gender="female"):
        seen["gender"] = gender
        return AUDIO

    monkeypatch.setattr(sarvam_service, "synthesize", failing_sarvam)
    monkeypatch.setattr(bhashini_service, "synthesize", fake_bhashini)

    client.post(ENDPOINT, json={**PAYLOAD, "gender": "male"})

    assert seen["gender"] == "male"


def test_empty_text_is_rejected_before_any_provider_call(client):
    response = client.post(ENDPOINT, json={"text": "", "language_code": "hi"})

    assert response.status_code == 422


def test_overlong_text_is_rejected(client):
    response = client.post(ENDPOINT, json={"text": "क" * 1001, "language_code": "hi"})

    assert response.status_code == 422
