"""Amazon affiliate integration tests.

Security-focused tests covering:
* Affiliate URL generation + ASIN validation
* Tracking ID immutability (cannot be overridden by user input)
* Provider fallback when API is disabled / credentials missing
* Endpoint response shape
* Invalid ASIN / long & malicious queries
* Arbitrary URL / SSRF protection
* No secrets in API responses or health endpoint

Run with: python test_amazon_affiliate.py
Uses SQLite so no Postgres is required.
"""
import os

os.environ["DATABASE_URL"] = "sqlite+aiosqlite:///./amazon_test.db"
os.environ["AMAZON_API_ENABLED"] = "false"

from urllib.parse import parse_qs, urlsplit  # noqa: E402

from fastapi.testclient import TestClient  # noqa: E402

from app.core.config import settings  # noqa: E402
from app.main import app  # noqa: E402
from app.services.amazon_affiliate import (  # noqa: E402
    build_affiliate_product_url,
    build_affiliate_search_url,
    is_valid_asin,
    normalize_asin,
)
from app.services.amazon_provider import (  # noqa: E402
    AffiliateLinkProvider,
    AmazonCreatorsApiProvider,
    get_amazon_provider,
)

PASS, FAIL = 0, []


def check(name, cond, extra=""):
    global PASS
    if cond:
        PASS += 1
        print(f"  ok  {name}")
    else:
        FAIL.append(name)
        print(f"FAIL  {name}  {extra}")


client = TestClient(app)

# --- 1. ASIN validation ---
check("asin valid uppercase", is_valid_asin("B0ABCDEFGH"))
check("asin valid lowercase normalized", is_valid_asin("b0abcdefgh"))
check("asin valid numeric", is_valid_asin("0123456789"))
check("asin reject short", not is_valid_asin("B0ABC"))
check("asin reject long", not is_valid_asin("B0ABCDEFGHX"))
check("asin reject special chars", not is_valid_asin("B0ABC!EFGH"))
check("asin reject empty", not is_valid_asin(""))
check("asin reject whitespace-only", not is_valid_asin("   "))
try:
    normalize_asin("Bad$Asin!!")
    check("normalize invalid raises", False)
except ValueError:
    check("normalize invalid raises", True)
check("normalize uppercases", normalize_asin("b0abcdefgh") == "B0ABCDEFGH")

# --- 2. Affiliate URL generation ---
url = build_affiliate_product_url("B0ABCDEFGH")
check("product url shape",
      urlsplit(url).netloc == "www.amazon.com"
      and urlsplit(url).path == "/dp/B0ABCDEFGH")
pp = parse_qs(urlsplit(url).query)
check("product url tag", pp.get("tag") == ["clickshop03b-20"], url)

surl = build_affiliate_search_url("gaming")
sp = parse_qs(urlsplit(surl).query)
check("search url tag", sp.get("tag") == ["clickshop03b-20"] and sp.get("k") == ["gaming"], surl)
check("search url uses configured marketplace",
      urlsplit(surl).netloc == settings.amazon_marketplace)

# --- 3. Tracking ID cannot be overridden ---
# A malicious keyword tries to inject another tag via query params.
evil = build_affiliate_search_url("gaming&tag=evil-tag")
ep = parse_qs(urlsplit(evil).query)
check("keyword injection encoded", "gaming&tag=evil-tag" in ep.get("k", [""]), evil)
check("tag not overridden", ep.get("tag") == ["clickshop03b-20"], evil)

# --- 4. Provider mode / fallback ---
prov = get_amazon_provider()
check("disabled -> AffiliateLinkProvider", isinstance(prov, AffiliateLinkProvider))

# Simulate API enabled but credentials missing -> safe fallback, no crash.
settings.amazon_api_enabled = True
settings.amazon_access_key = ""
settings.amazon_secret_key = ""
pf = get_amazon_provider()
check("enabled + missing creds -> fallback link provider", isinstance(pf, AffiliateLinkProvider))
# Simulate API enabled AND credentials present -> future API provider selected.
settings.amazon_access_key = "DUMMY"
settings.amazon_secret_key = "DUMMY"
settings.amazon_partner_tag = "clickshop03b-20"
pr = get_amazon_provider()
check("enabled + creds -> Creators API provider", isinstance(pr, AmazonCreatorsApiProvider))
# Reset back to disabled.
settings.amazon_api_enabled = False
settings.amazon_access_key = ""
settings.amazon_secret_key = ""

# --- 5. Categories endpoint ---
r = client.get("/v1/amazon/categories")
cats = r.json()
check("categories 200", r.status_code == 200)
check("categories count", isinstance(cats, list) and len(cats) == 8, str(len(cats)))
if cats:
    first = cats[0]
    need = ["id", "name", "description", "keyword", "imageKey", "affiliateUrl"]
    check("category shape", all(k in first for k in need), f"{list(first.keys())}")
    check("category affiliateUrl has tag", "tag=clickshop03b-20" in first["affiliateUrl"], first["affiliateUrl"])
    check("category affiliateUrl is amazon.com", "amazon.com" in first["affiliateUrl"], first["affiliateUrl"])

# --- 6. Products endpoint (API disabled -> empty) ---
r = client.get("/v1/amazon/products?q=gaming")
check("products 200", r.status_code == 200)
check("products empty when disabled", r.json() == [])

# --- 7. Invalid ASIN -> 400 ---
r = client.get("/v1/amazon/products/BADASIN")
check("invalid asin 400", r.status_code == 400)
r = client.get("/v1/amazon/products/not_an_asin_12345")
check("malformed asin 400", r.status_code == 400)
check("bad asin does not return internals", "Traceback" not in r.text)

# --- 8. Long / malicious query handled safely ---
r = client.get("/v1/amazon/products?q=" + "a" * 500)
check("long query rejected (400/422)", r.status_code in (400, 422), r.text[:80])
r = client.get("/v1/amazon/products?q=" + "a" * 500, allow_redirects=False)
check("long query safe error body", "secret" not in r.text.lower())
r = client.get("/v1/amazon/products?q=..%2F..%2Fetc%2Fpasswd")
check("path-traversal query safe 200/[]", r.status_code in (200, 400), r.text[:80])

# --- 9. Arbitrary URL / SSRF protection ---
# A malicious "url" parameter must be ignored (FastAPI allows unknown params
# but our endpoint never reads/fetches it).
r = client.get("/v1/amazon/products?q=gaming&url=https://evil.example.com/internal")
check("arbitrary url param ignored", r.status_code == 200 and r.json() == [], r.text[:80])
body = r.text
check("url not echoed", "evil.example.com" not in body)

# --- 10. No secrets in responses ---
for path in ["/v1/amazon/categories", "/v1/amazon/products?q=gaming", "/v1/health", "/v1/health/db"]:
    r = client.get(path)
    low = r.text.lower()
    vuln_values = [v for v in (settings.amazon_secret_key, settings.amazon_access_key) if v]
    check(f"no secrets in {path}",
          all(v not in r.text for v in vuln_values)
          and "aws_secret" not in low
          and "jwt_secret" not in low
          and "-----begin" not in low)
    secrets_only_safe_keys = {"status", "amazon_api_enabled"}
    if path == "/v1/health":
        check("health only safe keys", set(r.json().keys()) <= secrets_only_safe_keys, f"{list(r.json().keys())}")
        check("health safe values", r.json().get("amazon_api_enabled") is False and r.json().get("status") == "ok")

# --- 11. Provider never returns live data in link mode ---
prov = get_amazon_provider()
products = None
import asyncio


async def _search():
    return await prov.search_products("gaming", item_count=20)


products = asyncio.run(_search())
check("link provider returns no products", products == [])


REMOVE_DB = True


def cleanup():
    try:
        os.remove("./amazon_test.db")
        os.remove("./amazon_test.db-shm")
        os.remove("./amazon_test.db-wal")
    except OSError:
        pass


if not FAIL:
    print(f"\nALL PASSED {PASS}")
    cleanup()
    raise SystemExit(0)

print(f"\nFAILURES: {', '.join(FAIL)}")
cleanup()
raise SystemExit(1)