"""Throwaway smoke test for the ClickShop backend (SQLite, no Postgres needed)."""
import asyncio
import os

os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///./smoke.db"

from fastapi.testclient import TestClient  # noqa: E402

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
r = client.post("/v1/auth/login", json={"email": "admin@clickshop.com", "password": "ChangeMe123!"})
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

# --- forbidden checks ---
r = client.get("/v1/admin/stats", headers=h); check("non-admin blocked", r.status_code == 403)
r = client.get("/v1/orders/does-not-exist", headers=h); check("404 on missing order", r.status_code == 404)

print(f"\n{('ALL PASSED ' + str(PASS)) if not FAIL else 'FAILURES: ' + ', '.join(FAIL)}")
raise SystemExit(1 if FAIL else 0)
