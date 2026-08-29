from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.config import settings
from app.core.database import get_db
from app.models import Order, User
from app.schemas.payment import CreateIntentRequest, PaymentIntentResponse

router = APIRouter(prefix="/payments", tags=["payments"])


@router.post("/create-intent", response_model=PaymentIntentResponse)
async def create_payment_intent(
    payload: CreateIntentRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    order = await db.scalar(select(Order).where(Order.id == payload.order_id))
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.user_id != user.id and not user.is_admin:
        raise HTTPException(status_code=403, detail="Not your order")
    if order.status != "pending":
        raise HTTPException(status_code=400, detail=f"Order is already '{order.status}'")

    if settings.stripe_enabled:
        import stripe

        stripe.api_key = settings.stripe_secret_key
        intent = stripe.PaymentIntent.create(
            amount=int(round(order.total * 100)),
            currency="usd",
            metadata={"order_id": order.id, "user_id": user.id},
            automatic_payment_methods={"enabled": True},
        )
        order.payment_id = intent.id
        await db.commit()
        return PaymentIntentResponse(payment_intent_id=intent.id, client_secret=intent.client_secret)
    else:
        # Dev fallback when Stripe isn't configured: simulate a client secret.
        mock = f"mock_secret_{order.id}"
        order.payment_id = f"mock_pi_{order.id}"
        await db.commit()
        return PaymentIntentResponse(payment_intent_id=order.payment_id, client_secret=mock)


@router.post("/webhook")
async def stripe_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    """Stripe webhook: marks orders paid on payment_intent.succeeded."""
    import stripe

    stripe.api_key = settings.stripe_secret_key
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    if settings.stripe_webhook_secret and sig_header:
        try:
            event = stripe.Webhook.construct_event(payload, sig_header, settings.stripe_webhook_secret)
        except (ValueError, stripe.error.SignatureVerificationError):
            raise HTTPException(status_code=400, detail="Invalid signature")
    else:
        import json

        event = json.loads(payload)

    if event["type"] == "payment_intent.succeeded":
        intent = event["data"]["object"]
        order_id = intent.get("metadata", {}).get("order_id")
        if order_id:
            order = await db.scalar(select(Order).where(Order.id == order_id))
            if order and order.status == "pending":
                order.status = "paid"
                order.payment_id = intent["id"]
                await db.commit()
    return {"received": True}
