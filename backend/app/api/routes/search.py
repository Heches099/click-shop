from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, Query
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models import AnalyticsEvent, Category, Product
from app.schemas.insight import SearchSuggestionOut, SuggestOut

router = APIRouter(prefix="/search", tags=["search"])


@router.get("/suggest", response_model=SuggestOut)
async def search_suggest(
    q: str = Query(min_length=1),
    limit: int = Query(default=6, ge=1, le=12),
    db: AsyncSession = Depends(get_db),
):
    """Autocomplete: matching products, categories and a popular-query hint.

    A lightweight deterministic implementation — the shape is stable so a
    stronger semantic engine can be swapped in without changing the client.
    """
    term = f"%{q.strip()}%"

    products = await db.scalars(
        select(Product)
        .options(selectinload(Product.category))
        .where(Product.is_active.is_(True), or_(Product.name.ilike(term), Product.brand.ilike(term)))
        .order_by(Product.rating.desc())
        .limit(limit)
    )
    categories = await db.scalars(
        select(Category).where(Category.name.ilike(term)).limit(4)
    )
    product_suggestions = [
        SearchSuggestionOut(
            product_id=p.id,
            slug=p.slug,
            name=p.name,
            brand=p.brand,
            price=p.price,
            image=p.images[0] if p.images else None,
        )
        for p in products
    ]
    category_list = [
        {"slug": c.slug, "name": c.name} for c in categories
    ]
    return SuggestOut(
        products=product_suggestions,
        categories=category_list,
        popular=await popular_search_terms(db, limit=5),
    )


@router.get("/popular", response_model=list[str])
async def popular_searches(
    limit: int = Query(default=10, ge=1, le=25),
    db: AsyncSession = Depends(get_db),
):
    return await popular_search_terms(db, limit=limit)


async def popular_search_terms(db: AsyncSession, limit: int) -> list[str]:
    """Most frequent real search queries from the last 30 days.

    Aggregated in Python so it works identically on SQLite (tests) and
    Postgres (production) without vendor-specific JSON functions.
    """
    cutoff = datetime.now(UTC) - timedelta(days=30)
    rows = await db.scalars(
        select(AnalyticsEvent)
        .where(AnalyticsEvent.event_type == "search", AnalyticsEvent.created_at >= cutoff)
        .order_by(AnalyticsEvent.created_at.desc())
        .limit(1500)
    )
    counts: dict[str, tuple[int, float]] = {}
    for event in rows:
        raw = (event.payload or {}).get("q", "") if isinstance(event.payload, dict) else ""
        q = str(raw).strip().lower()
        if len(q) < 2 or len(q) > 60:
            continue
        count, latest = counts.get(q, (0, 0.0))
        counts[q] = (count + 1, max(latest, event.created_at.timestamp()))
    ranked = sorted(counts.items(), key=lambda kv: (-kv[1][0], -kv[1][1]))
    return [q for q, _ in ranked[:limit]]