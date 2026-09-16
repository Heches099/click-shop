from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_optional_user
from app.core.database import get_db
from app.core.ratelimit import rate_limit
from app.models import AnalyticsEvent, User
from app.schemas.insight import AnalyticsEventIn

router = APIRouter(prefix="/analytics", tags=["analytics"])

MAX_KEYS = 8
MAX_VALUE_LENGTH = 160

# Hard size cap on the sanitised payload per event (enough for a search query
# plus lightweight context; never enough for sensitive data).
_MAX_PAYLOAD_CHARS = 2000


def _sanitize_payload(payload: dict) -> dict:
    """Keep only small, safe string/int/float values. Never echo nested data."""
    clean: dict[str, object] = {}
    for key in list(payload)[:MAX_KEYS]:
        value = payload[key]
        if isinstance(value, bool):
            clean[key] = value
        elif isinstance(value, (int, float)):
            clean[key] = float(value)
        elif isinstance(value, str) and len(value) <= MAX_VALUE_LENGTH:
            clean[key] = value
    total = sum(len(str(v)) for v in clean.values())
    if total > _MAX_PAYLOAD_CHARS:
        return {}
    return clean


@router.post("/events", status_code=status.HTTP_202_ACCEPTED)
async def record_event(
    payload: AnalyticsEventIn,
    request: Request,
    user: User | None = Depends(get_optional_user),
    _: None = Depends(rate_limit("analytics-events", limit=60, window_seconds=60)),
    db: AsyncSession = Depends(get_db),
):
    """Record an anonymised funnel/discovery event. Public — no credentials.

    `client_id` is an app-generated anonymous id so an owner can approximate
    sessions without any personal data. Never send passwords/tokens/secrets.
    """
    if payload.event_type not in AnalyticsEventIn.allowed_types():
        raise HTTPException(status_code=422, detail="Unknown event type")

    clean_payload = _sanitize_payload(payload.payload)

    db.add(
        AnalyticsEvent(
            user_id=user.id if user else None,
            client_id=payload.client_id,
            event_type=payload.event_type,
            product_id=payload.product_id,
            payload=clean_payload,
        )
    )
    await db.commit()
    return {"received": True}