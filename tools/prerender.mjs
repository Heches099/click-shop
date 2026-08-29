#!/usr/bin/env node
/**
 * ClickShop — prerender snapshot generator.
 *
 * Fetches the product catalog (from the store API used by the app) and writes
 * fully-rendered, SEO-optimised static HTML snapshots of every public page
 * (home, categories, products) into `build/prerendered/`. The Cloudflare
 * crawler proxy (worker/crawler_proxy.js) serves these to search bots, and
 * `web/sitemap.xml` is regenerated automatically.
 *
 * Usage:
 *   node tools/prerender.mjs
 *
 * Config (env vars or defaults):
 *   STORE_API_BASE   e.g. http://localhost:8000/v1   (the FastAPI backend, matches AppConstants.baseUrl)
 *   SITE_URL         e.g. https://clickshop.example.com
 *   OUT_DIR          default ./build/prerendered
 *
 * The tool works offline: when the API is unreachable it falls back to a small
 * demo catalog so snapshots can still be generated in CI.
 */

import { mkdir, writeFile, rm } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const STORE_API_BASE = process.env.STORE_API_BASE || 'http://localhost:8000/v1';
const SITE_URL = (process.env.SITE_URL || 'https://clickshop.example.com').replace(/\/+$/, '');
const OUT_DIR = process.env.OUT_DIR || join(__dirname, '..', 'build', 'prerendered');
const SITEMAP_PATH = join(__dirname, '..', 'web', 'sitemap.xml');

const esc = (s) =>
  String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const sponsoredRel = 'rel="sponsored nofollow"';

// ---------------------------------------------------------------- fetching

async function getJson(path) {
  const res = await fetch(`${STORE_API_BASE}${path}`, { signal: AbortSignal.timeout(8000) });
  if (!res.ok) throw new Error(`GET ${path} -> ${res.status}`);
  const data = await res.json();
  if (Array.isArray(data)) return data;
  for (const key of ['data', 'products', 'items', 'results']) {
    if (Array.isArray(data?.[key])) return data[key];
  }
  return data;
}

const DEMO_PRODUCTS = [
  {
    id: 'air-max-2024',
    name: 'Air Max Runner 2024',
    description:
      'A lightweight, breathable running sneaker with responsive cushioning for everyday performance.',
    price: 129.99, originalPrice: 159.99,
    images: ['https://picsum.photos/seed/air1/600/600'],
    rating: 4.8, reviewCount: 214, category: 'sneakers', stock: 12, brand: 'Nike',
  },
  {
    id: 'classic-hoodie',
    name: 'Classic Cotton Hoodie',
    description:
      'A premium heavyweight cotton hoodie with a relaxed fit and a soft brushed interior.',
    price: 59.99, originalPrice: null,
    images: ['https://picsum.photos/seed/hoodie1/600/600'],
    rating: 4.6, reviewCount: 98, category: 'fashion', stock: 40, brand: 'H&M',
  },
  {
    id: 'noise-cancel-buds',
    name: 'Pro Wireless Earbuds',
    description:
      'Active noise cancelling wireless earbuds with 30h battery life and crystal clear calls.',
    price: 89.99, originalPrice: 119.99,
    images: ['https://picsum.photos/seed/buds1/600/600'],
    rating: 4.7, reviewCount: 156, category: 'electronics', stock: 25, brand: 'Sony',
  },
];

const DEMO_CATEGORIES = [
  { slug: 'sneakers', name: 'Sneakers', image: 'https://picsum.photos/seed/cat1/200/200', subcategories: [] },
  { slug: 'fashion', name: 'Fashion', image: 'https://picsum.photos/seed/cat2/200/200', subcategories: [] },
  { slug: 'electronics', name: 'Electronics', image: 'https://picsum.photos/seed/cat3/200/200', subcategories: [] },
];

// Collect a category's own slug plus every nested subcategory slug, so product
// pages of descendants are listed under the matching top-level category page.
function collectSlugs(category) {
  return [
    category.slug,
    ...(category.subcategories ?? []).flatMap((s) => collectSlugs(s)),
  ];
}

async function fetchAllProducts() {
  const products = [];
  const pageSize = 100;
  for (let page = 1; page <= 50; page++) {
    const data = await getJson(`/products?page=${page}&page_size=${pageSize}`);
    const items = Array.isArray(data) ? data : (data.items ?? []);
    products.push(...items);
    if (Array.isArray(data) || items.length < pageSize) break;
  }
  return products;
}

async function loadCatalog() {
  try {
    const [products, categories] = await Promise.all([
      fetchAllProducts().catch(() => getJson('/products/featured')),
      getJson('/categories'),
    ]);
    return { products, categories };
  } catch (error) {
    console.warn(`[prerender] Store API unreachable (${error.message}); using demo catalog.`);
    return { products: DEMO_PRODUCTS, categories: DEMO_CATEGORIES };
  }
}

// ---------------------------------------------------------------- builders

function productSchema(p, url) {
  const offer = p.originalPrice
    ? {
        '@type': 'AggregateOffer', lowPrice: p.price, highPrice: p.originalPrice,
        priceCurrency: 'USD', offerCount: 1,
        availability: p.stock > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
        itemCondition: 'https://schema.org/NewCondition',
      }
    : {
        '@type': 'Offer', price: p.price, priceCurrency: 'USD',
        availability: p.stock > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
        itemCondition: 'https://schema.org/NewCondition',
      };
  return {
    '@context': 'https://schema.org', '@type': 'Product', '@id': url, name: p.name,
    description: p.description, image: p.images ?? [],
    brand: { '@type': 'Brand', name: p.brand },
    category: p.category, sku: p.id, url,
    offers: offer,
    ...(p.reviewCount > 0
      ? { aggregateRating: { '@type': 'AggregateRating', ratingValue: p.rating, reviewCount: p.reviewCount, bestRating: 5, worstRating: 1 } }
      : {}),
  };
}

function siteGraph() {
  return {
    '@context': 'https://schema.org',
    '@graph': [
      { '@type': 'WebSite', '@id': `${SITE_URL}/#website`, url: `${SITE_URL}/`, name: 'ClickShop', inLanguage: 'en-US' },
      { '@type': 'Organization', '@id': `${SITE_URL}/#organization`, url: `${SITE_URL}/`, name: 'ClickShop', logo: `${SITE_URL}/icons/Icon-512.png` },
    ],
  };
}

function collectionSchema(products, url) {
  return {
    '@context': 'https://schema.org', '@type': 'CollectionPage', url,
    mainEntity: {
      '@type': 'ItemList',
      itemListElement: products.slice(0, 48).map((p, i) => ({
        '@type': 'ListItem', position: i + 1, name: p.name,
        url: `${SITE_URL}/products/${p.id}`, image: p.images?.[0] ?? '',
      })),
    },
  };
}

function jsonLd(...schemas) {
  return schemas.map((s) => `<script type="application/ld+json">${JSON.stringify(s)}</script>`).join('\n');
}

function head(title, description, canonical, schemas, navItems = []) {
  const nav = [
    ...navItems.map(
      (c) => `<a href="/category/${esc(c.slug)}" style="color:#fff;text-decoration:none;">${esc(c.name)}</a>`,
    ),
    `<a href="/category/all" style="color:#fff;text-decoration:none;">All products</a>`,
  ].join('\n      ');
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${esc(title)}</title>
  <meta name="description" content="${esc(description)}">
  <meta name="robots" content="index, follow, max-image-preview:large">
  <link rel="canonical" href="${SITE_URL}${canonical}">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="ClickShop">
  <meta property="og:title" content="${esc(title)}">
  <meta property="og:description" content="${esc(description)}">
  <meta property="og:url" content="${SITE_URL}${canonical}">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="icon" type="image/png" href="/favicon.png">
  ${jsonLd(...schemas)}
</head>
<body style="font-family:-apple-system,Segoe UI,Roboto,sans-serif;margin:0;background:#fff;color:#222;">
  <header style="background:#03704a;color:#fff;padding:20px 24px;">
    <a href="/" style="color:#fff;text-decoration:none;font-weight:800;font-size:20px;">ClickShop</a>
    <nav style="margin-top:10px;display:flex;gap:16px;flex-wrap:wrap;">
      ${nav}
    </nav>
  </header>
  <main style="max-width:1080px;margin:0 auto;padding:28px 24px;">
    <h1>${esc(title)}</h1>
    <p>${esc(description)}</p>`;
}

function footer() {
  return `
  </main>
  <footer style="max-width:1080px;margin:0 auto;padding:24px;border-top:1px solid #eee;font-size:13px;color:#666;">
    <p>
      <strong>Affiliate disclosure:</strong> As an affiliate, ClickShop may earn a commission from
      partner <a href="#" ${sponsoredRel}>retailer links</a> — you never pay extra.
      Ad placements are clearly marked and reserved in fixed-size boxes.
    </p>
    <p>&copy; ${new Date().getFullYear()} ClickShop. All rights reserved.</p>
  </footer>
</body>
</html>`;
}

function productCard(p) {
  const price = p.originalPrice
    ? `<s style="color:#999">$${Number(p.originalPrice).toFixed(2)}</s> <strong style="color:#03704a">$${Number(p.price).toFixed(2)}</strong>`
    : `<strong style="color:#03704a">$${Number(p.price).toFixed(2)}</strong>`;
  return `<article style="border:1px solid #eee;border-radius:14px;overflow:hidden;">
    <a href="/products/${esc(p.id)}" style="text-decoration:none;color:inherit;">
      ${p.images?.[0] ? `<img src="${esc(p.images[0])}" alt="${esc(p.name)}" width="300" height="300" style="width:100%;display:block;" loading="lazy">` : ''}
      <div style="padding:14px;">
        <div style="font-size:12px;color:#888;">${esc(p.brand)}</div>
        <h2 style="font-size:15px;margin:6px 0;">${esc(p.name)}</h2>
        <div>${price}</div>
        <div style="font-size:12px;color:#888;margin-top:4px;">&#9733; ${p.rating} (${p.reviewCount} reviews)</div>
      </div>
    </a>
  </article>`;
}

// ---------------------------------------------------------------- writing

async function writePage(relPath, html) {
  const full = join(OUT_DIR, relPath);
  await mkdir(dirname(full), { recursive: true });
  await writeFile(full, html, 'utf8');
  return relPath;
}

async function main() {
  const { products, categories } = await loadCatalog();
  const written = [];

  console.log(`[prerender] ${products.length} products, ${categories.length} categories.`);

  // Clean previous run (never delete the directory itself).
  await rm(OUT_DIR, { recursive: true, force: true });

  // Home + collection pages
  const homeProducts = products.slice(0, 12);
  written.push(
    await writePage(
      'index.html',
      head(
        'ClickShop — Premium Fashion, Sneakers & Electronics',
        'ClickShop is your premium online store for fashion, sneakers and electronics at the best prices with fast delivery and real reviews.',
        '/',
        [siteGraph(), collectionSchema(homeProducts, `${SITE_URL}/`)],
        categories,
      ) + `<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:18px;">
        ${homeProducts.map(productCard).join('\n')}
      </div>` + footer(),
    ),
  );

  // One page per category (+ an "all" page listing everything). Products that
  // live in a subcategory appear under their parent's page.
  const categoryPages = [
    { slug: 'all', name: 'All Products', list: products },
    ...categories.map((c) => {
      const slugs = collectSlugs(c).map((s) => String(s).toLowerCase());
      return {
        slug: c.slug,
        name: c.name,
        list: products.filter((p) => slugs.includes(String(p.category || '').toLowerCase())),
      };
    }),
  ];
  for (const page of categoryPages) {
    const canonical = `/category/${page.slug}`;
    const title = `${page.name} — ClickShop`;
    const desc = `Shop the best ${page.name} at ClickShop. ${page.list.length} hand-picked items with fast delivery and great prices.`;
    written.push(
      await writePage(
        `category/${page.slug}/index.html`,
        head(title, desc, canonical, [siteGraph(), collectionSchema(page.list, `${SITE_URL}${canonical}`)], categories) +
          `<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:18px;">
            ${page.list.length ? page.list.map(productCard).join('\n') : '<p>No products in this category yet.</p>'}
          </div>` + footer(),
      ),
    );
  }

  // One page per product (JSON-LD Product schema + aggregate rating).
  for (const p of products) {
    const canonical = `/products/${p.id}`;
    const title = `${p.name} — ${p.brand} | ClickShop`;
    const desc = `Buy ${p.name} for $${Number(p.price).toFixed(2)}. ${(p.description || '').slice(0, 140)}`;
    written.push(
      await writePage(
        `products/${p.id}/index.html`,
        head(title, desc, canonical, [siteGraph(), productSchema(p, `${SITE_URL}${canonical}`)], categories) +
          `<div>
            <img src="${esc(p.images?.[0] ?? '')}" alt="${esc(p.name)}" style="max-width:420px;width:100%;border-radius:14px;">
            <p>${esc(p.description)}</p>
            <p>Price: $${Number(p.price).toFixed(2)} · ${p.stock > 0 ? 'In stock' : 'Out of stock'}</p>
            <p>Rating: &#9733; ${p.rating} (${p.reviewCount} reviews)</p>
            <h2>More from ClickShop</h2>
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;">
              ${products.filter((x) => x.id !== p.id).slice(0, 4).map(productCard).join('\n')}
            </div>
          </div>` + footer(),
      ),
    );
  }

  // Regenerate sitemap.xml
  const urls = [
    '/',
    ...categoryPages.map((c) => `/category/${c.slug}`),
    ...products.map((p) => `/products/${p.id}`),
  ];
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls
  .map(
    (u) => `  <url>
    <loc>${SITE_URL}${u}</loc>
    <changefreq>${u === '/' ? 'daily' : 'weekly'}</changefreq>
    <priority>${u === '/' ? '1.0' : u.startsWith('/products') ? '0.6' : '0.8'}</priority>
  </url>`,
  )
  .join('\n')}
</urlset>
`;
  await writeFile(SITEMAP_PATH, sitemap, 'utf8');

  console.log(`[prerender] wrote ${written.length} snapshots to ${OUT_DIR}`);
  console.log(`[prerender] regenerated ${SITEMAP_PATH} (${urls.length} urls)`);
}

main().catch((error) => {
  console.error('[prerender] failed:', error);
  process.exit(1);
});
