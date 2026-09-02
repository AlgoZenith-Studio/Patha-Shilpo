"""Auth and rate limiting — the two controls guarding paid provider quota.

TRD.md §18.3 listed both as blocking risks. They are now implemented, so
these tests exist to stop them regressing back into the stub they were.
"""

import pytest

from app.core.rate_limit import SlidingWindowLimiter, ai_limiter
from app.services import gemini_service

LISTING = "/api/v1/ai/listing"
PAYLOAD = {"transcript": "test", "craft_type": "saree"}


def test_health_needs_no_token(anonymous_client):
    response = anonymous_client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


@pytest.mark.parametrize(
    "headers",
    [
        {},
        {"Authorization": "Bearer"},
        {"Authorization": "Bearer   "},
        {"Authorization": "not-a-bearer-token"},
        {"Authorization": "Basic dXNlcjpwYXNz"},
    ],
    ids=["missing", "bearer-only", "blank-token", "wrong-scheme", "basic-auth"],
)
def test_malformed_authorization_is_rejected(anonymous_client, headers):
    """A malformed header must never reach the provider call."""
    response = anonymous_client.post(LISTING, json=PAYLOAD, headers=headers)

    assert response.status_code == 401


def test_ai_routes_require_a_token(anonymous_client):
    for endpoint in ("/api/v1/ai/listing", "/api/v1/ai/tts"):
        response = anonymous_client.post(endpoint, json=PAYLOAD)
        assert response.status_code in (401, 422, 503), endpoint
        assert response.status_code != 200, f"{endpoint} answered without a token"


def test_rate_limit_returns_429_with_retry_after(client, monkeypatch):
    monkeypatch.setattr(
        gemini_service.get_settings(), "GEMINI_API_KEY", "", raising=False
    )

    limit = ai_limiter.max_requests
    for _ in range(limit):
        assert client.post(LISTING, json=PAYLOAD).status_code == 200

    response = client.post(LISTING, json=PAYLOAD)

    assert response.status_code == 429
    assert "Retry-After" in response.headers


def test_limiter_is_per_user():
    """One artisan burning their quota must not lock out another."""
    limiter = SlidingWindowLimiter(max_requests=2, window_seconds=60)

    limiter.check("artisan-a")
    limiter.check("artisan-a")
    with pytest.raises(Exception):
        limiter.check("artisan-a")

    # A different uid still has a full budget.
    limiter.check("artisan-b")


def test_limiter_window_expires(monkeypatch):
    limiter = SlidingWindowLimiter(max_requests=1, window_seconds=60)
    clock = {"now": 1000.0}
    monkeypatch.setattr(
        "app.core.rate_limit.time.monotonic", lambda: clock["now"]
    )

    limiter.check("uid")
    with pytest.raises(Exception):
        limiter.check("uid")

    clock["now"] += 61
    limiter.check("uid")  # window has slid past the first hit
