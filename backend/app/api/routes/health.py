from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import get_db

router = APIRouter(tags=["health"])


@router.get("/health")
async def health():
    # Returns only non-sensitive information. Never return env vars, secrets,
    # credentials, or internal configuration from any endpoint.
    return {
        "status": "ok",
        "amazon_api_enabled": settings.amazon_api_enabled,
    }


@router.get("/health/db")
async def health_db(db: AsyncSession = Depends(get_db)):
    await db.execute(text("SELECT 1"))
    return {"status": "ok", "database": "connected"}
