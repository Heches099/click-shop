import secrets

import httpx

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import hash_password
from app.models import User

FIREBASE_TOKENINFO = "https://oauth2.googleapis.com/tokeninfo"
FIREBASE_LOOKUP = "https://identitytoolkit.googleapis.com/v1/accounts:lookup"


class AuthServiceError(Exception):
    pass


def normalize_email(email: str) -> str:
    return email.strip().lower()


def is_admin_email(email: str) -> bool:
    """True when the email is on the server-side ADMIN_EMAILS owner list."""
    return normalize_email(email) in settings.admin_emails_list


async def _verify_with_identitytoolkit(id_token: str) -> dict | None:
    """Verify an ID token against THIS Firebase project (accounts:lookup).

    Returns None when the Firebase web API key is not configured so callers
    can fall back. Raises AuthServiceError for unverified / missing emails.
    """
    api_key = settings.firebase_web_api_key
    if not api_key:
        return None

    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.post(
            FIREBASE_LOOKUP,
            params={"key": api_key},
            json={"idToken": id_token},
        )
    if response.status_code != 200:
        raise AuthServiceError("Invalid Firebase ID token")
    users = response.json().get("users") or []
    if not users:
        raise AuthServiceError("Invalid Firebase ID token")

    user = users[0]
    email = (user.get("email") or "").strip().lower()
    if not email or not user.get("emailVerified", False):
        raise AuthServiceError("Firebase token has no verified email")
    return {
        "sub": user.get("localId"),
        "email": email,
        "name": user.get("displayName"),
        "picture": user.get("photoUrl"),
    }


async def verify_firebase_id_token(id_token: str) -> dict:
    """Validate a Firebase/Google ID token and return its verified identity.

    Preferred path: accounts:lookup against this Firebase project (ties the
    token to the ClickShop project). Fallback: Google's tokeninfo endpoint.
    """
    info = await _verify_with_identitytoolkit(id_token)
    if info is not None:
        return info

    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.get(FIREBASE_TOKENINFO, params={"id_token": id_token})
        if response.status_code != 200:
            raise AuthServiceError("Invalid Firebase ID token")
        data = response.json()
    email = data.get("email")
    if not email or not data.get("email_verified", False):
        raise AuthServiceError("Firebase token has no verified email")
    # Audience validation: the token must carry an `aud` claim. When the
    # Firebase web API key is configured it must match (Firebase ID tokens are
    # minted for the project's API key), otherwise tokens minted for another
    # audience would be accepted by this fallback path.
    aud = data.get("aud")
    if not aud:
        raise AuthServiceError("Firebase token has no audience claim")
    if settings.firebase_web_api_key and aud != settings.firebase_web_api_key:
        raise AuthServiceError("Firebase token audience mismatch")
    _validate_issuer(data)
    return {
        "sub": data.get("sub"),
        "email": email.strip().lower(),
        "name": data.get("name"),
        "picture": data.get("picture"),
    }


GOOGLE_ISSUERS = {"accounts.google.com", "https://accounts.google.com"}


def _validate_issuer(data: dict) -> None:
    """Reject tokens minted by an unexpected issuer."""
    iss = data.get("iss")
    if not iss:
        raise AuthServiceError("Firebase token has no issuer claim")
    host = iss.split("://")[-1].split("/")[0] if iss else ""
    if host not in GOOGLE_ISSUERS:
        raise AuthServiceError("Firebase token issuer not trusted")


async def get_or_create_user_by_email(db: AsyncSession, email: str, name: str | None = None, photo_url: str | None = None) -> User:
    email = normalize_email(email)
    user = await db.scalar(select(User).where(User.email == email))
    if user is None:
        # OAuth users get a random, unguessable password so the email/password
        # login path can never be used to take over an OAuth account.
        user = User(
            email=email,
            hashed_password=hash_password(secrets.token_urlsafe(32)),
            name=name or email.split("@")[0],
            photo_url=photo_url,
            is_admin=is_admin_email(email),
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
    elif is_admin_email(email) and not user.is_admin:
        # Keep owner status in sync with ADMIN_EMAILS (server-side only).
        user.is_admin = True
        await db.commit()
    return user
