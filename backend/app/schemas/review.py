from datetime import datetime

from pydantic import BaseModel, Field


class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    title: str | None = Field(default=None, max_length=255)
    comment: str | None = None


class ReviewOut(BaseModel):
    id: str
    product_id: str
    user_id: str
    user_name: str | None = None
    rating: int
    title: str | None = None
    comment: str | None = None
    created_at: datetime
