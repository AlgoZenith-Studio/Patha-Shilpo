"""Firebase Admin SDK initialisation.

Reads the service account from ``FIREBASE_SERVICE_ACCOUNT``, which may be
either raw JSON or base64-encoded JSON (base64 is easier to put in a one-line
``.env`` or a Render dashboard field).

**This credential is a real secret.** It bypasses every Firestore security
rule, so it must never be committed, never shipped in the app, and never
logged. See TRD.md §5.4.
"""

import base64
import binascii
import json
import logging
from typing import Any

import firebase_admin
from firebase_admin import credentials

from app.core.config import get_settings

logger = logging.getLogger(__name__)

_initialised = False


def _decode_service_account(raw: str) -> dict[str, Any] | None:
    """Accept either raw JSON or base64-encoded JSON."""
    raw = raw.strip()
    if not raw:
        return None

    # Raw JSON
    if raw.startswith("{"):
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            logger.error("FIREBASE_SERVICE_ACCOUNT looks like JSON but does not parse")
            return None

    # base64-encoded JSON
    try:
        decoded = base64.b64decode(raw, validate=True).decode("utf-8")
        return json.loads(decoded)
    except (binascii.Error, UnicodeDecodeError, json.JSONDecodeError):
        logger.error("FIREBASE_SERVICE_ACCOUNT is neither valid JSON nor base64 JSON")
        return None


def init_firebase() -> bool:
    """Initialise the Admin SDK once. Returns True when credentials are live.

    Returns False (rather than raising) when no service account is configured,
    so local development without Firebase still boots — but every authenticated
    route will then reject requests rather than waving them through.
    """
    global _initialised
    if _initialised:
        return True

    settings = get_settings()
    account = _decode_service_account(settings.FIREBASE_SERVICE_ACCOUNT)

    if account is None:
        logger.warning(
            "FIREBASE_SERVICE_ACCOUNT is not set - authenticated endpoints "
            "will reject all requests until it is configured."
        )
        return False

    try:
        cred = credentials.Certificate(account)
        firebase_admin.initialize_app(
            cred,
            {"projectId": settings.FIREBASE_PROJECT_ID}
            if settings.FIREBASE_PROJECT_ID
            else None,
        )
        _initialised = True
        logger.info("Firebase Admin initialised for project %s", account.get("project_id"))
        return True
    except Exception:
        # Deliberately not logging the exception body - it can echo key material.
        logger.exception("Firebase Admin initialisation failed")
        return False


def is_ready() -> bool:
    return _initialised
