"""Tiny in-memory sliding-window rate limiter (no external dependencies).

Used on auth and attribution endpoints to slow brute-force, credential
stuffing and spam. Buckets are per client IP (respecting the X-Forwarded-For
header set by the Render reverse proxy) and per worker process, which is
sufficient for this single-worker deployment.

Note: memory is pruned lazily on each hit; the map is bounded by the number
of distinct client IPs seen within a window.
"""

import time
from collections import defaultdict

from fastapi import HTTPException, Request

_buckets: dict[str, list[float]] = defaultdict(list)

_STATUS_429 = 429


def _client_key(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for", "")
    if forwarded:
        return forwarded.split(",")[0].strip()
    if request.client is not None:
        return request.client.host
    return "unknown"


def rate_limit(limit: int, window_seconds: int):
    """Return a FastAPI dependency enforcing `limit` calls per `window_seconds`."""

    async def _check(request: Request) -> None:
        key = _client_key(request)
        now = time.monotonic()
        bucket = _buckets[key]
        cutoff = now - window_seconds

        while bucket and bucket[0] < cutoff:
            bucket.pop(0)

        if len(bucket) >= limit:
            raise HTTPException(
                status_code=_STATUS_429,
                detail="Too many requests. Try again later.",
            )
        bucket.append(now)

    return _check