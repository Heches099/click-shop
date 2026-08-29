from sqlalchemy import Float, ForeignKey, JSON, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


class Order(Base, TimestampMixin):
    __tablename__ = "orders"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True, nullable=False)
    subtotal: Mapped[float] = mapped_column(Float, nullable=False)
    shipping_fee: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    tax: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    total: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="pending", index=True, nullable=False)
    payment_method: Mapped[str | None] = mapped_column(String(60))
    payment_id: Mapped[str | None] = mapped_column(String(120))
    shipping_address: Mapped[dict] = mapped_column(JSON, nullable=False)
    tracking_number: Mapped[str | None] = mapped_column(String(120))
    ref_code: Mapped[str | None] = mapped_column(String(40), index=True)

    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    order_id: Mapped[str] = mapped_column(String(36), ForeignKey("orders.id"), index=True, nullable=False)
    product_id: Mapped[str] = mapped_column(String(36), ForeignKey("products.id"), nullable=False)
    product_snapshot: Mapped[dict] = mapped_column(JSON, nullable=False)
    quantity: Mapped[int] = mapped_column(default=1, nullable=False)
    unit_price: Mapped[float] = mapped_column(Float, nullable=False)
    selected_color: Mapped[str | None] = mapped_column(String(100))
    selected_size: Mapped[str | None] = mapped_column(String(100))

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")
