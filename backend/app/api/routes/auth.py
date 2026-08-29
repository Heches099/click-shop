from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.core.security import create_access_token, hash_password, verify_password
from app.models import User
from app.schemas.auth import (
    FirebaseLoginRequest,
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserOut,
)
from app.services.auth_service import AuthServiceError, get_or_create_user_by_email, verify_firebase_id_token

router = APIRouter(prefix="/auth", tags=["auth"])


def _token_response(user: User) -> TokenResponse:
    return TokenResponse(access_token=create_access_token(user.id), user=UserOut.model_validate(user))


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: RegisterRequest, db: AsyncSession = Depends(get_db)):
    existing = await db.scalar(select(User).where(User.email == payload.email))
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    user = User(email=payload.email, hashed_password=hash_password(payload.password), name=payload.name)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return _token_response(user)


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, db: AsyncSession = Depends(get_db)):
    user = await db.scalar(select(User).where(User.email == payload.email))
    if user is None or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    return _token_response(user)


@router.post("/firebase", response_model=TokenResponse)
async def firebase_login(payload: FirebaseLoginRequest, db: AsyncSession = Depends(get_db)):
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
