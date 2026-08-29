from sqlalchemy import ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


class Review(Base, TimestampMixin):
    __tablename__ = "reviews"
    __table_args__ = (UniqueConstraint("product_id", "user_id", name="uq_review_product_user"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    product_id: Mapped[str] = mapped_column(String(36), ForeignKey("products.id"), index=True, nullable=False)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True, nullable=False)
    rating: Mapped[int] = mapped_column(Integer, nullable=False)
    title: Mapped[str | None] = mapped_column(String(255))
    comment: Mapped[str | None] = mapped_column(Text)

    product = relationship("Product", back_populates="reviews")
    user = relationship("User", back_populates="reviews")
