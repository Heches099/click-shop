from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.address import AddressIn, AddressOut
from app.schemas.product import ProductOut


class OrderItemIn(BaseModel):
    product_id: str
    quantity: int = Field(ge=1, le=99)
    selected_color: str | None = None
    selected_size: str | None = None


class OrderCreateRequest(BaseModel):
    items: list[OrderItemIn] = Field(min_length=1)
    shipping_address: AddressIn
    payment_method: str = "card"
    ref_code: str | None = None


class OrderItemOut(BaseModel):
    """Matches the app's CartItemModel used inside an OrderModel."""

    model_config = {"populate_by_name": True}

    product: ProductOut
    quantity: int
    selected_color: str | None = Field(default=None, alias="selectedColor")
    selected_size: str | None = Field(default=None, alias="selectedSize")


class OrderOut(BaseModel):
    """Matches the app's OrderModel (camelCase)."""

    id: str
    userId: str
    items: list[OrderItemOut]
    subtotal: float
    shippingFee: float = 0.0
    tax: float = 0.0
    total: float
    shippingAddress: AddressOut
    status: str
    createdAt: datetime
    trackingNumber: str | None = None
    paymentMethod: str | None = None
    paymentId: str | None = None


class OrderStatusUpdate(BaseModel):
    status: str = Field(pattern="^(pending|paid|shipped|delivered|cancelled)$")


class OrderTrackingUpdate(BaseModel):
    tracking_number: str = Field(min_length=1)
