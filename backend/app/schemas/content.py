from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class CollectionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    slug: str
    name: str
    description: str = ""
    tag: str | None = None
    image: str | None = None
    productCount: int = 0


class CollectionDetailOut(CollectionOut):
    products: list = []  # ProductOut serialized dicts


class CollectionCreate(BaseModel):
    name: str = Field(min_length=2, max_length=255)
    slug: str = Field(min_length=2, max_length=200)
    description: str = ""
    tag: str | None = None
    image: str | None = None
    sort_order: int = 0
    product_ids: list[str] = []


class CollectionUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=255)
    slug: str | None = Field(default=None, min_length=2, max_length=200)
    description: str | None = None
    tag: str | None = None
    image: str | None = None
    sort_order: int | None = None
    is_active: bool | None = None
    product_ids: list[str] | None = None


class GuideOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    slug: str
    title: str
    summary: str = ""
    categorySlug: str | None = None
    image: str | None = None
    publishedAt: datetime | None = None


class GuideDetailOut(GuideOut):
    body: str = ""


class GuideCreate(BaseModel):
    title: str = Field(min_length=2, max_length=255)
    slug: str = Field(min_length=2, max_length=200)
    summary: str = ""
    body: str = ""
    category_slug: str | None = None
    image: str | None = None


class GuideUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=2)
    slug: str | None = Field(default=None, min_length=2)
    summary: str | None = None
    body: str | None = None
    category_slug: str | None = None
    image: str | None = None
    is_active: bool | None = None