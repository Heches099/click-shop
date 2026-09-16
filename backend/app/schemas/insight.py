from datetime import datetime

from pydantic import BaseModel, Field


class AnalyticsEventIn(BaseModel):
    event_type: str = Field(min_length=2, max_length=50)
    product_id: str | None = None
    client_id: str | None = Field(default=None, min_length=8, max_length=64)
    payload: dict = {}

    @classmethod
    def allowed_types(cls) -> set[str]:
        return {
            "view_product",
            "search",
            "filter",
            "add_to_compare",
            "remove_from_compare",
            "save_product",
            "remove_saved_product",
            "add_to_cart",
            "remove_from_cart",
            "begin_checkout",
            "purchase",
            "affiliate_click",
            "help_choose_start",
            "help_choose_result",
        }


class SearchSuggestionOut(BaseModel):
    product_id: str
    slug: str
    name: str
    brand: str = ""
    price: float = 0.0
    image: str | None = None


class SuggestOut(BaseModel):
    products: list[SearchSuggestionOut] = []
    categories: list[dict] = []
    popular: list[str] = []


class ContactMessageCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    email: str = Field(min_length=3, max_length=255)
    subject: str | None = Field(default=None, max_length=200)
    message: str = Field(min_length=10, max_length=5000)


class ContactMessageOut(BaseModel):
    id: str
    name: str
    email: str
    subject: str | None = None
    message: str
    isRead: bool
    createdAt: datetime | None = None


class AuditLogOut(BaseModel):
    id: str
    adminEmail: str = ""
    action: str
    targetType: str
    targetId: str | None = None
    detail: dict = {}
    createdAt: datetime | None = None