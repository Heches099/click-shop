from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class AffiliateAccountCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    email: EmailStr
    payment_email: str | None = None


class AffiliateOut(BaseModel):
    id: str
    name: str
    email: str
    promoCode: str
    paymentEmail: str
    status: str
    totalClicks: int = 0
    totalSales: int = 0
    totalCommission: float = 0.0
    pendingBalance: float = 0.0
    createdAt: datetime | None = None


class AffiliateClickCreate(BaseModel):
    code: str = Field(min_length=1, max_length=40)
    source: str | None = None


class AffiliateClickOut(BaseModel):
    id: str
    affiliateCode: str
    source: str | None = None
    createdAt: datetime


class CommissionOut(BaseModel):
    id: str
    affiliateCode: str
    orderId: str
    orderAmount: float
    rate: float
    amount: float
    status: str
    createdAt: datetime


class AffiliateStatsOut(BaseModel):
    clicks: int = 0
    sales: int = 0
    commission: float = 0.0
    conversionRate: float = 0.0
    pendingCommissions: int = 0


class PayoutRequest(BaseModel):
    pass
