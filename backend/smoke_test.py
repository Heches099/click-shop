"""Throwaway smoke test for the ClickShop backend (SQLite, no Postgres needed)."""
import asyncio
import os

os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///./smoke.db"

from fastapi.testclient import TestClient  # noqa: E402

from app.core.config import settings  # noqa: E402
from app.db.seed import seed  # noqa: E402
from app.main import app  # noqa: E402

PASS, FAIL = 0, []


def check(name, cond, extra=""):
    global PASS
    if cond:
        PASS += 1
        print(f"  ok  {name}")
    else:
        FAIL.append(name)
        print(f"FAIL  {name}  {extra}")


async def _seed():
    await seed()


asyncio.run(_seed())

client = TestClient(app)

# --- public catalog ---
r = client.get("/v1/health"); check("health", r.status_code == 200)
r = client.get("/v1/categories"); cats = r.json(); check("categories list", r.status_code == 200 and len(cats) >= 4, r.text[:120])
for ep in ["featured", "best-sellers", "new-arrivals", "flash-sales", "recommended"]:
    r = client.get(f"/v1/products/{ep}")
    items = r.json()
    check(f"products/{ep}", r.status_code == 200 and isinstance(items, list) and len(items) > 0, r.text[:120])
    if items:
        p = items[0]
        need = ["id", "name", "description", "price", "originalPrice", "images", "rating", "reviewCount", "category", "stock", "brand"]
        check(f"products/{ep} shape", all(k in p for k in need), f"{p.keys()}")
pid = client.get("/v1/products/featured").json()[0]["id"]
r = client.get(f"/v1/products/{pid}"); check("product by id", r.status_code == 200 and r.json()["id"] == pid)
slug = client.get("/v1/products/featured").json()[0]["slug"]
r = client.get(f"/v1/products/by-slug/{slug}")
check("product by slug", r.status_code == 200 and r.json()["slug"] == slug, r.text[:120])
r = client.get("/v1/products/by-slug/not-a-real-slug"); check("product by-slug 404", r.status_code == 404)
featured_amazon = client.get("/v1/amazon/products?limit=1").json()
az_slug = (featured_amazon[0]["slug"] if featured_amazon else "")
r = client.get(f"/v1/amazon/products/by-slug/{az_slug}")
check("amazon product by slug", r.status_code == 200 and r.json()["slug"] == az_slug, r.text[:120])
r = client.get("/v1/amazon/products/by-slug/zzz-not-real"); check("amazon by-slug 404", r.status_code == 404)
r = client.get("/v1/products?category=sneakers"); check("products by category", r.status_code == 200 and r.json()["total"] > 0)
r = client.get("/v1/products/search?q=hoodie"); check("search", r.status_code == 200 and len(r.json()) >= 1, r.text[:120])

# --- auth ---
r = client.post("/v1/auth/register", json={"email": "user@test.com", "password": "password123", "name": "Test User"})
check("register", r.status_code == 201 and "access_token" in r.json(), r.text[:200])
token = r.json()["access_token"]
h = {"Authorization": f"Bearer {token}"}
r = client.post("/v1/auth/login", json={"email": "user@test.com", "password": "password123"})
check("login", r.status_code == 200)
r = client.get("/v1/auth/me", headers=h); check("me", r.status_code == 200 and r.json()["email"] == "user@test.com")

# --- cart ---
r = client.post("/v1/cart/items", headers=h, json={"product_id": pid, "quantity": 2})
check("cart add", r.status_code == 201 and r.json()["count"] == 2, r.text[:200])
cart_id = r.json()["items"][0]["id"]
r = client.put(f"/v1/cart/items/{cart_id}", headers=h, json={"quantity": 3})
check("cart update", r.status_code == 200 and r.json()["count"] == 3)
r = client.get("/v1/cart", headers=h); check("cart get", r.status_code == 200 and len(r.json()["items"]) == 1)

# --- orders + cancel ---
order_payload = {
    "items": [{"product_id": pid, "quantity": 2, "selected_color": "Black"}],
    "shipping_address": {"name": "T", "phone": "555", "street": "1 Main", "city": "NY", "state": "NY", "zip_code": "10001", "country": "US", "is_default": True},
    "payment_method": "card",
}
r = client.post("/v1/orders", headers=h, json=order_payload)
check("order create", r.status_code == 201, r.text[:300])
order = r.json()
need = ["id", "userId", "items", "subtotal", "shippingFee", "tax", "total", "shippingAddress", "status", "createdAt"]
check("order shape", all(k in order for k in need), f"{order.keys()}")
r = client.get("/v1/orders", headers=h); check("my orders", r.status_code == 200 and len(r.json()) == 1)
r = client.get(f"/v1/orders/{order['id']}", headers=h); check("order by id", r.status_code == 200)
r = client.post("/v1/payments/create-intent", headers=h, json={"order_id": order["id"]})
check("payment intent (mock)", r.status_code == 200 and "client_secret" in r.json(), r.text[:200])
r = client.post(f"/v1/orders/{order['id']}/cancel", headers=h); check("order cancel", r.status_code == 200 and r.json()["status"] == "cancelled")
r = client.post("/v1/payments/create-intent", headers=h, json={"order_id": order["id"]})
check("payment rejected for cancelled", r.status_code == 400)
r = client.get(f"/v1/addresses", headers=h); check("address saved", r.status_code == 200 and len(r.json()) == 1)

# --- payments ---

# --- reviews ---
r = client.post(f"/v1/products/{pid}/reviews", headers=h, json={"rating": 5, "title": "Great", "comment": "Love it"})
check("review create", r.status_code == 201, r.text[:200])
r = client.get(f"/v1/products/{pid}/reviews"); check("review list", r.status_code == 200 and len(r.json()) == 1)

# --- affiliate ---
r = client.post("/v1/affiliate/register", headers=h, json={"name": "T", "email": "user@test.com"})
check("affiliate register", r.status_code == 201 and r.json()["promoCode"].startswith("CS-"), r.text[:200])
code = r.json()["promoCode"]
r = client.post("/v1/affiliate/clicks", json={"code": code, "source": "instagram"})
check("affiliate click", r.status_code == 201, r.text[:200])
r = client.get("/v1/affiliate/me", headers=h); check("affiliate me", r.status_code == 200 and r.json()["totalClicks"] == 1)
r = client.get("/v1/affiliate/stats", headers=h); check("affiliate stats", r.status_code == 200 and r.json()["clicks"] == 1)
r = client.get("/v1/affiliate/commissions", headers=h); check("affiliate commissions", r.status_code == 200)

# --- admin ---
r = client.post("/v1/auth/login", json={"email": settings.admin_email, "password": settings.admin_password})
check("admin login", r.status_code == 200, r.text[:200])
ah = {"Authorization": f"Bearer {r.json()['access_token']}"}
r = client.get("/v1/admin/stats", headers=ah); check("admin stats", r.status_code == 200 and "revenue" in r.json(), r.text[:200])
r = client.get("/v1/admin/orders", headers=ah); check("admin orders", r.status_code == 200 and len(r.json()) >= 1)
r = client.post("/v1/admin/products", headers=ah, json={"name": "Test Product", "description": "d", "price": 10.0, "category_slug": "home", "brand": "TestBrand", "stock": 5})
check("admin create product", r.status_code == 201, r.text[:300])
r = client.put(f"/v1/admin/orders/{order['id']}/status", headers=ah, json={"status": "shipped"})
check("admin order status", r.status_code == 200 and r.json()["status"] == "shipped")
r = client.put(f"/v1/admin/orders/{order['id']}/tracking", headers=ah, json={"tracking_number": "TRK123"})
check("admin tracking", r.status_code == 200 and r.json()["trackingNumber"] == "TRK123")

# --- for forbidden / missing checks ---

# --- discovery: search suggest/popular, filters, related ---
r = client.get("/v1/search/popular")
check("search popular", r.status_code == 200 and isinstance(r.json(), list))
r = client.get("/v1/search/suggest?q=hood")
data = r.json()
check("search suggest", r.status_code == 200 and {"products", "categories", "popular"} <= set(data), r.text[:200])
r = client.get("/v1/products?q=hoodie")
check("catalog q search", r.status_code == 200 and r.json()["total"] >= 1)
r = client.get("/v1/products?min_price=0&max_price=60")
check("price filter", r.status_code == 200 and all(p["price"] <= 60 for p in r.json()["items"]), r.text[:120])
brand = client.get("/v1/products?category=sneakers").json()["items"][0]["brand"]
r = client.get(f"/v1/products?brands={brand}")
check("brand filter", r.status_code == 200 and r.json()["total"] >= 1)
rel = client.get(f"/v1/products/{pid}/related")
check("related", rel.status_code == 200 and {"similar", "cheaper", "higherEnd", "complementary"} <= set(rel.json()), rel.text[:200])
r = client.get("/v1/products/not-a-real-id-0000/related")
check("related 404", r.status_code == 404)

# --- content: collections & guides ---
r = client.get("/v1/content/collections"); cols = r.json()
check("collections list", r.status_code == 200 and len(cols) >= 4 and "productCount" in cols[0], r.text[:200])
r = client.get(f"/v1/content/collections/{cols[0]['slug']}")
check("collection detail", r.status_code == 200 and r.json()["productCount"] == len(r.json()["products"]), r.text[:200])
r = client.get("/v1/content/collections/zzz-not-real"); check("collection 404", r.status_code == 404)
r = client.get("/v1/content/guides"); guides = r.json()
check("guides list", r.status_code == 200 and len(guides) >= 4 and "summary" in guides[0], r.text[:200])
r = client.get(f"/v1/content/guides/{guides[0]['slug']}")
check("guide detail", r.status_code == 200 and len(r.json()["body"]) > 100, r.text[:200])
r = client.get("/v1/content/guides/zzz-not-real"); check("guide 404", r.status_code == 404)

# --- analytics events (anonymous + validation) ---
r = client.post("/v1/analytics/events", json={"event_type": "search", "client_id": "test-client-0001", "payload": {"q": "hoodie"}})
check("analytics search event", r.status_code == 202, r.text[:200])
r = client.post("/v1/analytics/events", json={"event_type": "search", "client_id": "test-client-0001", "payload": {"q": "hoodie", "nested": {"x": 1}}})
check("analytics sanitises nested payload", r.status_code == 202, r.text[:200])
r = client.post("/v1/analytics/events", json={"event_type": "view_product", "client_id": "test-client-0001", "product_id": pid})
check("analytics view event", r.status_code == 202, r.text[:200])
r = client.post("/v1/analytics/events", json={"event_type": "totally-fake-event", "payload": {}})
check("analytics unknown type rejected", r.status_code == 422)
r = client.get("/v1/search/popular")
check("popular now has real query", r.status_code == 200 and "hoodie" in r.json(), r.text[:200])

# --- contact (works without any email provider) ---
r = client.post("/v1/contact", json={"name": "Pat", "email": "pat@example.com", "subject": "Order question", "message": "How long does shipping usually take for orders?"})
check("contact submit", r.status_code == 201 and r.json()["isRead"] is False, r.text[:200])
r = client.post("/v1/contact", json={"name": "Pat", "email": "pat@example.com", "message": "short"})
check("contact rejects short message", r.status_code == 422)

# --- admin: ops surface (analytics, inbox, audit, content CRUD) ---
r = client.get("/v1/admin/analytics/summary", headers=ah)
check("admin analytics summary", r.status_code == 200 and "funnel" in r.json() and "topSearches" in r.json(), r.text[:300])
r = client.get("/v1/admin/contact-messages", headers=ah)
inbox = r.json()
check("admin contact inbox", r.status_code == 200 and any(m["email"] == "pat@example.com" for m in inbox), r.text[:200])
mid = inbox[0]["id"]
r = client.patch(f"/v1/admin/contact-messages/{mid}/read", headers=ah)
check("mark contact read", r.status_code == 200 and r.json()["isRead"] is True, r.text[:200])
r = client.get("/v1/admin/audit-log", headers=ah)
check("admin audit log", r.status_code == 200 and len(r.json()) >= 1, r.text[:300])
r = client.get("/v1/admin/collections", headers=ah)
check("admin collections list", r.status_code == 200 and len(r.json()) >= 4, r.text[:200])
r = client.post("/v1/admin/collections", headers=ah, json={"slug": "test-col", "name": "Test Collection", "description": "d", "product_ids": [pid]})
check("admin create collection", r.status_code == 201 and len(r.json()["products"]) >= 1, r.text[:200])
col_id = r.json()["id"]
r = client.delete(f"/v1/admin/collections/{col_id}", headers=ah)
check("admin delete collection", r.status_code == 204)
r = client.post("/v1/admin/guides", headers=ah, json={"slug": "test-guide", "title": "Test Guide", "summary": "s", "body": "body " * 30, "category_slug": "electronics"})
check("admin create guide", r.status_code == 201, r.text[:200])
guide_id = r.json()["id"]
r = client.delete(f"/v1/admin/guides/{guide_id}", headers=ah)
check("admin delete guide", r.status_code == 204)
r = client.post("/v1/admin/products", headers=ah, json={"name": "Edit-me Product", "description": "d", "price": 5.0, "category_slug": "home", "brand": "B", "stock": 3})
check("admin create edit product", r.status_code == 201, r.text[:200])
edit_pid = r.json()["id"]
r = client.put(f"/v1/admin/products/{edit_pid}", headers=ah, json={"price": 9.5})
check("admin update product", r.status_code == 200 and r.json()["price"] == 9.5, r.text[:200])
r = client.delete(f"/v1/admin/products/{edit_pid}", headers=ah)
check("admin soft-delete product", r.status_code == 204)
r = client.post("/v1/admin/categories?name=TestCat", headers=ah)
check("admin create category", r.status_code == 201 and r.json()["slug"] == "testcat", r.text[:200])

# --- forbidden checks ---
r = client.get("/v1/admin/stats", headers=h); check("non-admin blocked", r.status_code == 403)
r = client.get("/v1/admin/analytics/summary", headers=h); check("non-admin analytics blocked", r.status_code == 403)
r = client.get("/v1/admin/contact-messages", headers=h); check("non-admin inbox blocked", r.status_code == 403)
r = client.get("/v1/orders/does-not-exist", headers=h); check("404 on missing order", r.status_code == 404)

print(f"\n{('ALL PASSED ' + str(PASS)) if not FAIL else 'FAILURES: ' + ', '.join(FAIL)}")
raise SystemExit(1 if FAIL else 0)
