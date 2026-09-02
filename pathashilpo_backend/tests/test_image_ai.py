"""POST /api/v1/ai/image — fal.ai, degrading to the original (TRD.md §8.4).

Invariant 3 (PROJECT_CONTEXT §7): this route must never hand the artisan an
error they have to resolve. Every provider failure is a 200 with
`degraded: true`.
"""

from app.api.v1.endpoints import image_ai
from app.services import fal_service

ENDPOINT = "/api/v1/ai/image"


def _image_file(content: bytes, content_type: str = "image/jpeg"):
    return {"file": ("photo.jpg", content, content_type)}


def test_missing_key_degrades_to_original(client, jpeg_bytes, monkeypatch):
    """Today's real behaviour when FAL_KEY is unset."""
    monkeypatch.setattr(fal_service.get_settings(), "FAL_KEY", "", raising=False)

    response = client.post(ENDPOINT, files=_image_file(jpeg_bytes))

    assert response.status_code == 200
    body = response.json()
    assert body["degraded"] is True
    assert body["background_removed"] is False
    assert body["image_url"].startswith("data:image/jpeg;base64,")


def test_successful_pipeline(client, jpeg_bytes, monkeypatch):
    async def fake_process(image_bytes, content_type="image/jpeg"):
        return {
            "image_url": "https://fal.media/files/processed.png",
            "background_removed": True,
            "enhanced": True,
            "quality_score": 0.7,
            "degraded": False,
        }

    monkeypatch.setattr(fal_service, "process_image", fake_process)

    response = client.post(ENDPOINT, files=_image_file(jpeg_bytes))

    assert response.status_code == 200
    body = response.json()
    assert body["degraded"] is False
    assert body["enhanced"] is True


def test_provider_failure_still_returns_200(client, jpeg_bytes, monkeypatch):
    """A fal.ai outage must not surface as a 5xx to the artisan."""

    def exploding_submit(model, arguments):
        raise RuntimeError("fal.ai queue unavailable")

    monkeypatch.setattr(fal_service, "_submit", exploding_submit)
    monkeypatch.setattr(fal_service.get_settings(), "FAL_KEY", "test-key", raising=False)

    response = client.post(ENDPOINT, files=_image_file(jpeg_bytes))

    assert response.status_code == 200
    assert response.json()["degraded"] is True


def test_background_removal_is_retried_once(client, jpeg_bytes, monkeypatch):
    """§8.5 allows one retry; a transient failure should still succeed."""
    attempts = {"count": 0}

    def flaky_submit(model, arguments):
        if model == fal_service.BACKGROUND_REMOVAL_MODEL:
            attempts["count"] += 1
            if attempts["count"] == 1:
                raise RuntimeError("transient queue error")
            return {"image": {"url": "https://fal.media/files/cutout.png"}}
        raise RuntimeError("upscaler down")

    monkeypatch.setattr(fal_service, "_submit", flaky_submit)
    monkeypatch.setattr(fal_service.get_settings(), "FAL_KEY", "test-key", raising=False)

    response = client.post(ENDPOINT, files=_image_file(jpeg_bytes))
    body = response.json()

    assert attempts["count"] == 2
    assert body["background_removed"] is True
    # The upscaler failed, but that is best-effort — the cutout survives.
    assert body["enhanced"] is False
    assert body["degraded"] is False


def test_accepts_the_flutter_clients_octet_stream_upload(client, jpeg_bytes, monkeypatch):
    """Regression guard for the real client's request shape.

    `image_router.dart` builds `MultipartFile.fromBytes(bytes, filename:
    'photo.jpg')` with no contentType, so Dio labels it
    application/octet-stream. Validating the header instead of the bytes
    would 415 every photo the app sends.
    """
    monkeypatch.setattr(fal_service.get_settings(), "FAL_KEY", "", raising=False)

    response = client.post(
        ENDPOINT, files=_image_file(jpeg_bytes, content_type="application/octet-stream")
    )

    assert response.status_code == 200
    # The sniffed type, not the declared one, reaches the data URI.
    assert response.json()["image_url"].startswith("data:image/jpeg;base64,")


def test_non_image_bytes_are_rejected(client):
    """A lying Content-Type does not get a file into the paid pipeline."""
    response = client.post(
        ENDPOINT, files=_image_file(b"%PDF-1.4 not an image", content_type="image/jpeg")
    )

    assert response.status_code == 415


def test_empty_upload_is_rejected(client):
    response = client.post(ENDPOINT, files=_image_file(b""))

    assert response.status_code == 400


def test_oversized_upload_is_rejected(client, monkeypatch):
    monkeypatch.setattr(image_ai, "MAX_IMAGE_BYTES", 1024)

    response = client.post(ENDPOINT, files=_image_file(b"x" * 2048))

    assert response.status_code == 413
