from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_optional_user
from app.core.database import get_db
from app.core.ratelimit import rate_limit
from app.models import ContactMessage, User
from app.schemas.insight import ContactMessageCreate, ContactMessageOut

router = APIRouter(prefix="/contact", tags=["contact"])

_MIN_MESSAGE_LENGTH = 10
_MAX_SUBJECT_LENGTH = 200


@router.post("", response_model=ContactMessageOut, status_code=status.HTTP_201_CREATED)
async def submit_contact(
    payload: ContactMessageCreate,
    request: Request,
    user: User | None = Depends(get_optional_user),
    _: None = Depends(rate_limit("contact", limit=5, window_seconds=3600)),
    db: AsyncSession = Depends(get_db),
):
    """Accept a support message, stored for the owner.

    Works end-to-end without any email provider configured: messages appear in
    the owner contact inbox instead of being emailed. An SMTP credential is
    optional and only needed to add outbound notifications later.
    """
    if len(payload.message.strip()) < _MIN_MESSAGE_LENGTH:
        raise HTTPException(status_code=422, detail="Message must be at least 10 characters")
    if payload.subject and len(payload.subject) > _MAX_SUBJECT_LENGTH:
        raise HTTPException(status_code=422, detail="Subject is too long")

    message = ContactMessage(
        name=payload.name,
        email=payload.email.lower(),
        subject=payload.subject,
        message=payload.message.strip(),
        user_id=user.id if user else None,
    )
    db.add(message)
    await db.commit()
    await db.refresh(message)
    return ContactMessageOut(
        id=message.id,
        name=message.name,
        email=message.email,
        subject=message.subject,
        message=message.message,
        isRead=message.is_read,
        createdAt=message.created_at,
    )