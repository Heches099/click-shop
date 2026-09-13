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
    """Stripe webhook: marks orders paid on payment_intent.succeeded.

    Security: the event is only processed when a webhook signing secret is
    configured and the `stripe-signature` header verifies. An unsigned or
    missing signature is rejected — an unauthenticated payload is never
    trusted even in development.
    """
    import stripe

    stripe.api_key = settings.stripe_secret_key

    if not settings.stripe_webhook_secret:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Webhooks are not enabled on this instance",
        )

    sig_header = request.headers.get("stripe-signature")
    if not sig_header:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Missing stripe-signature header")

    payload = await request.body()
    try:
        event = stripe.Webhook.construct_event(payload, sig_header, settings.stripe_webhook_secret)
    except (ValueError, stripe.error.SignatureVerificationError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid signature") from None

    if event["type"] == "payment_intent.succeeded":
        intent = event["data"]["object"]
        order_id = intent.get("metadata", {}).get("order_id")
        if not order_id:
            return {"received": True}
        order = await db.scalar(select(Order).where(Order.id == order_id))
        if order is None or order.status != "pending":
            return {"received": True}
        # Defense in depth: the amount in the event must match the order total.
        expected_cents = int(round(order.total * 100))
        actual_cents = int(intent.get("amount") or 0)
        if actual_cents != expected_cents:
            return {"received": True}
        order.status = "paid"
        order.payment_id = intent["id"]
        await db.commit()
    return {"received": True}
