"""Request authentication.

Every `/api/v1/*` route except `/health` requires a Firebase ID token issued
to a real signed-in user (TRD.md §5.5). This replaces the earlier stub that
accepted any bearer string.
"""

import logging
from dataclasses import dataclass

from fastapi import Depends, Header, HTTPException, status
from firebase_admin import auth as firebase_auth

from app.core.firebase import init_firebase, is_ready

logger = logging.getLogger(__name__)


@dataclass
class AuthenticatedUser:
    uid: str
    token: str
    phone: str | None = None
    email: str | None = None


def _unauthorised(detail: str) -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )


async def get_current_user(
    authorization: str | None = Header(default=None),
) -> AuthenticatedUser:
    """Verify the caller's Firebase ID token and return the real user.

    Fails closed: if Firebase credentials are not configured the request is
    rejected with 503 rather than being allowed through, so a misconfigured
    deploy cannot silently become an open endpoint.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise _unauthorised("Missing or malformed Authorization header")

    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        raise _unauthorised("Missing or malformed Authorization header")

    if not is_ready() and not init_firebase():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication is not configured on this server.",
        )

    try:
        decoded = firebase_auth.verify_id_token(token)
    except firebase_auth.ExpiredIdTokenError:
        raise _unauthorised("Token has expired. Sign in again.") from None
    except firebase_auth.RevokedIdTokenError:
        raise _unauthorised("Token has been revoked. Sign in again.") from None
    except (
        firebase_auth.InvalidIdTokenError,
        firebase_auth.UserDisabledError,
        ValueError,
    ):
        # Never echo the token or the underlying error to the caller.
        raise _unauthorised("Invalid authentication token") from None

    uid = decoded.get("uid")
    if not uid:
        raise _unauthorised("Invalid authentication token")

    return AuthenticatedUser(
        uid=uid,
        token=token,
        phone=decoded.get("phone_number"),
        email=decoded.get("email"),
    )


# Convenience alias so route signatures read clearly.
CurrentUser = Depends(get_current_user)
