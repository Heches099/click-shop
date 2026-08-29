import httpx

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password
from app.models import User

FIREBASE_TOKENINFO = "https://oauth2.googleapis.com/tokeninfo"


class AuthServiceError(Exception):
    pass


async def verify_firebase_id_token(id_token: str) -> dict:
    """Validate a Firebase/Google ID token via Google's tokeninfo endpoint."""
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.get(FIREBASE_TOKENINFO, params={"id_token": id_token})
        if response.status_code != 200:
            raise AuthServiceError("Invalid Firebase ID token")
        data = response.json()
    email = data.get("email")
    if not email or not data.get("email_verified", False):
        raise AuthServiceError("Firebase token has no verified email")
    return {
        "sub": data.get("sub"),
        "email": email,
        "name": data.get("name"),
        "picture": data.get("picture"),
    }


async def get_or_create_user_by_email(db: AsyncSession, email: str, name: str | None = None, photo_url: str | None = None) -> User:
    user = await db.scalar(select(User).where(User.email == email))
    if user is None:
        user = User(
            email=email,
            hashed_password=hash_password(f"oauth-{email}"),
            name=name or email.split("@")[0],
            photo_url=photo_url,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
    return user
