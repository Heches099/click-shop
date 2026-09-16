from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.serializers import product_out
from app.core.database import get_db
from app.models import Collection, Guide, Product
from app.schemas.content import CollectionDetailOut, CollectionOut, GuideDetailOut, GuideOut

router = APIRouter(prefix="/content", tags=["content"])


@router.get("/collections", response_model=list[CollectionOut])
async def list_collections(db: AsyncSession = Depends(get_db)):
    rows = await db.scalars(
        select(Collection)
        .options(selectinload(Collection.products))
        .where(Collection.is_active.is_(True))
        .order_by(Collection.sort_order.asc(), Collection.name.asc())
    )
    result = []
    for c in rows:
        result.append(
            CollectionOut(
                id=c.id,
                slug=c.slug,
                name=c.name,
                description=c.description,
                tag=c.tag,
                image=c.image,
                productCount=len(c.products),
            )
        )
    return result


@router.get("/collections/{slug}", response_model=CollectionDetailOut)
async def get_collection(slug: str, db: AsyncSession = Depends(get_db)):
    collection = await db.scalar(
        select(Collection)
        .options(selectinload(Collection.products).selectinload(Product.category))
        .where(Collection.slug == slug, Collection.is_active.is_(True))
    )
    if collection is None:
        raise HTTPException(status_code=404, detail="Collection not found")
    return CollectionDetailOut(
        id=collection.id,
        slug=collection.slug,
        name=collection.name,
        description=collection.description,
        tag=collection.tag,
        image=collection.image,
        productCount=len(collection.products),
        products=[product_out(p) for p in collection.products],
    )


@router.get("/guides", response_model=list[GuideOut])
async def list_guides(db: AsyncSession = Depends(get_db)):
    rows = await db.scalars(
        select(Guide).where(Guide.is_active.is_(True)).order_by(Guide.published_at.desc())
    )
    return [
        GuideOut(
            id=g.id,
            slug=g.slug,
            title=g.title,
            summary=g.summary,
            categorySlug=g.category_slug,
            image=g.image,
            publishedAt=g.published_at,
        )
        for g in rows
    ]


@router.get("/guides/{slug}", response_model=GuideDetailOut)
async def get_guide(slug: str, db: AsyncSession = Depends(get_db)):
    guide = await db.scalar(
        select(Guide).where(Guide.slug == slug, Guide.is_active.is_(True))
    )
    if guide is None:
        raise HTTPException(status_code=404, detail="Guide not found")
    return GuideDetailOut(
        id=guide.id,
        slug=guide.slug,
        title=guide.title,
        summary=guide.summary,
        body=guide.body,
        categorySlug=guide.category_slug,
        image=guide.image,
        publishedAt=guide.published_at,
    )