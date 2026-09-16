from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.core.ratelimit import rate_limit
from app.core.security import create_access_token, hash_password, verify_password
from app.models import User
from app.schemas.auth import (
    FirebaseLoginRequest,
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserOut,
)
from app.services.auth_service import (
    AuthServiceError,
    get_or_create_user_by_email,
    is_admin_email,
    normalize_email,
    verify_firebase_id_token,
)

router = APIRouter(prefix="/auth", tags=["auth"])


def _token_response(user: User) -> TokenResponse:
    return TokenResponse(access_token=create_access_token(user.id), user=UserOut.model_validate(user))


def _sync_admin_role(db: AsyncSession, user: User) -> User:
    """Server-side owner bootstrap: emails on ADMIN_EMAILS are owner accounts.

    A normal account never becomes an owner through any client input — role is
    always derived from server configuration.
    """
    if is_admin_email(user.email) and not user.is_admin:
        user.is_admin = True
        db.add(user)
    return user


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    payload: RegisterRequest,
    request: Request,
    _: None = Depends(rate_limit("auth-register", limit=5, window_seconds=600)),
    db: AsyncSession = Depends(get_db),
):
    email = normalize_email(payload.email)
    existing = await db.scalar(select(User).where(User.email == email))
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    user = User(
        email=email,
        hashed_password=hash_password(payload.password),
        name=payload.name,
        is_admin=is_admin_email(email),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return _token_response(user)


@router.post("/login", response_model=TokenResponse)
async def login(
    payload: LoginRequest,
    request: Request,
    _: None = Depends(rate_limit("auth-login", limit=10, window_seconds=300)),
    db: AsyncSession = Depends(get_db),
):
    email = normalize_email(payload.email)
    user = await db.scalar(select(User).where(User.email == email))
    if user is None or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    _sync_admin_role(db, user)
    await db.commit()
    return _token_response(user)


@router.post("/firebase", response_model=TokenResponse)
async def firebase_login(
    payload: FirebaseLoginRequest,
    request: Request,
    _: None = Depends(rate_limit("auth-firebase", limit=10, window_seconds=300)),
    db: AsyncSession = Depends(get_db),
):
    """Exchange a Firebase/Google ID token (from the app's Firebase Auth) for an API JWT."""
    try:
        info = await verify_firebase_id_token(payload.id_token)
    except AuthServiceError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)) from exc
    user = await get_or_create_user_by_email(db, info["email"], info.get("name"), info.get("picture"))
    return _token_response(user)


@router.get("/me", response_model=UserOut)
async def me(user: User = Depends(get_current_user)):
    return UserOut.model_validate(user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(user: User = Depends(get_current_user)):
    # JWT stateless logout: the client discards the token.
    return None
