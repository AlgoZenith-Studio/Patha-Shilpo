"""Shared test fixtures.

Two things every test in this suite depends on:

1. **Auth is overridden, not faked with a token.** `get_current_user` calls
   `firebase_admin.auth.verify_id_token`, which needs a live project and a
   real signed-in user. Overriding the dependency tests the routes without
   turning every test into an integration test — `test_security.py` covers
   the real dependency's behaviour separately.

2. **The rate limiter is process-global.** `ai_limiter` holds its counters in
   a module-level dict, so without a reset the 21st request across the whole
   session starts returning 429 and unrelated tests fail in file order.

No test in this suite makes a network call; every provider is monkeypatched.
"""

import io

import pytest
from fastapi.testclient import TestClient
from PIL import Image

from app.core.rate_limit import ai_limiter
from app.core.security import AuthenticatedUser, get_current_user
from app.main import app

TEST_UID = "test-artisan-uid"


@pytest.fixture(autouse=True)
def reset_rate_limiter():
    ai_limiter.reset()
    yield
    ai_limiter.reset()


@pytest.fixture
def authenticated_user() -> AuthenticatedUser:
    return AuthenticatedUser(uid=TEST_UID, token="test-token", phone="+919000000000")


@pytest.fixture
def client(authenticated_user) -> TestClient:
    """A client whose requests always carry a valid signed-in user."""
    app.dependency_overrides[get_current_user] = lambda: authenticated_user
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def anonymous_client() -> TestClient:
    """No dependency override — exercises the real auth dependency."""
    app.dependency_overrides.clear()
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def jpeg_bytes() -> bytes:
    """A real, decodable 64x64 JPEG.

    Pillow actually parses this in `_quality_score`, so a dummy byte string
    would silently take the corrupt-image path and score 0.0.
    """
    buffer = io.BytesIO()
    Image.new("RGB", (64, 64), color=(200, 150, 90)).save(buffer, format="JPEG")
    return buffer.getvalue()
