"""Amazon affiliate provider abstraction.

Architecture
------------
    AffiliateProvider
      ├── AffiliateLinkProvider       (ACTIVE — curated affiliate links only)
      └── AmazonCreatorsApiProvider   (FUTURE — official Amazon API when eligible)

Flutter never talks to Amazon directly — it only talks to the Click Shop
backend. The backend normalizes whatever the active provider returns into
the internal Click Shop product model.

Affiliate Link Mode (current): curated destination categories with affiliate
URLs are always available and require no API credentials.

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
    """ACTIVE MODE — curated affiliate destination links only.

    No live Amazon inventory is fetched, no scraping occurs, and the UI
    makes no claim of live products. Product endpoints return empty/safe
    results.
    """

    async def search_products(
        self,
        query: str,
        category: str = "",
        item_count: int = 20,
    ) -> list[AmazonProduct]:
        return []

    async def get_product_by_asin(self, asin: str) -> AmazonProduct | None:
        return None


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