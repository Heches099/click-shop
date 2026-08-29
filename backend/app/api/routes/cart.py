from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_user
from app.api.serializers import cart_item_out
from app.core.database import get_db
from app.models import Cart, CartItem, Product, User
from app.schemas.cart import CartItemAddRequest, CartItemUpdateRequest, CartOut

router = APIRouter(prefix="/cart", tags=["cart"])


def _cart_query():
    return (
        select(Cart)
        .options(selectinload(Cart.items).selectinload(CartItem.product).selectinload(Product.category))
        .execution_options(populate_existing=True)
    )


async def _load_cart(db: AsyncSession, user_id: str) -> Cart:
    cart = await db.scalar(_cart_query().where(Cart.user_id == user_id))
    if cart is None:
        cart = Cart(user_id=user_id)
        db.add(cart)
        await db.commit()
        cart = await db.scalar(_cart_query().where(Cart.user_id == user_id))
    return cart


def _cart_out(cart: Cart) -> CartOut:
    items = [cart_item_out(i) for i in cart.items]
    subtotal = sum(i.product.price * i.quantity for i in cart.items if i.product)
    return CartOut(items=items, subtotal=round(subtotal, 2), count=sum(i.quantity for i in cart.items))


@router.get("", response_model=CartOut)
async def get_cart(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    cart = await _load_cart(db, user.id)
    return _cart_out(cart)


@router.post("/items", response_model=CartOut, status_code=201)
async def add_to_cart(
    payload: CartItemAddRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    product = await db.scalar(select(Product).where(Product.id == payload.product_id))
    if product is None or not product.is_active:
        raise HTTPException(status_code=404, detail="Product not found")
    if product.stock <= 0:
        raise HTTPException(status_code=400, detail="Product out of stock")

    cart = await _load_cart(db, user.id)
    existing = next((i for i in cart.items if i.product_id == payload.product_id), None)
    if existing:
        existing.quantity = min(existing.quantity + payload.quantity, 99, max(product.stock, 1))
        existing.selected_color = payload.selected_color or existing.selected_color
        existing.selected_size = payload.selected_size or existing.selected_size
    else:
        db.add(
            CartItem(
                cart_id=cart.id,
                product_id=payload.product_id,
                quantity=min(payload.quantity, 99),
                selected_color=payload.selected_color,
                selected_size=payload.selected_size,
            )
        )
    await db.commit()
    cart = await _load_cart(db, user.id)
    return _cart_out(cart)


@router.put("/items/{item_id}", response_model=CartOut)
async def update_cart_item(
    item_id: str,
    payload: CartItemUpdateRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    cart = await _load_cart(db, user.id)
    item = next((i for i in cart.items if i.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Cart item not found")
    if item.product and item.product.stock > 0:
        item.quantity = min(payload.quantity, item.product.stock)
    else:
        item.quantity = payload.quantity
    await db.commit()
    cart = await _load_cart(db, user.id)
    return _cart_out(cart)


@router.delete("/items/{item_id}", response_model=CartOut)
async def remove_cart_item(
    item_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    cart = await _load_cart(db, user.id)
    item = next((i for i in cart.items if i.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Cart item not found")
    await db.execute(delete(CartItem).where(CartItem.id == item_id))
    await db.commit()
    cart = await _load_cart(db, user.id)
    return _cart_out(cart)


@router.delete("", response_model=CartOut)
async def clear_cart(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    cart = await _load_cart(db, user.id)
    await db.execute(delete(CartItem).where(CartItem.cart_id == cart.id))
    await db.commit()
    cart = await _load_cart(db, user.id)
    return _cart_out(cart)
