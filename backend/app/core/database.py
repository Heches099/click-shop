from collections.abc import AsyncGenerator
from urllib.parse import urlsplit, urlunsplit

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings


def _clean_database_url(url: str) -> str:
    """Normalise the DATABASE_URL so asyncpg is always used."""
    if not url.startswith("postgres"):
        return url

    parts = urlsplit(url)

    # Ensure the scheme uses the asyncpg driver
    scheme = parts.scheme
    if scheme == "postgresql":
        scheme = "postgresql+asyncpg"
    elif scheme == "postgresql+psycopg2":
        scheme = "postgresql+asyncpg"

    # Strip query params that asyncpg/SQLAlchemy cannot pass directly
    return urlunsplit((scheme, parts.netloc, parts.path, "", parts.fragment))


_engine_kwargs = {"echo": False, "pool_pre_ping": True}
if settings.database_url.startswith("postgres"):
    _engine_kwargs.update({"pool_size": 10, "max_overflow": 20})

engine = create_async_engine(_clean_database_url(settings.database_url), **_engine_kwargs)

async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session
