"""Centralized Amazon affiliate URL generation.

SECURITY
--------
* The partner tag and marketplace ALWAYS come from server-side configuration
  (backend env vars). Callers cannot supply a tag or marketplace.
* ASINs are strictly validated before any URL is built.
* Search keywords are percent-encoded with `urlencode`, so a user can never
  inject extra query parameters (e.g. `&tag=someone-else`) into the URL.

This is the ONLY place in the codebase that builds Amazon affiliate URLs.
"""

from __future__ import annotations

import re
from urllib.parse import urlencode

from app.core.config import settings

_ASIN_LENGTH = 10
_ASIN_RE = re.compile(r"^[A-Za-z0-9]{10}$")

MAX_KEYWORD_LENGTH = 100
MAX_CATEGORY_LENGTH = 50


class InvalidAsinError(ValueError):
    """Raised when an ASIN fails validation."""


class InvalidKeywordError(ValueError):
    """Raised when a search keyword fails validation."""


def is_valid_asin(asin: str) -> bool:
    """Return True if `asin` is a structurally valid Amazon ASIN (10 chars)."""
    if not isinstance(asin, str):
        return False
    return bool(_ASIN_RE.fullmatch(asin.strip()))


def normalize_asin(asin: str) -> str:
    """Validate and normalize an ASIN to canonical uppercase form."""
    if not isinstance(asin, str) or not _ASIN_RE.fullmatch(asin.strip()):
        raise InvalidAsinError("Invalid ASIN")
    return asin.strip().upper()


def build_affiliate_product_url(asin: str) -> str:
    """Build the affiliate URL for a single product.

    Shape: https://{marketplace}/dp/{ASIN}?tag={partner_tag}
    """
    normalized = normalize_asin(asin)
    return (
        f"https://{settings.amazon_marketplace}/dp/{normalized}"
        f"?tag={settings.amazon_partner_tag}"
    )


def build_affiliate_search_url(keyword: str) -> str:
    """Build the affiliate URL for an Amazon search result page.

    Shape: https://{marketplace}/s?k={keyword}&tag={partner_tag}

    The keyword is percent-encoded, preventing parameter injection.
    """
    kw = (keyword or "").strip()
    if not kw or len(kw) > MAX_KEYWORD_LENGTH:
        raise InvalidKeywordError("Keyword must be 1-100 characters")

    query = urlencode({"k": kw, "tag": settings.amazon_partner_tag})
    return f"https://{settings.amazon_marketplace}/s?{query}"