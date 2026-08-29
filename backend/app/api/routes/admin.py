import re
import unicodedata

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_admin
from app.api.serializers import order_out, product_out
from app.core.database import get_db
from app.models import AffiliateAccount, Category, Order, OrderItem, Product, User
from app.schemas.category import CategoryOut
from app.schemas.order import OrderOut, OrderStatusUpdate, OrderTrackingUpdate
from app.schemas.product import ProductCreate, ProductOut, ProductUpdate

router = APIRouter(prefix="/admin", tags=["admin"])


def slugify(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii").lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return text or "item"


async def _product_by_id(db: AsyncSession, product_id: str) -> Product:
    product = await db.scalar(select(Product).where(Product.id == product_id))
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


async def _category_by_id(db: AsyncSession, category_id: str) -> Category:
    category = await db.scalar(select(Category).where(Category.id == category_id))
    if category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return category


# ------------------------------------------------------------ dashboard

@router.get("/stats")
async def dashboard_stats(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    revenue = await db.scalar(
        select(func.coalesce(func.sum(Order.total), 0.0)).where(Order.status.in_(["paid", "shipped", "delivered"]))
    )
    order_count = await db.scalar(select(func.count(Order.id)))
    product_count = await db.scalar(select(func.count(Product.id)))
    user_count = await db.scalar(select(func.count(User.id)))
    low_stock = await db.scalar(select(func.count(Product.id)).where(Product.stock <= 5))
    sales_today = await db.scalar(
        select(func.count(Order.id)).where(Order.status.in_(["paid", "shipped", "delivered"]))
    )
    recent = await db.scalars(
        select(Order)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category),
        )
        .order_by(Order.created_at.desc())
        .limit(10)
    )
    return {
        "revenue": round(float(revenue or 0), 2),
        "orders": order_count or 0,
        "products": product_count or 0,
        "users": user_count or 0,
        "lowStock": low_stock or 0,
        "salesToday": sales_today or 0,
        "recentOrders": [order_out(o) for o in recent],
    }


# ------------------------------------------------------------ orders

@router.get("/orders", response_model=list[OrderOut])
async def list_all_orders(
    status_filter: str | None = Query(default=None, alias="status"),
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    query = (
        select(Order)
        .options(selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category))
        .order_by(Order.created_at.desc())
        .limit(200)
    )
    if status_filter:
        query = query.where(Order.status == status_filter)
    orders = await db.scalars(query)
    return [order_out(o) for o in orders]


@router.put("/orders/{order_id}/status", response_model=OrderOut)
async def update_order_status(
    order_id: str,
    payload: OrderStatusUpdate,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    order = await db.scalar(
        select(Order)
        .options(selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category))
        .where(Order.id == order_id)
    )
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    order.status = payload.status
    await db.commit()
    return order_out(order)


@router.put("/orders/{order_id}/tracking", response_model=OrderOut)
async def update_order_tracking(
    order_id: str,
    payload: OrderTrackingUpdate,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    order = await db.scalar(
        select(Order)
        .options(selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category))
        .where(Order.id == order_id)
    )
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    order.tracking_number = payload.tracking_number
    if order.status == "paid":
        order.status = "shipped"
    await db.commit()
    return order_out(order)


# ------------------------------------------------------------ products

@router.post("/products", response_model=ProductOut, status_code=status.HTTP_201_CREATED)
async def create_product(
    payload: ProductCreate,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    category = await db.scalar(select(Category).where(Category.slug == payload.category_slug))
    if category is None:
        raise HTTPException(status_code=400, detail=f"Unknown category slug '{payload.category_slug}'")
    slug = slugify(payload.name)
    existing = await db.scalar(select(Product).where(Product.slug == slug))
    if existing:
        slug = f"{slug}-{existing.id[:6]}"
    product = Product(
        name=payload.name,
        slug=slug,
        description=payload.description,
        price=payload.price,
        original_price=payload.original_price,
        images=payload.images,
        category_id=category.id,
        brand=payload.brand,
        stock=payload.stock,
        specifications=payload.specifications,
        colors=payload.colors,
        sizes=payload.sizes,
        is_featured=payload.is_featured,
        is_best_seller=payload.is_best_seller,
        is_new_arrival=payload.is_new_arrival,
        is_flash_sale=payload.is_flash_sale,
        is_recommended=payload.is_recommended,
    )
    db.add(product)
    await db.commit()
    await db.refresh(product)
    product.category = category
    return product_out(product)


@router.put("/products/{product_id}", response_model=ProductOut)
async def update_product(
    product_id: str,
    payload: ProductUpdate,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    product = await _product_by_id(db, product_id)
    data = payload.model_dump(exclude_unset=True)
    if "category_slug" in data:
        category = await db.scalar(select(Category).where(Category.slug == data.pop("category_slug")))
        if category is None:
            raise HTTPException(status_code=400, detail="Unknown category slug")
        product.category_id = category.id
    for field, value in data.items():
        setattr(product, field, value)
    await db.commit()
    await db.refresh(product)
    category = await db.scalar(select(Category).where(Category.id == product.category_id))
    product.category = category
    return product_out(product)


@router.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(product_id: str, admin: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    product = await _product_by_id(db, product_id)
    product.is_active = False  # soft delete keeps order history intact
    await db.commit()
    return None


# ------------------------------------------------------------ categories

@router.post("/categories", response_model=CategoryOut, status_code=status.HTTP_201_CREATED)
async def create_category(
    name: str,
    image: str | None = None,
    parent_id: str | None = None,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    slug = slugify(name)
    if await db.scalar(select(Category).where(Category.slug == slug)):
        raise HTTPException(status_code=409, detail="Category slug already exists")
    if parent_id and not await db.scalar(select(Category).where(Category.id == parent_id)):
        raise HTTPException(status_code=400, detail="Parent category not found")
    category = Category(name=name, slug=slug, image=image, parent_id=parent_id)
    db.add(category)
    await db.commit()
    await db.refresh(category)
    return CategoryOut.model_validate(category)


@router.put("/categories/{category_id}", response_model=CategoryOut)
async def update_category(
    category_id: str,
    name: str | None = None,
    image: str | None = None,
    parent_id: str | None = None,
    sort_order: int | None = None,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    category = await _category_by_id(db, category_id)
    if name:
        category.name = name
        new_slug = slugify(name)
        conflict = await db.scalar(select(Category).where(Category.slug == new_slug, Category.id != category_id))
        if not conflict:
            category.slug = new_slug
    if image is not None:
        category.image = image
    if parent_id is not None:
        category.parent_id = parent_id or None
    if sort_order is not None:
        category.sort_order = sort_order
    await db.commit()
    await db.refresh(category)
    return CategoryOut.model_validate(category)


@router.delete("/categories/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_category(category_id: str, admin: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    category = await _category_by_id(db, category_id)
    has_products = await db.scalar(select(func.count(Product.id)).where(Product.category_id == category_id))
    if has_products:
        raise HTTPException(status_code=400, detail="Category still has products")
    await db.delete(category)
    await db.commit()
    return None


# ------------------------------------------------------------ affiliates

@router.get("/affiliates")
async def list_affiliates(admin: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    accounts = await db.scalars(select(AffiliateAccount).order_by(AffiliateAccount.created_at.desc()))
    return [
        {
            "id": a.id,
            "userId": a.user_id,
            "name": a.name,
            "email": a.email,
            "promoCode": a.promo_code,
            "status": a.status,
            "totalClicks": a.total_clicks,
            "totalSales": a.total_sales,
            "pendingBalance": a.pending_balance,
        }
        for a in accounts
    ]


@router.put("/affiliates/{affiliate_id}/status")
async def update_affiliate_status(
    affiliate_id: str,
    status: str,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    account = await db.scalar(select(AffiliateAccount).where(AffiliateAccount.id == affiliate_id))
    if account is None:
        raise HTTPException(status_code=404, detail="Affiliate not found")
    if status not in ("active", "suspended"):
        raise HTTPException(status_code=400, detail="Invalid status")
    account.status = status
    await db.commit()
    return {"id": account.id, "status": account.status}
