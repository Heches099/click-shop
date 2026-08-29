from pydantic import BaseModel, Field


class CreateIntentRequest(BaseModel):
    order_id: str


class PaymentIntentResponse(BaseModel):
    payment_intent_id: str
    client_secret: str
    currency: str = "usd"
