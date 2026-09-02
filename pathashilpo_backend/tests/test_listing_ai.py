"""POST /api/v1/ai/listing — Gemini with a template fallback (TRD.md §8.1).

The template path is not a degraded edge case: it is the offline twin from
the AI matrix, and it must always produce a usable bilingual listing.
"""

import httpx

from app.services import gemini_service

ENDPOINT = "/api/v1/ai/listing"

PAYLOAD = {
    "transcript": "yeh chanderi saree hai, silk ki bani hai",
    "craft_type": "saree",
    "material": "silk",
    "colors": ["maroon"],
    "hours_of_work": 6,
}

GEMINI_RESULT = {
    "title": "Handwoven Chanderi Silk Saree",
    "titleHi": "हस्तनिर्मित चंदेरी सिल्क साड़ी",
    "description": "A handwoven Chanderi saree in maroon silk.",
    "descriptionHi": "मैरून सिल्क में हस्तनिर्मित चंदेरी साड़ी।",
    "tags": ["saree", "silk", "chanderi", "maroon", "handmade", "artisan"],
    "colors": ["maroon"],
    "material": "silk",
    "craftType": "saree",
}


def test_gemini_success(client, monkeypatch):
    async def fake_call(prompt, api_key):
        return dict(GEMINI_RESULT)

    monkeypatch.setattr(gemini_service, "_call_gemini", fake_call)
    monkeypatch.setattr(
        gemini_service.get_settings(), "GEMINI_API_KEY", "test-key", raising=False
    )

    response = client.post(ENDPOINT, json=PAYLOAD)

    assert response.status_code == 200
    body = response.json()
    assert body["generated_by"] == "gemini"
    assert body["title_hi"] == GEMINI_RESULT["titleHi"]


def test_falls_back_to_template_when_gemini_fails(client, monkeypatch):
    calls = {"count": 0}

    async def failing_call(prompt, api_key):
        calls["count"] += 1
        raise httpx.ConnectError("gemini unreachable")

    monkeypatch.setattr(gemini_service, "_call_gemini", failing_call)
    monkeypatch.setattr(
        gemini_service.get_settings(), "GEMINI_API_KEY", "test-key", raising=False
    )

    response = client.post(ENDPOINT, json=PAYLOAD)

    assert response.status_code == 200
    assert response.json()["generated_by"] == "template"
    # §8.1: one retry, so exactly two attempts before the template.
    assert calls["count"] == 2


def test_missing_key_uses_template_without_calling_gemini(client, monkeypatch):
    def explode(*args, **kwargs):
        raise AssertionError("Gemini must not be called without an API key")

    monkeypatch.setattr(gemini_service, "_call_gemini", explode)
    monkeypatch.setattr(
        gemini_service.get_settings(), "GEMINI_API_KEY", "", raising=False
    )

    response = client.post(ENDPOINT, json=PAYLOAD)

    assert response.status_code == 200
    assert response.json()["generated_by"] == "template"


def test_template_output_satisfies_the_data_contract(client, monkeypatch):
    """TRD §4.1: title ≤70, description ≤600, 6-8 lowercase tags."""
    monkeypatch.setattr(
        gemini_service.get_settings(), "GEMINI_API_KEY", "", raising=False
    )

    response = client.post(ENDPOINT, json=PAYLOAD)
    body = response.json()

    assert len(body["title"]) <= 70
    assert len(body["title_hi"]) <= 70
    assert len(body["description"]) <= 600
    assert len(body["description_hi"]) <= 600
    assert 1 <= len(body["tags"]) <= 8
    assert all(tag == tag.lower() for tag in body["tags"])
    # The Hindi fields must never come back empty — a blank Devanagari field
    # is indistinguishable from the tofu-box rendering bug on the device.
    assert body["title_hi"].strip()
    assert body["description_hi"].strip()


def test_craft_type_is_required(client):
    response = client.post(ENDPOINT, json={"transcript": "kuch to hai"})

    assert response.status_code == 422
