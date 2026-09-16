import re
import unicodedata
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_current_admin
from app.api.serializers import order_out, product_out
from app.core.database import get_db
from app.models import (
    AffiliateAccount,
    AnalyticsEvent,
    AuditLog,
    Category,
    Collection,
    ContactMessage,
    Guide,
    Order,
    OrderItem,
    Product,
    User,
)
from app.schemas.category import CategoryOut
from app.schemas.content import (
    CollectionCreate,
    CollectionDetailOut,
    CollectionOut,
    CollectionUpdate,
    GuideCreate,
    GuideDetailOut,
    GuideOut,
    GuideUpdate,
)
from app.schemas.insight import AuditLogOut, ContactMessageOut
from app.schemas.order import OrderOut, OrderStatusUpdate, OrderTrackingUpdate
from app.schemas.product import ProductCreate, ProductOut, ProductUpdate

router = APIRouter(prefix="/admin", tags=["admin"])


def slugify(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii").lower()
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return text or "item"


async def log_audit(
    db: AsyncSession,
    admin: User,
    action: str,
    target_type: str,
    target_id: str | None = None,
    detail: dict | None = None,
    ip: str | None = None,
) -> None:
    """Record a sensitive owner action. Never logs passwords/tokens/secrets."""
    db.add(
        AuditLog(
            admin_user_id=admin.id,
            action=action,
            target_type=target_type,
            target_id=target_id,
            detail=detail or {},
            ip=ip,
        )
    )


def _client_ip(request: Request | None) -> str | None:
    if request is None or request.client is None:
        return None
    return request.client.host


async def _product_by_id(db: AsyncSession, product_id: str) -> Product:
    product = await db.scalar(select(Product).where(Product.id == product_id))
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


async def _category_by_id(db: AsyncSession, category_id: str) -> Category:
    category = await db.scalar(
        select(Category).options(selectinload(Category.subcategories)).where(Category.id == category_id)
    )
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
    request: Request,
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
    await log_audit(
        db, admin, "order_status_changed", "order", order.id,
        {"from": order.status, "to": payload.status}, _client_ip(request),
    )
    order.status = payload.status
    await db.commit()
    return order_out(order)


@router.put("/orders/{order_id}/tracking", response_model=OrderOut)
async def update_order_tracking(
    order_id: str,
    payload: OrderTrackingUpdate,
    request: Request,
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
    await log_audit(
        db, admin, "order_tracking_set", "order", order.id,
        {"tracking_number": payload.tracking_number}, _client_ip(request),
    )
    order.tracking_number = payload.tracking_number
    if order.status == "paid":
        order.status = "shipped"
    await db.commit()
    return order_out(order)


# ------------------------------------------------------------ products

@router.post("/products", response_model=ProductOut, status_code=status.HTTP_201_CREATED)
async def create_product(
    payload: ProductCreate,
    request: Request,
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
    await db.flush()
    await log_audit(
        db, admin, "product_created", "product", product.id,
        {"name": payload.name, "price": payload.price}, _client_ip(request),
    )
    await db.commit()
    await db.refresh(product)
    product.category = category
    return product_out(product)


@router.put("/products/{product_id}", response_model=ProductOut)
async def update_product(
    product_id: str,
    payload: ProductUpdate,
    request: Request,
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
    await log_audit(
        db, admin, "product_updated", "product", product.id,
        {"fields": sorted(set(data) | ({"category_slug"} if "category_slug" in data else set()))},
        _client_ip(request),
    )
    await db.commit()
    await db.refresh(product)
    category = await db.scalar(select(Category).where(Category.id == product.category_id))
    product.category = category
    return product_out(product)


@router.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: str,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    product = await _product_by_id(db, product_id)
    product.is_active = False  # soft delete keeps order history intact
    await log_audit(
        db, admin, "product_deactivated", "product", product.id,
        {"name": product.name}, _client_ip(request),
    )
    await db.commit()
    return None


# ------------------------------------------------------------ categories

@router.post("/categories", response_model=CategoryOut, status_code=status.HTTP_201_CREATED)
async def create_category(
    name: str,
    image: str | None = None,
    parent_id: str | None = None,
    request: Request = None,
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
    await db.flush()
    await log_audit(db, admin, "category_created", "category", category.id, {"name": name}, _client_ip(request))
    await db.commit()
    return CategoryOut.model_validate(await _category_by_id(db, category.id))


@router.put("/categories/{category_id}", response_model=CategoryOut)
async def update_category(
    category_id: str,
    name: str | None = None,
    image: str | None = None,
    parent_id: str | None = None,
    sort_order: int | None = None,
    request: Request = None,
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
    await log_audit(db, admin, "category_updated", "category", category.id, {}, _client_ip(request))
    await db.commit()
    return CategoryOut.model_validate(category)


@router.delete("/categories/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_category(
    category_id: str,
    request: Request = None,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    category = await _category_by_id(db, category_id)
    has_products = await db.scalar(select(func.count(Product.id)).where(Product.category_id == category_id))
    if has_products:
        raise HTTPException(status_code=400, detail="Category still has products")
    await log_audit(db, admin, "category_deleted", "category", category.id, {}, _client_ip(request))
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
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    account = await db.scalar(select(AffiliateAccount).where(AffiliateAccount.id == affiliate_id))
    if account is None:
        raise HTTPException(status_code=404, detail="Affiliate not found")
    if status not in ("active", "suspended"):
        raise HTTPException(status_code=400, detail="Invalid status")
    await log_audit(
        db, admin, "affiliate_status_changed", "affiliate", account.id,
        {"code": account.promo_code, "from": account.status, "to": status}, _client_ip(request),
    )
    account.status = status
    await db.commit()
    return {"id": account.id, "status": account.status}


# ------------------------------------------------------------ ops analytics

async def _event_count(db: AsyncSession, event_type: str, since: datetime) -> int:
    value = await db.scalar(
        select(func.count(AnalyticsEvent.id)).where(
            AnalyticsEvent.event_type == event_type,
            AnalyticsEvent.created_at >= since,
        )
    )
    return value or 0


@router.get("/analytics/summary")
async def analytics_summary(
    days: int = Query(default=30, ge=1, le=90),
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    """Answers: what are customers searching for / saving / abandoning?"""
    cutoff = datetime.now(UTC) - timedelta(days=days)

    top_searches: list[dict] = []
    search_rows = await db.scalars(
        select(AnalyticsEvent)
        .where(AnalyticsEvent.event_type == "search", AnalyticsEvent.created_at >= cutoff)
        .order_by(AnalyticsEvent.created_at.desc())
        .limit(2000)
    )
    counts: dict[str, int] = {}
    for e in search_rows:
        q = (e.payload or {}).get("q", "") if isinstance(e.payload, dict) else ""
        q = str(q).strip().lower()
        if 2 <= len(q) <= 60:
            counts[q] = counts.get(q, 0) + 1
    top_searches = [{"query": q, "count": c} for q, c in sorted(counts.items(), key=lambda kv: -kv[1])[:25]]

    view_counts: dict[str, int] = {}
    view_rows = await db.scalars(
        select(AnalyticsEvent)
        .where(AnalyticsEvent.event_type == "view_product", AnalyticsEvent.created_at >= cutoff)
        .order_by(AnalyticsEvent.created_at.desc())
        .limit(2000)
    )
    pid_counts: dict[str, int] = {}
    for e in view_rows:
        if e.product_id:
            pid_counts[e.product_id] = pid_counts.get(e.product_id, 0) + 1
    if pid_counts:
        top_ids = [pid for pid, _ in sorted(pid_counts.items(), key=lambda kv: -kv[1])[:10]]
        rows = await db.scalars(select(Product).where(Product.id.in_(top_ids)))
        name_map = {p.id: p.name for p in rows}
        view_counts = [
            {"productId": pid, "name": name_map.get(pid, ""), "views": n}
            for pid, n in sorted(pid_counts.items(), key=lambda kv: -kv[1])[:10]
        ]

    return {
        "days": days,
        "topSearches": top_searches,
        "topProductViews": view_counts,
        "funnel": {
            "viewProduct": await _event_count(db, "view_product", cutoff),
            "addToCart": await _event_count(db, "add_to_cart", cutoff),
            "beginCheckout": await _event_count(db, "begin_checkout", cutoff),
            "purchase": await _event_count(db, "purchase", cutoff),
            "saveProduct": await _event_count(db, "save_product", cutoff),
            "addToCompare": await _event_count(db, "add_to_compare", cutoff),
            "affiliateClick": await _event_count(db, "affiliate_click", cutoff),
            "search": await _event_count(db, "search", cutoff),
        },
    }


# ------------------------------------------------------------ contact inbox

@router.get("/contact-messages", response_model=list[ContactMessageOut])
async def list_contact_messages(
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    rows = await db.scalars(select(ContactMessage).order_by(ContactMessage.created_at.desc()).limit(200))
    return [
        ContactMessageOut(
            id=m.id, name=m.name, email=m.email, subject=m.subject,
            message=m.message, isRead=m.is_read, createdAt=m.created_at,
        )
        for m in rows
    ]


@router.patch("/contact-messages/{message_id}/read", response_model=ContactMessageOut)
async def mark_contact_read(
    message_id: str,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    message = await db.scalar(select(ContactMessage).where(ContactMessage.id == message_id))
    if message is None:
        raise HTTPException(status_code=404, detail="Message not found")
    message.is_read = True
    await db.commit()
    await db.refresh(message)
    return ContactMessageOut(
        id=message.id, name=message.name, email=message.email, subject=message.subject,
        message=message.message, isRead=message.is_read, createdAt=message.created_at,
    )


# ------------------------------------------------------------ audit log

@router.get("/audit-log", response_model=list[AuditLogOut])
async def list_audit_log(
    limit: int = Query(default=100, ge=1, le=500),
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    rows = await db.scalars(
        select(AuditLog).order_by(AuditLog.created_at.desc()).limit(limit)
    )
    rows = list(rows)
    email_map: dict[str, str] = {}
    if rows:
        admin_ids = {r.admin_user_id for r in rows}
        email_rows = await db.execute(select(User.id, User.email).where(User.id.in_(admin_ids)))
        email_map = {uid: email for uid, email in email_rows.all()}
    return [
        AuditLogOut(
            id=r.id,
            adminEmail=email_map.get(r.admin_user_id, ""),
            action=r.action,
            targetType=r.target_type,
            targetId=r.target_id,
            detail=r.detail or {},
            createdAt=r.created_at,
        )
        for r in rows
    ]


# ------------------------------------------------------------ collections

@router.get("/collections", response_model=list[CollectionOut])
async def list_all_collections(admin: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    rows = await db.scalars(
        select(Collection).options(selectinload(Collection.products)).order_by(Collection.sort_order.asc())
    )
    return [
        CollectionOut(
            id=c.id, slug=c.slug, name=c.name, description=c.description,
            tag=c.tag, image=c.image, productCount=len(c.products or []),
        )
        for c in rows
    ]


@router.post("/collections", response_model=CollectionDetailOut, status_code=status.HTTP_201_CREATED)
async def create_collection(
    payload: CollectionCreate,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    if await db.scalar(select(Collection).where(Collection.slug == payload.slug)):
        raise HTTPException(status_code=409, detail="Collection slug already exists")
    collection = Collection(
        slug=payload.slug,
        name=payload.name,
        description=payload.description,
        tag=payload.tag,
        image=payload.image,
        sort_order=payload.sort_order,
    )
    if payload.product_ids:
        products = await db.scalars(select(Product).where(Product.id.in_(payload.product_ids)))
        collection.products = list(products)
    db.add(collection)
    await db.flush()
    await log_audit(db, admin, "collection_created", "collection", collection.id, {"name": payload.name}, _client_ip(request))
    await db.commit()
    refreshed = await db.scalar(
        select(Collection).options(selectinload(Collection.products).selectinload(Product.category))
        .where(Collection.id == collection.id)
    )
    return CollectionDetailOut(
        id=refreshed.id, slug=refreshed.slug, name=refreshed.name,
        description=refreshed.description, tag=refreshed.tag, image=refreshed.image,
        productCount=len(refreshed.products or []),
        products=[product_out(p) for p in refreshed.products],
    )


@router.put("/collections/{collection_id}", response_model=CollectionDetailOut)
async def update_collection(
    collection_id: str,
    payload: CollectionUpdate,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    collection = await db.scalar(
        select(Collection).options(selectinload(Collection.products)).where(Collection.id == collection_id)
    )
    if collection is None:
        raise HTTPException(status_code=404, detail="Collection not found")
    data = payload.model_dump(exclude_unset=True)
    product_ids = data.pop("product_ids", None)
    for field, value in data.items():
        setattr(collection, field, value)
    if product_ids is not None:
        products = await db.scalars(select(Product).where(Product.id.in_(product_ids)))
        collection.products = list(products)
    await log_audit(db, admin, "collection_updated", "collection", collection.id, {}, _client_ip(request))
    await db.commit()
    refreshed = await db.scalar(
        select(Collection).options(selectinload(Collection.products).selectinload(Product.category))
        .where(Collection.id == collection.id)
    )
    return CollectionDetailOut(
        id=refreshed.id, slug=refreshed.slug, name=refreshed.name,
        description=refreshed.description, tag=refreshed.tag, image=refreshed.image,
        productCount=len(refreshed.products or []),
        products=[product_out(p) for p in refreshed.products],
    )


@router.delete("/collections/{collection_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_collection(
    collection_id: str,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    collection = await db.scalar(select(Collection).where(Collection.id == collection_id))
    if collection is None:
        raise HTTPException(status_code=404, detail="Collection not found")
    await log_audit(db, admin, "collection_deleted", "collection", collection.id, {}, _client_ip(request))
    await db.delete(collection)
    await db.commit()
    return None


# ------------------------------------------------------------ guides

@router.get("/guides", response_model=list[GuideOut])
async def list_all_guides(admin: User = Depends(get_current_admin), db: AsyncSession = Depends(get_db)):
    rows = await db.scalars(select(Guide).order_by(Guide.published_at.desc()))
    return [
        GuideOut(
            id=g.id, slug=g.slug, title=g.title, summary=g.summary,
            categorySlug=g.category_slug, image=g.image, publishedAt=g.published_at,
        )
        for g in rows
    ]


@router.post("/guides", response_model=GuideDetailOut, status_code=status.HTTP_201_CREATED)
async def create_guide(
    payload: GuideCreate,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    if await db.scalar(select(Guide).where(Guide.slug == payload.slug)):
        raise HTTPException(status_code=409, detail="Guide slug already exists")
    guide = Guide(
        slug=payload.slug,
        title=payload.title,
        summary=payload.summary,
        body=payload.body,
        category_slug=payload.category_slug,
        image=payload.image,
        published_at=datetime.now(UTC),
    )
    db.add(guide)
    await db.flush()
    await log_audit(db, admin, "guide_created", "guide", guide.id, {"title": payload.title}, _client_ip(request))
    await db.commit()
    await db.refresh(guide)
    return GuideDetailOut(
        id=guide.id, slug=guide.slug, title=guide.title, summary=guide.summary,
        body=guide.body, categorySlug=guide.category_slug, image=guide.image,
        publishedAt=guide.published_at,
    )


@router.put("/guides/{guide_id}", response_model=GuideDetailOut)
async def update_guide(
    guide_id: str,
    payload: GuideUpdate,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    guide = await db.scalar(select(Guide).where(Guide.id == guide_id))
    if guide is None:
        raise HTTPException(status_code=404, detail="Guide not found")
    data = payload.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(guide, field, value)
    await log_audit(db, admin, "guide_updated", "guide", guide.id, {"title": guide.title}, _client_ip(request))
    await db.commit()
    await db.refresh(guide)
    return GuideDetailOut(
        id=guide.id, slug=guide.slug, title=guide.title, summary=guide.summary,
        body=guide.body, categorySlug=guide.category_slug, image=guide.image,
        publishedAt=guide.published_at,
    )


@router.delete("/guides/{guide_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_guide(
    guide_id: str,
    request: Request,
    admin: User = Depends(get_current_admin),
    db: AsyncSession = Depends(get_db),
):
    guide = await db.scalar(select(Guide).where(Guide.id == guide_id))
    if guide is None:
        raise HTTPException(status_code=404, detail="Guide not found")
    await log_audit(db, admin, "guide_deleted", "guide", guide.id, {}, _client_ip(request))
    await db.delete(guide)
    await db.commit()
    return None
