from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Table, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


collection_products = Table(
    "collection_products",
    Base.metadata,
    Column("collection_id", String(36), ForeignKey("collections.id"), primary_key=True),
    Column("product_id", String(36), ForeignKey("products.id"), primary_key=True),
    Column("sort_order", Integer, default=0),
)


class Collection(Base, TimestampMixin):
    """A curated shopping mission (e.g. 'Student Setup', 'Everyday Sneakers')."""

    __tablename__ = "collections"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    slug: Mapped[str] = mapped_column(String(200), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, default="", nullable=False)
    tag: Mapped[str | None] = mapped_column(String(120))  # who it's for, e.g. "Students"
    image: Mapped[str | None] = mapped_column(String(500))
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    products = relationship(
        "Product",
        secondary=collection_products,
        back_populates="collections",
        order_by="collection_products.c.sort_order",
    )


class Guide(Base, TimestampMixin):
    """A genuine buying guide tied to the curated catalog."""

    __tablename__ = "guides"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    slug: Mapped[str] = mapped_column(String(200), unique=True, index=True, nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    summary: Mapped[str] = mapped_column(Text, default="", nullable=False)
    body: Mapped[str] = mapped_column(Text, default="", nullable=False)
    category_slug: Mapped[str | None] = mapped_column(String(120))  # guides route to a category
    image: Mapped[str | None] = mapped_column(String(500))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))