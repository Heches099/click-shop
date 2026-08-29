from sqlalchemy import Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, uuid_str


class AffiliateAccount(Base, TimestampMixin):
    __tablename__ = "affiliate_accounts"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    promo_code: Mapped[str] = mapped_column(String(40), unique=True, index=True, nullable=False)
    payment_email: Mapped[str] = mapped_column(String(255), nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="active", nullable=False)
    total_clicks: Mapped[int] = mapped_column(default=0, nullable=False)
    total_sales: Mapped[int] = mapped_column(default=0, nullable=False)
    total_commission: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    pending_balance: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    last_payout_request: Mapped[str | None] = mapped_column(String(40))

    user = relationship("User", back_populates="affiliate_account")
    commissions = relationship("AffiliateCommission", back_populates="affiliate")
    clicks = relationship("AffiliateClick", back_populates="affiliate")


class AffiliateClick(Base, TimestampMixin):
    __tablename__ = "affiliate_clicks"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    affiliate_id: Mapped[str] = mapped_column(String(36), ForeignKey("affiliate_accounts.id"), index=True, nullable=False)
    code: Mapped[str] = mapped_column(String(40), nullable=False)
    source: Mapped[str | None] = mapped_column(String(120))

    affiliate = relationship("AffiliateAccount", back_populates="clicks")


class AffiliateCommission(Base, TimestampMixin):
    __tablename__ = "affiliate_commissions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    affiliate_id: Mapped[str] = mapped_column(String(36), ForeignKey("affiliate_accounts.id"), index=True, nullable=False)
    order_id: Mapped[str] = mapped_column(String(36), ForeignKey("orders.id"), index=True, nullable=False)
    code: Mapped[str] = mapped_column(String(40), nullable=False)
    order_amount: Mapped[float] = mapped_column(Float, nullable=False)
    rate: Mapped[float] = mapped_column(Float, nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="pending", nullable=False)

    affiliate = relationship("AffiliateAccount", back_populates="commissions")


class Payout(Base, TimestampMixin):
    __tablename__ = "payouts"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=uuid_str)
    affiliate_id: Mapped[str] = mapped_column(String(36), ForeignKey("affiliate_accounts.id"), index=True, nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String(30), default="requested", nullable=False)
