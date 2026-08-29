import secrets

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.database import get_db
from app.models import AffiliateAccount, AffiliateClick, AffiliateCommission, Payout, User
from app.schemas.affiliate import (
    AffiliateAccountCreate,
    AffiliateClickCreate,
    AffiliateClickOut,
    AffiliateOut,
    AffiliateStatsOut,
    CommissionOut,
)

router = APIRouter(prefix="/affiliate", tags=["affiliate"])

MIN_PAYOUT = 25.0


def _promo_code() -> str:
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return "CS-" + "".join(secrets.choice(alphabet) for _ in range(6))


async def _get_account(db: AsyncSession, user_id: str) -> AffiliateAccount | None:
    return await db.scalar(select(AffiliateAccount).where(AffiliateAccount.user_id == user_id))


def _account_out(a: AffiliateAccount) -> AffiliateOut:
    return AffiliateOut(
        id=a.id,
        name=a.name,
        email=a.email,
        promoCode=a.promo_code,
        paymentEmail=a.payment_email,
        status=a.status,
        totalClicks=a.total_clicks,
        totalSales=a.total_sales,
        totalCommission=a.total_commission,
        pendingBalance=a.pending_balance,
        createdAt=a.created_at,
    )


@router.post("/register", response_model=AffiliateOut, status_code=201)
async def register_account(
    payload: AffiliateAccountCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    existing = await _get_account(db, user.id)
    if existing:
        return _account_out(existing)
    account = AffiliateAccount(
        user_id=user.id,
        name=payload.name,
        email=payload.email,
        payment_email=payload.payment_email or payload.email,
        promo_code=_promo_code(),
        status="active",
    )
    db.add(account)
    await db.commit()
    await db.refresh(account)
    return _account_out(account)


@router.get("/me", response_model=AffiliateOut)
async def my_account(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    account = await _get_account(db, user.id)
    if account is None:
        raise HTTPException(status_code=404, detail="No affiliate account yet")
    return _account_out(account)


@router.get("/stats", response_model=AffiliateStatsOut)
async def stats(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    account = await _get_account(db, user.id)
    if account is None:
        return AffiliateStatsOut()
    commissions = await db.scalars(select(AffiliateCommission).where(AffiliateCommission.affiliate_id == account.id))
    commissions = list(commissions)
    pending_commission = round(sum(c.amount for c in commissions if c.status != "paid"), 2)
    pending_count = sum(1 for c in commissions if c.status == "pending")
    conversion = (account.total_sales / account.total_clicks) * 100 if account.total_clicks else 0.0
    return AffiliateStatsOut(
        clicks=account.total_clicks,
        sales=account.total_sales,
        commission=pending_commission,
        conversionRate=round(conversion, 2),
        pendingCommissions=pending_count,
    )


@router.get("/commissions", response_model=list[CommissionOut])
async def commissions(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    account = await _get_account(db, user.id)
    if account is None:
        return []
    rows = await db.scalars(
        select(AffiliateCommission).where(AffiliateCommission.affiliate_id == account.id).order_by(AffiliateCommission.created_at.desc())
    )
    return [
        CommissionOut(
            id=c.id,
            affiliateCode=c.code,
            orderId=c.order_id,
            orderAmount=c.order_amount,
            rate=c.rate,
            amount=c.amount,
            status=c.status,
            createdAt=c.created_at,
        )
        for c in rows
    ]


@router.post("/clicks", response_model=AffiliateClickOut, status_code=201)
async def record_click(payload: AffiliateClickCreate, db: AsyncSession = Depends(get_db)):
    account = await db.scalar(select(AffiliateAccount).where(AffiliateAccount.promo_code == payload.code.strip()))
    if account is None:
        raise HTTPException(status_code=404, detail="Unknown referral code")
    click = AffiliateClick(affiliate_id=account.id, code=account.promo_code, source=payload.source or "direct")
    account.total_clicks += 1
    db.add(click)
    await db.commit()
    await db.refresh(click)
    return AffiliateClickOut(id=click.id, affiliateCode=click.code, source=click.source, createdAt=click.created_at)


@router.post("/payout", status_code=201)
async def request_payout(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    account = await _get_account(db, user.id)
    if account is None:
        raise HTTPException(status_code=404, detail="No affiliate account yet")
    if account.pending_balance < MIN_PAYOUT:
        raise HTTPException(status_code=400, detail=f"Minimum payout is ${MIN_PAYOUT:.2f}")
    amount = round(account.pending_balance, 2)
    db.add(Payout(affiliate_id=account.id, amount=amount, status="requested"))
    account.pending_balance = 0.0
    await db.commit()
    return {"status": "requested", "amount": amount, "requested": True}
