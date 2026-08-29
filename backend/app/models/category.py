from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


class Category(Base, TimestampMixin):
    __tablename__ = "categories"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    slug: Mapped[str] = mapped_column(String(120), unique=True, index=True, nullable=False)
    parent_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("categories.id"), nullable=True)
    image: Mapped[str | None] = mapped_column(String(500))
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    parent = relationship("Category", remote_side=[id], back_populates="subcategories")
    subcategories = relationship("Category", back_populates="parent")
    products = relationship("Product", back_populates="category")
