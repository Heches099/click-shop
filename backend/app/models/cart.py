from sqlalchemy import ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


class Cart(Base, TimestampMixin):
    __tablename__ = "carts"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), unique=True, index=True, nullable=False)

    user = relationship("User", back_populates="cart")
    items = relationship("CartItem", back_populates="cart", cascade="all, delete-orphan")


class CartItem(Base):
    __tablename__ = "cart_items"
    __table_args__ = (UniqueConstraint("cart_id", "product_id", name="uq_cart_product"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    cart_id: Mapped[str] = mapped_column(String(36), ForeignKey("carts.id"), index=True, nullable=False)
    product_id: Mapped[str] = mapped_column(String(36), ForeignKey("products.id"), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    selected_color: Mapped[str | None] = mapped_column(String(100))
    selected_size: Mapped[str | None] = mapped_column(String(100))

    cart = relationship("Cart", back_populates="items")
    product = relationship("Product")
