from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.serializers import product_out
from app.core.database import get_db
from app.models import Category, Product
from app.schemas.common import Paginated
from app.schemas.product import ProductOut

router = APIRouter(prefix="/products", tags=["products"])


async def _list_active(db: AsyncSession, *filters) -> list[Product]:
    query = (
        select(Product)
        .options(selectinload(Product.category))
        .where(Product.is_active.is_(True), *filters)
        .order_by(Product.created_at.desc(), Product.name.asc())
    )
    result = await db.scalars(query)
    return list(result)


@router.get("/featured", response_model=list[ProductOut])
async def get_featured(db: AsyncSession = Depends(get_db)):
    return [product_out(p) for p in await _list_active(db, Product.is_featured.is_(True))]


@router.get("/best-sellers", response_model=list[ProductOut])
async def get_best_sellers(db: AsyncSession = Depends(get_db)):
    return [product_out(p) for p in await _list_active(db, Product.is_best_seller.is_(True))]


@router.get("/new-arrivals", response_model=list[ProductOut])
async def get_new_arrivals(db: AsyncSession = Depends(get_db)):
    return [product_out(p) for p in await _list_active(db, Product.is_new_arrival.is_(True))]


@router.get("/flash-sales", response_model=list[ProductOut])
async def get_flash_sales(db: AsyncSession = Depends(get_db)):
    return [product_out(p) for p in await _list_active(db, Product.is_flash_sale.is_(True))]


@router.get("/recommended", response_model=list[ProductOut])
async def get_recommended(db: AsyncSession = Depends(get_db)):
    return [product_out(p) for p in await _list_active(db, Product.is_recommended.is_(True))]


@router.get("/search", response_model=list[ProductOut])
async def search_products(
    q: str = Query(min_length=1),
    limit: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    term = f"%{q.strip()}%"
    products = await _list_active(
        db, or_(Product.name.ilike(term), Product.description.ilike(term), Product.brand.ilike(term))
    )
    return [product_out(p) for p in products[:limit]]


@router.get("", response_model=Paginated[ProductOut])
async def list_products(
    category: str | None = None,
    q: str | None = None,
    sort: str = Query(default="newest", pattern="^(newest|price_asc|price_desc|rating|popular)$"),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=24, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    filters = [Product.is_active.is_(True)]
    if category:
        cat = await db.scalar(select(Category).where(Category.slug == category))
        if cat is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")
        filters.append(Product.category_id == cat.id)
    if q:
        term = f"%{q.strip()}%"
        filters.append(or_(Product.name.ilike(term), Product.description.ilike(term), Product.brand.ilike(term)))

    total = await db.scalar(select(func.count(Product.id)).where(*filters)) or 0

    order_by = {
        "newest": Product.created_at.desc(),
        "price_asc": Product.price.asc(),
        "price_desc": Product.price.desc(),
        "rating": Product.rating.desc(),
        "popular": Product.review_count.desc(),
    }[sort]

    result = await db.scalars(
        select(Product)
        .options(selectinload(Product.category))
        .where(*filters)
        .order_by(order_by)
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    items = [product_out(p) for p in result]
    return Paginated[ProductOut](items=items, total=total, page=page, page_size=page_size)


@router.get("/{product_id}", response_model=ProductOut)
async def get_product(product_id: str, db: AsyncSession = Depends(get_db)):
    product = await db.scalar(
        select(Product).options(selectinload(Product.category)).where(Product.id == product_id)
    )
    if product is None or not product.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    return product_out(product)
