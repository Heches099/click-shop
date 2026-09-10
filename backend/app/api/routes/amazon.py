"""Secure Amazon affiliate endpoints.

* Affiliate categories are always available and are built server-side from
  trusted configuration via the centralized URL service.
* Product search returns [] while Amazon API access is disabled/ineligible.
* Product lookup validates the ASIN before doing anything.
* No endpoint accepts an arbitrary URL, and the backend never fetches a
  user-supplied URL (no SSRF).
* Errors are generic and never leak credentials, stack traces, or provider
  implementation details.
* API responses contain only public product/category data and public
  affiliate destination URLs.
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Query, status

from app.services.amazon_affiliate import (
    MAX_KEYWORD_LENGTH,
    build_affiliate_product_url,
    build_affiliate_search_url,
    is_valid_asin,
    normalize_asin,
)
from app.services.amazon_provider import (
    AffiliateApiUnavailableError,
    AffiliateCategory,
    AffiliateProvider,
    AmazonProduct,
    get_amazon_provider,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/amazon", tags=["amazon"])


def _category_to_out(category: AffiliateCategory) -> dict:
    """Serialize a category + its server-built affiliate URL."""
    return {
        "id": category.id,
        "name": category.name,
        "description": category.description,
        "keyword": category.keyword,
        "imageKey": category.image_key,
        "affiliateUrl": build_affiliate_search_url(category.keyword),
    }


def _product_to_out(product: AmazonProduct, category: str) -> dict:
    """Serialize normalized product data.

    The affiliate URL is always generated here from the validated ASIN so no
    caller can supply or override the destination or tracking tag.
    """
    return {
        "id": f"amazon-{product.asin}",
        "name": product.title,
        "description": product.title,
        "price": product.price,
        "originalPrice": None,
        "images": [product.image_url] if product.image_url else [],
        "rating": product.rating,
        "reviewCount": product.review_count,
        "category": category,
        "stock": 1,
        "brand": product.brand or "Amazon",
        "specifications": {},
        "colors": [],
        "sizes": [],
        "asin": product.asin,
        "amazonUrl": build_affiliate_product_url(product.asin),
    }


@router.get("/categories")
async def get_affiliate_categories() -> list[dict]:
    """Curated affiliate destination categories (link mode).

    Always available regardless of API eligibility. Public data only.
    """
    provider: AffiliateProvider = get_amazon_provider()
    return [_category_to_out(c) for c in provider.get_categories()]


@router.get("/products")
async def get_amazon_products(
    q: str = Query(default="gaming", min_length=1, max_length=MAX_KEYWORD_LENGTH),
    category: str = Query(default="", max_length=MAX_KEYWORD_LENGTH),
    limit: int = Query(default=20, ge=1, le=50),
) -> list[dict]:
    """Search Amazon products.

    Returns [] when the Amazon API is disabled or not eligible. Fails safe —
    never crashes and never returns an error containing internals.
    """
    # `q` is only ever used as a search term for the future API provider;
    # it is never treated as a URL and never fetched client-side.
    provider: AffiliateProvider = get_amazon_provider()
    try:
        products = await provider.search_products(
            query=q.strip(),
            category=category.strip(),
            item_count=limit,
        )
    except AffiliateApiUnavailableError:
        return []
    except Exception:  # pragma: no cover - defensive, never leak details
        logger.error("Amazon product search failed.")
        return []

    return [_product_to_out(p, category.strip() or "gaming") for p in products]


@router.get("/products/{asin}")
async def get_amazon_product(asin: str) -> dict:
    """Fetch a single Amazon product by ASIN.

    The ASIN is validated before any work happens; malformed ASINs are
    rejected with 400. Returns 404 when no product data is available.
    """
    if not is_valid_asin(asin):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid ASIN",
        )

    provider: AffiliateProvider = get_amazon_provider()
    try:
        product = await provider.get_product_by_asin(normalize_asin(asin))
    except AffiliateApiUnavailableError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Amazon product not found",
        ) from None
    except Exception:  # pragma: no cover - defensive
        logger.error("Amazon product lookup failed.")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Amazon product temporarily unavailable",
        ) from None

    if product is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Amazon product not found",
        )

    return _product_to_out(product, "")