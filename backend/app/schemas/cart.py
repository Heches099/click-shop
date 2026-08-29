from pydantic import BaseModel, Field

from app.schemas.product import ProductOut


class CartItemAddRequest(BaseModel):
    product_id: str
    quantity: int = Field(default=1, ge=1, le=99)
    selected_color: str | None = None
    selected_size: str | None = None


class CartItemUpdateRequest(BaseModel):
    quantity: int = Field(ge=1, le=99)


class CartItemOut(BaseModel):
    """Matches the app's CartItemModel shape."""

    model_config = {"populate_by_name": True}

    id: str
    product: ProductOut
    quantity: int
    selected_color: str | None = Field(default=None, alias="selectedColor")
    selected_size: str | None = Field(default=None, alias="selectedSize")


class CartOut(BaseModel):
    items: list[CartItemOut]
    subtotal: float = 0.0
    count: int = 0
