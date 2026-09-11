"""Amazon affiliate provider abstraction.

Architecture
------------
    AffiliateProvider
      ├── AffiliateLinkProvider       (ACTIVE — curated real products + links)
      └── AmazonCreatorsApiProvider   (FUTURE — official Amazon API when eligible)

Flutter never talks to Amazon directly — it only talks to the Click Shop
backend. The backend normalizes whatever the active provider returns into
the internal Click Shop product model.

Affiliate Link Mode (current): curated destination categories with affiliate
URLs are always available and require no API credentials, plus a hand-picked
set of REAL Amazon products (real ASINs + verified CDN product images) served
as static configuration. Prices are intentionally omitted: prices are shown
only when Amazon API access supplies live, correct, localized quotes.

Amazon API mode (future): when the Associates account becomes eligible for
the Amazon Creators API / PA-API, implement search_products/get_product_by_asin
in AmazonCreatorsApiProvider. Do NOT implement it before eligibility, and do
NOT fabricate credentials.
"""

from __future__ import annotations

import abc
import logging
from dataclasses import dataclass

from app.core.config import settings

logger = logging.getLogger(__name__)


class AffiliateApiUnavailableError(RuntimeError):
    """Raised when the Amazon API is requested but not available/eligible."""


@dataclass(frozen=True)
class AffiliateCategory:
    """A curated affiliate destination category (link mode)."""

    id: str
    name: str
    description: str
    keyword: str
    image_key: str


@dataclass(frozen=True)
class AmazonProduct:
    """Normalized Amazon product data returned by the provider."""

    asin: str
    title: str
    image_url: str
    price: float
    currency: str = "USD"
    rating: float = 0.0
    review_count: int = 0
    brand: str = ""
    category: str = ""
    detail_page_url: str = ""


# Curated affiliate destination categories. These are click-through links to
# Amazon search pages — always active, no live inventory claim.
CURATED_AFFILIATE_CATEGORIES: tuple[AffiliateCategory, ...] = (
    AffiliateCategory(
        id="gaming",
        name="Gaming",
        description="Explore top gaming products and accessories.",
        keyword="gaming",
        image_key="gaming",
    ),
    AffiliateCategory(
        id="gaming-laptops",
        name="Gaming Laptops",
        description="Powerful laptops built for gaming.",
        keyword="gaming laptop",
        image_key="laptop",
    ),
    AffiliateCategory(
        id="gaming-pcs",
        name="Gaming PCs",
        description="Ready-to-play gaming desktops.",
        keyword="gaming pc",
        image_key="gaming_pc",
    ),
    AffiliateCategory(
        id="gaming-monitors",
        name="Gaming Monitors",
        description="High-refresh displays for smooth play.",
        keyword="gaming monitor",
        image_key="monitor",
    ),
    AffiliateCategory(
        id="graphics-cards",
        name="Graphics Cards",
        description="GPUs for the best visuals and FPS.",
        keyword="graphics card",
        image_key="gpu",
    ),
    AffiliateCategory(
        id="gaming-keyboards",
        name="Gaming Keyboards",
        description="Mechanical and RGB keyboards.",
        keyword="gaming keyboard",
        image_key="keyboard",
    ),
    AffiliateCategory(
        id="gaming-mouse",
        name="Gaming Mouse",
        description="Precision mice for competitive play.",
        keyword="gaming mouse",
        image_key="mouse",
    ),
    AffiliateCategory(
        id="gaming-headsets",
        name="Gaming Headsets",
        description="Immersive audio for chat and gameplay.",
        keyword="gaming headset",
        image_key="headset",
    ),
)

# ---------------------------------------------------------------------------
# Curated REAL Amazon products — hand-picked, image-verified in 2025/2026.
# Prices are intentionally omitted (0.0): Amazon prices are localized and
# stale snapshots would be misleading. The Flutter card hides $0 prices.
# All ASINs are structurally valid and map to live Amazon detail pages.
# ---------------------------------------------------------------------------
CURATED_AMAZON_PRODUCTS: tuple[AmazonProduct, ...] = (
    AmazonProduct(
        asin="B0DW1X5YCQ",
        title=(
            "ASUS ROG Strix G16 (2025) Gaming Laptop, 16\" ROG Nebula 2.5K "
            "240Hz, NVIDIA GeForce RTX 5070 Ti, Intel Core Ultra 9 275HX, "
            "32GB DDR5, 1TB SSD, G615LR-AS96"
        ),
        image_url="https://m.media-amazon.com/images/I/71dvs4J6B7L.jpg",
        price=0.0,
        currency="USD",
        rating=0.0,
        review_count=0,
        brand="ASUS",
        category="gaming-laptops",
        detail_page_url="https://www.amazon.com/dp/B0DW1X5YCQ",
    ),
    AmazonProduct(
        asin="B0FNR773ZJ",
        title=(
            "Prebuilt Gaming Desktop PC, AMD Ryzen 5 5500, GeForce RTX 3050 "
            "6GB, 16GB DDR4 3200MHz RAM, 1TB NVMe SSD, ARGB Air Cooling, "
            "Wi-Fi, Tower Computer for Gaming, Streaming, Editing"
        ),
        image_url="https://m.media-amazon.com/images/I/61dF5SPnpyL.jpg",
        price=0.0,
        currency="USD",
        rating=0.0,
        review_count=0,
        brand="iBUYPOWER",
        category="gaming-pcs",
        detail_page_url="https://www.amazon.com/dp/B0FNR773ZJ",
    ),
    AmazonProduct(
        asin="B0GLV9PML4",
        title=(
            "Samsung 27\" Odyssey G5 (G51F) Series QHD 1440P Gaming Monitor, "
            "180Hz, 1ms, AMD FreeSync, HDR10, Height Adjustable Stand"
        ),
        image_url="https://m.media-amazon.com/images/I/71BMK6HmBbL.jpg",
        price=0.0,
        currency="USD",
        rating=0.0,
        review_count=0,
        brand="Samsung",
        category="gaming-monitors",
        detail_page_url="https://www.amazon.com/dp/B0GLV9PML4",
    ),
    AmazonProduct(
        asin="B0CVPHDLTD",
        title=(
            "ASUS Dual GeForce RTX 4060 Ti EVO OC Edition 8GB GDDR6, "
            "DLSS 3, HDMI 2.1a, DisplayPort 1.4a, Axial-tech Fan Design, "
            "3 Year Warranty"
        ),
        image_url="https://m.media-amazon.com/images/I/41MMvMtwqnL.jpg",
        price=0.0,
        currency="USD",
        rating=0.0,
        review_count=0,
        brand="ASUS",
        category="graphics-cards",
        detail_page_url="https://www.amazon.com/dp/B0CVPHDLTD",
    ),
    AmazonProduct(
        asin="B07G11G2X8",
        title=(
            "Redragon K580 Wired RGB Mechanical Gaming Keyboard, Macro Key "
            "& Media Wheel, 5 On-Board Keybinding Buttons, Blue Switches"
        ),
        image_url="https://m.media-amazon.com/images/I/71NFUiC1XaL.jpg",
        price=0.0,
        currency="USD",
        rating=0.0,
        review_count=0,
        brand="Redragon",
        category="gaming-keyboards",
        detail_page_url="https://www.amazon.com/dp/B07G11G2X8",
    ),
    AmazonProduct(
        asin="B07QKC4WWD",
        title=(
            "Logitech G502 Lightspeed Wireless Gaming Mouse, Hero 16K "
            "Sensor, 16000 DPI, RGB, Adjustable Weights, 11 Programmable "
            "Buttons, PC/Mac - Black"
        ),
        image_url="https://m.media-amazon.com/images/I/31bygHDH1hL.jpg",
        price=0.0,
        currency="USD",
        rating=0.0,
        review_count=0,
        brand="Logitech",
        category="gaming-mouse",
        detail_page_url="https://www.amazon.com/dp/B07QKC4WWD",
    ),
)


class AffiliateProvider(abc.ABC):
    """Abstract interface implemented by every affiliate provider.

    The Flutter app only ever consumes the normalized backend responses;
    it never depends on provider details.
    """

    def get_categories(self) -> list[AffiliateCategory]:
        return list(CURATED_AFFILIATE_CATEGORIES)

    @abc.abstractmethod
    async def search_products(
        self,
        query: str,
        category: str = "",
        item_count: int = 20,
    ) -> list[AmazonProduct]:
        """Search for real Amazon products. Empty when no API is available."""

    @abc.abstractmethod
    async def get_product_by_asin(self, asin: str) -> AmazonProduct | None:
        """Fetch a single product by ASIN, or None when unavailable."""


class AffiliateLinkProvider(AffiliateProvider):
    """ACTIVE MODE — curated real Amazon products + category search links.

    Product endpoints return the hand-picked [CURATED_AMAZON_PRODUCTS]
    (real ASINs + verified CDN images). Prices are omitted because they are
    locale-dependent and change frequently.  Category endpoints continue to
    return curated search-page links with the tracking tag.
    """

    async def search_products(
        self,
        query: str,
        category: str = "",
        item_count: int = 20,
    ) -> list[AmazonProduct]:
        cat = (category or "").strip().lower()
        q = (query or "").strip().lower()
        results = list(CURATED_AMAZON_PRODUCTS)
        if cat and cat not in ("gaming", "amazon"):
            results = [p for p in results if p.category.lower() == cat]
        if q and q not in ("gaming", "amazon"):
            tokens = [t for t in q.split() if len(t) >= 3]
            if tokens:
                results = [
                    p
                    for p in results
                    if all(
                        t in (p.title + " " + p.brand + " " + p.category).lower()
                        for t in tokens
                    )
                ]
        return results[:item_count]

    async def get_product_by_asin(self, asin: str) -> AmazonProduct | None:
        normalized = asin.strip().upper()
        return next(
            (p for p in CURATED_AMAZON_PRODUCTS if p.asin == normalized), None
        )


class AmazonCreatorsApiProvider(AffiliateProvider):
    """FUTURE MODE — official Amazon Creators API / PA-API.

    Do NOT activate before the Associates account is eligible for the API,
    and do NOT implement a bypass for the eligibility requirement.

    When eligibility is granted and this provider is implemented, it must
    normalize Amazon responses into [AmazonProduct] so the Flutter layer and
    route layer remain unchanged.
    """

    async def search_products(
        self,
        query: str,
        category: str = "",
        item_count: int = 20,
    ) -> list[AmazonProduct]:
        raise AffiliateApiUnavailableError(
            "Amazon Creators API is not available for this account yet"
        )

    async def get_product_by_asin(self, asin: str) -> AmazonProduct | None:
        raise AffiliateApiUnavailableError(
            "Amazon Creators API is not available for this account yet"
        )


def get_amazon_provider() -> AffiliateProvider:
    """Factory that selects the active provider.

    * API enabled AND fully configured  -> future Creators API provider.
    * API enabled but credentials missing -> safe fallback to link mode
      (never crash, never leak).
    * API disabled (default)              -> AffiliateLinkProvider.
    """
    if settings.amazon_api_ready:
        # Future: swap in the implemented Creators API provider once eligible.
        return AmazonCreatorsApiProvider()

    if settings.amazon_api_enabled and not settings.amazon_api_credentials_present:
        logger.warning(
            "Amazon API is enabled but credentials are missing; "
            "falling back to affiliate-link mode."
        )

    return AffiliateLinkProvider()