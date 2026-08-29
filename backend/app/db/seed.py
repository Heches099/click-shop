"""Demo seed data. Run with: python -m app.db.seed

Creates tables (dev convenience), an admin user, categories and a catalog
of demo products. Safe to re-run (upserts by slug / email).
"""

import asyncio

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import async_session, engine
from app.core.security import hash_password
from app.models import Category, Product, User, Base

CATEGORIES = [
    ("Sneakers", "sneakers", "https://picsum.photos/seed/cat-sneakers/400/400", 1),
    ("Fashion", "fashion", "https://picsum.photos/seed/cat-fashion/400/400", 2),
    ("Electronics", "electronics", "https://picsum.photos/seed/cat-electronics/400/400", 3),
    ("Beauty", "beauty", "https://picsum.photos/seed/cat-beauty/400/400", 4),
    ("Home", "home", "https://picsum.photos/seed/cat-home/400/400", 5),
]

# name, slug, description, price, original_price, category, brand, stock, featured, best, new, flash, rec
PRODUCTS = [
    ("Air Max Runner 2024", "air-max-runner-2024", "A lightweight, breathable running sneaker with responsive cushioning for everyday performance.", 129.99, 159.99, "sneakers", "Nike", 12, True, True, False, False, True),
    ("Classic Cotton Hoodie", "classic-cotton-hoodie", "A premium heavyweight cotton hoodie with a relaxed fit and a soft brushed interior.", 59.99, None, "fashion", "H&M", 40, True, True, True, False, False),
    ("Pro Wireless Earbuds", "pro-wireless-earbuds", "Active noise cancelling wireless earbuds with 30h battery life and crystal clear calls.", 89.99, 119.99, "electronics", "Sony", 25, True, True, True, True, True),
    ("Retro Low-Top Sneaker", "retro-low-top-sneaker", "A classic retro low-top in premium leather with a cushioned footbed.", 99.0, None, "sneakers", "Adidas", 18, False, True, False, False, True),
    ("Everyday Joggers", "everyday-joggers", "Soft-stretch joggers with a tapered fit and zip pockets.", 39.99, 49.99, "fashion", "Uniqlo", 55, False, False, True, True, False),
    ("Ultrabook Laptop 14", "ultrabook-laptop-14", "A 14-inch ultrabook with a 12-core processor, 16GB RAM and all-day battery.", 999.0, 1199.0, "electronics", "Dell", 8, True, False, False, False, True),
    ("Hydrating Serum", "hydrating-serum", "Hyaluronic acid serum that deeply hydrates and plumps the skin.", 24.99, 34.99, "beauty", "The Ordinary", 60, True, False, True, False, True),
    ("Cast Iron Skillet", "cast-iron-skillet", "Pre-seasoned 12-inch cast iron skillet for perfect searing and baking.", 49.99, None, "home", "Lodge", 30, True, False, False, False, False),
    ("Trail Running Shoes", "trail-running-shoes", "Grippy trail runners with water-repellent mesh and rock protection.", 119.99, 139.99, "sneakers", "Salomon", 14, False, False, True, False, True),
    ("Linen Shirt", "linen-shirt", "Breathable 100% linen shirt, perfect for warm weather.", 45.0, 59.0, "fashion", "COS", 33, False, True, True, False, False),
    ("Smart Watch Series 9", "smart-watch-series-9", "GPS smart watch with heart-rate tracking, sleep insights and 18h battery.", 329.0, 399.0, "electronics", "Apple", 20, True, True, False, False, True),
    ("Matte Lipstick Set", "matte-lipstick-set", "A set of 5 long-wear matte lipsticks in everyday shades.", 29.99, None, "beauty", "MAC", 45, False, False, True, False, False),
    ("Coffee Grinder Pro", "coffee-grinder-pro", "Burr grinder with 40 grind settings and a static-free dosing cup.", 89.0, 109.0, "home", "Breville", 15, False, True, False, False, True),
    ("Court Classic Sneaker", "court-classic-sneaker", "Minimal court sneaker in clean white leather with gum sole.", 74.99, 89.99, "sneakers", "Vans", 22, False, False, False, True, True),
    ("Denim Jacket", "denim-jacket", "A timeless raw-denim jacket that gets better with age.", 79.99, None, "fashion", "Levi's", 26, False, True, False, False, False),
    ("Bluetooth Speaker 360", "bluetooth-speaker-360", "Waterproof 360-degree speaker with deep bass and 24h playtime.", 129.0, 169.0, "electronics", "JBL", 28, True, False, True, False, True),
    ("Vitamin C Cream", "vitamin-c-cream", "Brightening vitamin C moisturiser with SPF 30.", 31.99, 39.99, "beauty", "CeraVe", 38, False, False, True, False, True),
    ("Slim Backpack", "slim-backpack", "A water-repellent 20L backpack with padded laptop sleeve.", 54.99, 69.99, "home", "North Face", 21, False, True, False, False, False),
]

RATINGS = [4.5, 4.8, 4.6, 4.2, 4.9, 4.3, 4.7, 4.4, 4.6, 4.1, 4.8, 4.5, 4.7, 4.2, 4.6, 4.9, 4.4, 4.3]


async def seed() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session() as db:
        # Admin user
        admin = await db.scalar(select(User).where(User.email == settings.admin_email))
        if admin is None:
            db.add(
                User(
                    email=settings.admin_email,
                    hashed_password=hash_password(settings.admin_password),
                    name="Admin",
                    is_admin=True,
                )
            )

        # Categories
        cat_map: dict[str, Category] = {}
        for name, slug, image, order in CATEGORIES:
            cat = await db.scalar(select(Category).where(Category.slug == slug))
            if cat is None:
                cat = Category(name=name, slug=slug, image=image, sort_order=order)
                db.add(cat)
                await db.flush()
            cat_map[slug] = cat

        # Products
        for i, (name, slug, desc, price, original, cat_slug, brand, stock, feat, best, new, flash, rec) in enumerate(PRODUCTS):
            product = await db.scalar(select(Product).where(Product.slug == slug))
            rating, reviews = RATINGS[i % len(RATINGS)], 15 + i * 7
            data = dict(
                name=name,
                description=desc,
                price=price,
                original_price=original,
                images=[f"https://picsum.photos/seed/{slug}/600/600"],
                rating=rating,
                review_count=reviews,
                category_id=cat_map[cat_slug].id,
                brand=brand,
                stock=stock,
                specifications={"Material": "Premium", "Warranty": "1 year"},
                colors=["Black", "White"],
                sizes=["S", "M", "L", "XL"] if cat_slug == "fashion" else [],
                is_featured=feat,
                is_best_seller=best,
                is_new_arrival=new,
                is_flash_sale=flash,
                is_recommended=rec,
            )
            if product is None:
                db.add(Product(slug=slug, **data))
            else:
                for key, value in data.items():
                    setattr(product, key, value)

        await db.commit()

    await engine.dispose()
    print("Seed complete.")
    print(f"Admin: {settings.admin_email} / {settings.admin_password}")


if __name__ == "__main__":
    asyncio.run(seed())
