from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.serializers import category_out, product_out
from app.core.database import get_db
from app.models import Category, Product
from app.schemas.category import CategoryOut
from app.schemas.product import ProductOut

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get("", response_model=list[CategoryOut])
async def get_categories(db: AsyncSession = Depends(get_db)):
    result = await db.scalars(
        select(Category)
        .options(selectinload(Category.subcategories))
        .where(Category.parent_id.is_(None))
        .order_by(Category.sort_order.asc(), Category.name.asc())
    )
    return [category_out(c) for c in result]


@router.get("/{slug}", response_model=CategoryOut)
async def get_category(slug: str, db: AsyncSession = Depends(get_db)):
    category = await db.scalar(
        select(Category)
        .options(selectinload(Category.subcategories))
        .where(Category.slug == slug)
    )
    if category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    return category_out(category)


@router.get("/{slug}/products", response_model=list[ProductOut])
async def get_category_products(slug: str, db: AsyncSession = Depends(get_db)):
    category = await db.scalar(select(Category).where(Category.slug == slug))
    if category is None:
        raise HTTPException(status_code=404, detail="Category not found")
    result = await db.scalars(
        select(Product)
        .options(selectinload(Product.category))
        .where(Product.category_id == category.id, Product.is_active.is_(True))
        .order_by(Product.created_at.desc())
    )
    return [product_out(p) for p in result]
