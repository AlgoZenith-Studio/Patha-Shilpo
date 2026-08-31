from dataclasses import dataclass

from fastapi import Header, HTTPException, status


@dataclass
class AuthenticatedUser:
    uid: str
    token: str


async def get_current_user(authorization: str | None = Header(default=None)) -> AuthenticatedUser:
    """Stub auth dependency.

    Placeholder for firebase_admin.auth.verify_id_token() — accepts any
    well-formed Bearer token without verifying it against Firebase, so the
    AI endpoints are callable during local development before a Firebase
    service account is wired in.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or malformed Authorization header",
        )

    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or malformed Authorization header",
        )

    return AuthenticatedUser(uid="stub-uid", token=token)
