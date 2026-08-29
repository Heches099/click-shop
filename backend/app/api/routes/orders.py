import uuid

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_user
from app.api.serializers import order_out
from app.core.config import settings
from app.core.database import get_db
from app.models import Address, AffiliateAccount, AffiliateCommission, Order, OrderItem, Product, User
from app.schemas.order import OrderCreateRequest, OrderOut

router = APIRouter(prefix="/orders", tags=["orders"])

SHIPPING_FEE = 5.99
FREE_SHIPPING_THRESHOLD = 50.0
TAX_RATE = 0.08


async def _get_order(db: AsyncSession, order_id: str, user: User) -> Order:
    order = await db.scalar(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category),
            selectinload(Order.user),
        )
        .execution_options(populate_existing=True)
        .where(Order.id == order_id)
    )
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.user_id != user.id and not user.is_admin:
        raise HTTPException(status_code=403, detail="Not your order")
    return order


@router.post("", response_model=OrderOut, status_code=201)
async def create_order(
    payload: OrderCreateRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    product_ids = [i.product_id for i in payload.items]
    products = await db.scalars(
        select(Product).options(selectinload(Product.category)).where(
            Product.id.in_(product_ids), Product.is_active.is_(True)
        )
    )
    product_map = {p.id: p for p in products}
    for line in payload.items:
        if line.product_id not in product_map:
            raise HTTPException(status_code=400, detail=f"Product {line.product_id} not available")
        if product_map[line.product_id].stock < line.quantity:
            raise HTTPException(status_code=400, detail=f"Not enough stock for {product_map[line.product_id].name}")

    subtotal = 0.0
    order_items: list[OrderItem] = []
    for line in payload.items:
        product = product_map[line.product_id]
        unit_price = product.price
        subtotal += unit_price * line.quantity
        order_items.append(
            OrderItem(
                product_id=product.id,
                product_snapshot={
                    "id": product.id,
                    "name": product.name,
                    "description": product.description,
                    "price": product.price,
                    "originalPrice": product.original_price,
                    "images": product.images or [],
                    "brand": product.brand,
                    "category": product.category.slug if product.category else "",
                },
                quantity=line.quantity,
                unit_price=unit_price,
                selected_color=line.selected_color,
                selected_size=line.selected_size,
            )
        )

    shipping_fee = 0.0 if subtotal >= FREE_SHIPPING_THRESHOLD else SHIPPING_FEE
    tax = round(subtotal * TAX_RATE, 2)
    total = round(subtotal + shipping_fee + tax, 2)

    address_id = str(uuid.uuid4())
    shipping_address = {
        "id": address_id,
        "name": payload.shipping_address.name,
        "phone": payload.shipping_address.phone,
        "street": payload.shipping_address.street,
        "city": payload.shipping_address.city,
        "state": payload.shipping_address.state,
        "zipCode": payload.shipping_address.zip_code,
        "country": payload.shipping_address.country,
        "isDefault": payload.shipping_address.is_default,
    }

    order = Order(
        user_id=user.id,
        items=order_items,
        subtotal=round(subtotal, 2),
        shipping_fee=shipping_fee,
        tax=tax,
        total=total,
        status="pending",
        payment_method=payload.payment_method,
        shipping_address=shipping_address,
        ref_code=payload.ref_code,
    )
    db.add(order)

    # Persist the shipping address for the user if it is marked default.
    if payload.shipping_address.is_default:
        await db.execute(
            Address.__table__.update().where(Address.user_id == user.id).values(is_default=False)
        )
        db.add(
            Address(
                user_id=user.id,
                name=payload.shipping_address.name,
                phone=payload.shipping_address.phone,
                street=payload.shipping_address.street,
                city=payload.shipping_address.city,
                state=payload.shipping_address.state,
                zip_code=payload.shipping_address.zip_code,
                country=payload.shipping_address.country,
                is_default=True,
            )
        )

    # Decrement stock.
    for product in product_map.values():
        product.stock = max(0, product.stock - next(
            (i.quantity for i in payload.items if i.product_id == product.id), 0
        ))

    # Affiliate commission on checkout with a referral code.
    if payload.ref_code and payload.ref_code.strip():
        aff = await db.scalar(select(AffiliateAccount).where(AffiliateAccount.promo_code == payload.ref_code.strip()))
        if aff:
            await db.flush()  # ensure order.id is assigned
            amount = round(total * settings.affiliate_commission_rate, 2)
            db.add(
                AffiliateCommission(
                    affiliate_id=aff.id,
                    order_id=order.id,
                    code=aff.promo_code,
                    order_amount=total,
                    rate=settings.affiliate_commission_rate,
                    amount=amount,
                    status="pending",
                )
            )
            aff.total_sales += 1
            aff.total_commission = round(aff.total_commission + amount, 2)
            aff.pending_balance = round(aff.pending_balance + amount, 2)

    await db.commit()
    return order_out(await _get_order(db, order.id, user))


@router.get("", response_model=list[OrderOut])
async def my_orders(
    status_filter: str | None = Query(default=None, alias="status"),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category),
        )
        .where(Order.user_id == user.id)
        .order_by(Order.created_at.desc())
    )
    if status_filter:
        query = query.where(Order.status == status_filter)
    orders = await db.scalars(query)
    return [order_out(o) for o in orders]


@router.get("/{order_id}", response_model=OrderOut)
async def get_order(order_id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    return order_out(await _get_order(db, order_id, user))


@router.post("/{order_id}/cancel", response_model=OrderOut)
async def cancel_order(order_id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    order = await _get_order(db, order_id, user)
    if order.status not in ("pending", "paid"):
        raise HTTPException(status_code=400, detail=f"Cannot cancel order in status '{order.status}'")
    order.status = "cancelled"
    # Restore stock.
    for item in order.items:
        product = item.product
        if product:
            product.stock += item.quantity
    await db.commit()
    return order_out(await _get_order(db, order_id, user))
