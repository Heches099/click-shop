"""Demo seed data. Run with: python -m app.db.seed

Creates tables (dev convenience), an admin user, categories and a catalog
of demo products. Safe to re-run (upserts by slug / email).
"""

import asyncio
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import async_session, engine
from app.core.security import hash_password
from app.models import Base, Category, Collection, Guide, Product, User

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

# slug -> list of product slugs (curated, honest groupings for the demo catalog)
COLLECTIONS = [
    ("everyday-sneakers", "Everyday Sneakers", "Sneakers for daily wear — comfortable, versatile and built to be worn a lot. Pick by how you'll use them, not just how they look.", "Commuters", "https://picsum.photos/seed/col-sneakers/800/400", ["air-max-runner-2024", "retro-low-top-sneaker", "court-classic-sneaker", "trail-running-shoes"], 1),
    ("student-setup", "Student Setup", "The essentials for a focused year: a dependable laptop, quiet earbuds, a carry-all backpack and comfortable joggers.", "Students", "https://picsum.photos/seed/col-student/800/400", ["ultrabook-laptop-14", "pro-wireless-earbuds", "slim-backpack", "everyday-joggers"], 2),
    ("work-from-home", "Work From Home", "Everything that makes a home workspace calmer and more productive — desk-ready tech and comfort basics.", "Remote workers", "https://picsum.photos/seed/col-wfh/800/400", ["ultrabook-laptop-14", "smart-watch-series-9", "bluetooth-speaker-360", "coffee-grinder-pro"], 3),
    ("budget-tech", "Budget Tech", "Genuinely useful tech that will not blow a tight budget — picks under roughly $150 on this catalog.", "Budget shoppers", "https://picsum.photos/seed/col-budget/800/400", ["pro-wireless-earbuds", "bluetooth-speaker-360"], 4),
    ("creator-gear", "Creator Gear", "Reliable gear for recording, filming and staying on top of a creator workflow.", "Creators", "https://picsum.photos/seed/col-creator/800/400", ["smart-watch-series-9", "bluetooth-speaker-360", "pro-wireless-earbuds", "slim-backpack"], 5),
    ("home-essentials", "Home Essentials", "Thoughtful upgrades for the kitchen and everyday home routines.", "Home cooks", "https://picsum.photos/seed/col-home/800/400", ["cast-iron-skillet", "coffee-grinder-pro", "slim-backpack", "bluetooth-speaker-360"], 6),
]

GUIDES = [
    ("how-to-choose-a-laptop-for-university", "How to choose a laptop for university",
     "Buying a laptop for studies is about matching three things: the course workload, your daily carry, and a budget you can defend. This guide walks through what actually matters.",
     "## How to choose a laptop for university\n\nA university laptop has to survive four things: all-day classes, group work, late-night assignments and being carried everywhere.\n\n### What to look for\n- **Portability**: a 1.3–1.6 kg 14-inch machine is a realistic daily carry.\n- **Battery**: aim for a laptop that reliably lasts a full day (8+ hours of real use).\n- **RAM**: 16 GB keeps dozens of tabs and a word processor comfortable.\n- **Performance**: for essays, spreadsheets and browsing, a modern mid-range CPU is plenty. Video editing or engineering software shifts the priority to GPU and cores.\n\n### Common mistakes\n- Paying for a gaming GPU that adds weight and drains battery if you only write essays.\n- Ignoring ports — a university desk still loves USB-A and HDMI.\n\n### Bottom line\nMatch performance to your major, not to the sales pitch. On this catalog, the **Ultrabook Laptop 14** is the balanced pick; a **Slim Backpack** pairs with it for the daily carry.",
     "electronics", None, 1),
    ("wireless-earbuds-what-to-look-for", "Wireless earbuds: what actually matters",
     "Noise cancelling, battery life, fit, call quality — the earbud spec sheet is confusing. Here is what changes the experience day to day.",
     "## Wireless earbuds: what to look for\n\n\n### What to look for\n- **Fit**: if the seal is right, sound is better and noise-cancelling works. Try before you decide.\n- **Battery**: total time including the case matters more than a single charge number.\n- **Call quality**: microphones in a quiet room differ a lot from the real street.\n- **ANC**: only worth money if you ride transit, fly, or work in noise.\n\n### Common mistakes\n- Choosing by a single spec (e.g. '30 hours') without checking real-world case cycles.\n\n### Bottom line\nDecide your priority: silence (ANC) vs battery vs calls. The **Pro Wireless Earbuds** on this catalog cover all three acceptably for the price.",
     "electronics", None, 2),
    ("choosing-running-sneakers", "Choosing running sneakers for your routine",
     "Daily jogs, trail runs or court sessions need different shoes. This guide helps you match footwear to how you actually move.",
     "## Choosing running sneakers\n\n### What to look for\n- **Purpose**: road shoes cushion; trail shoes grip; court classics suit casual every-day wear.\n- **Fit**: your shoes should hold the heel and leave a thumb-width at the toe.\n- **Use case**: if you run twice a week, a do-everything trainer is enough.\n\n### Common mistakes\n- Buying purely on looks — colour fades in a season, fit is with you every run.\n\n### Bottom line\nMatch the shoe to your routine. **Air Max Runner 2024** is the cushioned daily trainer; **Trail Running Shoes** add grip when you leave the pavement; **Court Classic** covers casual days.",
     "sneakers", None, 3),
    ("work-from-home-space", "Setting up a calm work-from-home space",
     "A productive home office is mostly about reducing friction: a comfortable place to sit, fewer distractions and tools that just work.",
     "## Setting up a work-from-home space\n\n### What to look for\n- **Silence**: ANC earbuds transform a noisy home into a meeting-friendly space.\n- **Focus**: a dedicated desk zone and one speaker for music, rather than five gadgets.\n- **Routine**: a morning ritual (coffee, walk, plan) beats any gadget.\n\n### Bottom line\nStart with the laptop and earbuds, then add comfort — the **Work From Home** collection on ClickShop gathers sensible picks in one place.",
     "electronics", None, 4),
    ("wardrobe-basics", "Wardrobe basics: what to prioritise first",
     "A small, useful wardrobe beats a big unused one. Start with pieces that combine with each other and last.",
     "## Wardrobe basics\n\n### What to look for\n- **Versatility**: neutrals and classic cuts combine with everything.\n- **Quality**: heavier cotton, real denim and good stitching age well.\n- **Layering**: a hoodie, denim jacket and joggers cover most seasons.\n\n### Common mistakes\n- Buying a statement piece before the foundations exist.\n\n### Bottom line\nFoundations first: **Classic Cotton Hoodie**, **Denim Jacket** and **Everyday Joggers** combine into months of outfits.",
     "fashion", None, 5),
]


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

        # Curated collections — upserted by slug, membership refreshed so the
        # demo never shows a collection out of sync with its products.
        product_rows = await db.scalars(select(Product))
        product_by_slug = {p.slug: p for p in product_rows}
        for slug, name, desc, tag, image, product_slugs, sort_order in COLLECTIONS:
            collection = await db.scalar(select(Collection).where(Collection.slug == slug))
            if collection is None:
                collection = Collection(
                    slug=slug, name=name, description=desc, tag=tag,
                    image=image, sort_order=sort_order,
                )
                db.add(collection)
            else:
                collection.name = name
                collection.description = desc
                collection.tag = tag
                collection.image = image
                collection.sort_order = sort_order
                collection.is_active = True
            members = [product_by_slug[s] for s in product_slugs if s in product_by_slug]
            collection.products = members

        # Buying guides — upserted by slug.
        for slug, title, summary, body, cat_slug, image, order in GUIDES:
            guide = await db.scalar(select(Guide).where(Guide.slug == slug))
            if guide is None:
                db.add(
                    Guide(
                        slug=slug, title=title, summary=summary, body=body,
                        category_slug=cat_slug, image=image,
                        published_at=datetime.now(UTC),
                    )
                )
            else:
                guide.title = title
                guide.summary = summary
                guide.body = body
                guide.category_slug = cat_slug
                guide.image = image
                guide.is_active = True

        await db.commit()

    await engine.dispose()
    print("Seed complete.")
    print(f"Admin account: {settings.admin_email}")


if __name__ == "__main__":
    asyncio.run(seed())
