import asyncio
from sqlalchemy import text
from app.core.database import engine

async def test():
    async with engine.connect() as conn:
        r = await conn.execute(text("SELECT 1"))
        print("DB connected:", r.scalar())

asyncio.run(test())
