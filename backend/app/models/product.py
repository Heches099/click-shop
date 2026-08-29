from sqlalchemy import Boolean, Float, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


class Product(Base, TimestampMixin):
    __tablename__ = "products"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    name: Mapped[str] = mapped_column(String(255), index=True, nullable=False)
    slug: Mapped[str] = mapped_column(String(280), unique=True, index=True, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    original_price: Mapped[float | None] = mapped_column(Float)
    images: Mapped[list] = mapped_column(JSON, default=list, nullable=False)
    rating: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    review_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    category_id: Mapped[str] = mapped_column(String(36), ForeignKey("categories.id"), index=True, nullable=False)
    brand: Mapped[str] = mapped_column(String(120), index=True, nullable=False)
    stock: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    specifications: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    colors: Mapped[list] = mapped_column(JSON, default=list, nullable=False)
    sizes: Mapped[list] = mapped_column(JSON, default=list, nullable=False)

    is_featured: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_best_seller: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_new_arrival: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_flash_sale: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_recommended: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    category = relationship("Category", back_populates="products")
    reviews = relationship("Review", back_populates="product", cascade="all, delete-orphan")
    order_items = relationship("OrderItem", back_populates="product")
