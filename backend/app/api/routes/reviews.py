from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.api.serializers import product_out
from app.core.database import get_db
from app.models import Product, Review, User
from app.schemas.product import ProductOut
from app.schemas.review import ReviewCreate, ReviewOut

router = APIRouter(prefix="/products", tags=["reviews"])


@router.get("/{product_id}/reviews", response_model=list[ReviewOut])
async def product_reviews(product_id: str, db: AsyncSession = Depends(get_db)):
    reviews = list(
        await db.scalars(
            select(Review).where(Review.product_id == product_id).order_by(Review.created_at.desc()).limit(100)
        )
    )
    user_ids = [r.user_id for r in reviews]
    users = {}
    if user_ids:
        rows = await db.execute(select(User.id, User.name).where(User.id.in_(user_ids)))
        users = {row[0]: row[1] for row in rows}
    return [
        ReviewOut(
            id=r.id,
            product_id=r.product_id,
            user_id=r.user_id,
            user_name=users.get(r.user_id),
            rating=r.rating,
            title=r.title,
            comment=r.comment,
            created_at=r.created_at,
        )
        for r in reviews
    ]


@router.post("/{product_id}/reviews", response_model=ReviewOut, status_code=status.HTTP_201_CREATED)
async def create_review(
    product_id: str,
    payload: ReviewCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    product = await db.scalar(select(Product).where(Product.id == product_id))
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    existing = await db.scalar(
        select(Review).where(Review.product_id == product_id, Review.user_id == user.id)
    )
    if existing:
        raise HTTPException(status_code=409, detail="You already reviewed this product")

    review = Review(
        product_id=product_id,
        user_id=user.id,
        rating=payload.rating,
        title=payload.title,
        comment=payload.comment,
    )
    db.add(review)
    await db.flush()

    # Recompute product aggregate rating.
    row = (
        await db.execute(
            select(func.avg(Review.rating), func.count(Review.id)).where(Review.product_id == product_id)
        )
    ).one()
    product.rating = round(float(row[0]) if row[0] is not None else payload.rating, 1)
    product.review_count = int(row[1])
    await db.commit()

    return ReviewOut(
        id=review.id,
        product_id=product_id,
        user_id=user.id,
        user_name=user.name,
        rating=payload.rating,
        title=payload.title,
        comment=payload.comment,
        created_at=review.created_at,
    )
