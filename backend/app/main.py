
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    description="Backend API for the ClickShop Flutter e-commerce app.",
    # API docs are a useful development surface but disclose the full router
    # schema publicly. They are disabled outside of local debug mode.
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    openapi_url="/openapi.json" if settings.debug else None,
)

if settings.jwt_secret == "change-me":
    print(
        "WARNING: JWT_SECRET is the insecure default 'change-me'. "
        "Set a unique JWT_SECRET in the environment before going live; "
        "a predictable signing key lets attackers forge admin tokens.",
        flush=True,
    )
if settings.admin_password == "ChangeMe123!":
    print(
        "WARNING: ADMIN_PASSWORD is the insecure default 'ChangeMe123!'. "
        "Set a unique ADMIN_PASSWORD before seeding/production.",
        flush=True,
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Bare health probe (no /v1 prefix) — used by platform health checks.
@app.get("/health")
async def root_health():
    # Mirror the versioned probe. Never returns env vars or secrets.
    return {"status": "ok", "amazon_api_enabled": settings.amazon_api_enabled}

app.include_router(api_router, prefix=settings.api_v1_prefix)
