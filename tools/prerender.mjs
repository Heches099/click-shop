#!/usr/bin/env node
/**
 * ClickShop — static SEO prerenderer (v2).
 *
 * Generates a fully crawlable static snapshot of the store directly into the
 * Firebase Hosting deploy folder (`build/web`):
 *
 *   /                       -> SPA shell (index.html) with real catalog links
 *                               injected into its <noscript> + schema markers
 *   /product/{slug}.html    -> full product pages (Product + Breadcrumb JSON-LD)
 *   /category/{slug}.html   -> category pages (CollectionPage JSON-LD)
 *   /guides/{slug}.html     -> editorial buying guides (curated content)
 *   /compare/{slug}.html    -> data-driven product comparisons
 *   /sitemap.xml            -> regenerated with every crawlable URL
 *   /robots.txt             -> copied from web/robots.txt
 *   /404.html               -> soft-404 page (noindex)
 *
 * Every static page embeds the Flutter bootstrap (`flutter_bootstrap.js`) so
 * humans get the full app after the JS engine boots, while JS-less crawlers
 * get the complete HTML, meta tags, JSON-LD and internal links.
 *
 * Because Firebase Hosting serves static HTML via `cleanUrls`, the extensionless
 * URL /product/{slug} maps to product/{slug}.html with no Cloud Functions and
 * no SPA-render proxy — so crawling works with the free Spark plan.
 *
 * Usage:
 *   flutter build web
 *   node tools/prerender.mjs
 *
 * Config (env vars):
 *   STORE_API_BASE   defaults to the production backend  https://click-shop-669d.onrender.com/v1
 *   SITE_URL         defaults to the production domain  https://click-shop-d62ad.web.app
 *   OUT_DIR          defaults to ./build/web (the hosting root)
 */

import { mkdir, writeFile, copyFile, rm, readFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const STORE_API_BASE = (
  process.env.STORE_API_BASE || 'https://click-shop-669d.onrender.com/v1'
).replace(/\/+$/, '');
const SITE_URL = (process.env.SITE_URL || 'https://click-shop-d62ad.web.app').replace(/\/+$/, '');
const OUT_DIR = process.env.OUT_DIR || join(__dirname, '..', 'build', 'web');
const WEB_DIR = join(__dirname, '..', 'web');
const SEO_DIR = join(__dirname, '..', 'tools', 'seo-content');
const HOST_INDEX = join(OUT_DIR, 'index.html');
const SITEMAP_REPO = join(WEB_DIR, 'sitemap.xml');

const esc = (s) =>
  String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const json = (o) => JSON.stringify(o);
const xmlns = 'http://www.sitemaps.org/schemas/sitemap/0.9';
const sponsoredRel = 'rel="sponsored nofollow"';

// ---------------------------------------------------------------- fetching

async function getJson(path, { silent = false } = {}) {
  // Render's free tier cold-starts after idle, so allow generous time + a retry.
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const res = await fetch(`${STORE_API_BASE}${path}`, { signal: AbortSignal.timeout(40000) });
      if (!res.ok) {
        if (silent) return null;
        throw new Error(`GET ${path} -> ${res.status}`);
      }
      return await res.json();
    } catch (error) {
      if (attempt === 0) continue;
      if (silent) return null;
      throw error;
    }
  }
  return null;
}

async function fetchDbProducts() {
  const out = [];
  let page = 1;
  for (;;) {
    const data = await getJson(`/products?page=${page}&page_size=100`);
    const items = Array.isArray(data) ? data : (data.items ?? []);
    out.push(...items.map(normalizeDb));
    if (!data?.items || data.items.length < 100) break;
    page += 1;
    if (page > 100) break;
  }
  return out;
}

const normalizeDb = (p) => ({
  kind: 'db',
  slug: p.slug || p.id,
  id: p.id,
  name: p.name,
  brand: p.brand || '',
  description: p.description || '',
  price: Number(p.price) || 0,
  originalPrice: p.originalPrice ? Number(p.originalPrice) : null,
  images: Array.isArray(p.images) ? p.images : [],
  rating: Number(p.rating) || 0,
  reviewCount: Number(p.reviewCount) || 0,
  category: p.category || '',
  stock: Number(p.stock) || 0,
  asin: p.asin || '',
  amazonUrl: p.amazonUrl || '',
  url: `/product/${p.slug || p.id}`,
});

const normalizeAmazon = (p) => ({
  kind: 'amazon',
  slug: p.slug || '',
  id: p.id || `amazon-${p.asin}`,
  asin: p.asin || '',
  name: p.name,
  brand: p.brand || 'Amazon',
  description: p.description || p.name || '',
  price: Number(p.price) || 0, // curated items intentionally carry 0.0
  originalPrice: p.originalPrice ? Number(p.originalPrice) : null,
  images: Array.isArray(p.images) ? p.images : [],
  rating: Number(p.rating) || 0,
  reviewCount: Number(p.reviewCount) || 0,
  category: p.category || '',
  stock: 1,
  amazonUrl: p.amazonUrl || '',
  url: `/product/${p.slug}`,
});

async function loadCatalog() {
  const [dbProducts, dbCategories, amazon, amazonCategories] = await Promise.all([
    fetchDbProducts(),
    getJson('/categories').catch(() => []),
    getJson('/amazon/products?limit=50'),
    getJson('/amazon/categories').catch(() => []),
  ]);

  const products = [];
  const bySlug = new Map();
  const byAsin = new Map();
  const add = (p) => {
    if (!p || !p.slug) return;
    if (p.asin) byAsin.set(p.asin, p);
    if (bySlug.has(p.slug)) return;
    bySlug.set(p.slug, p);
    products.push(p);
  };
  for (const p of dbProducts) add(p);
  for (const p of (Array.isArray(amazon) ? amazon : []).map(normalizeAmazon)) add(p);

  const categoryMap = new Map();
  for (const c of Array.isArray(dbCategories) ? dbCategories : []) {
    categoryMap.set(c.slug, { slug: c.slug, name: c.name || c.slug, kind: 'db' });
  }
  for (const c of Array.isArray(amazonCategories) ? amazonCategories : []) {
    if (!categoryMap.has(c.id)) {
      categoryMap.set(c.id, { slug: c.id, name: c.name || c.id, kind: 'amazon' });
    }
  }

  return { products, bySlug, byAsin, categoryMap };
}

// ---------------------------------------------------------------- schemas

const siteGraph = () => ({
  '@context': 'https://schema.org',
  '@graph': [
    { '@type': 'WebSite', '@id': `${SITE_URL}/#website`, url: `${SITE_URL}/`, name: 'ClickShop', inLanguage: 'en-US' },
    { '@type': 'Organization', '@id': `${SITE_URL}/#organization`, url: `${SITE_URL}/`, name: 'ClickShop', logo: `${SITE_URL}/icons/Icon-512.png` },
  ],
});

const breadcrumb = (crumbs) => ({
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: crumbs.map((c, i) => ({
    '@type': 'ListItem',
    position: i + 1,
    name: c.name,
    item: `${SITE_URL}${c.path}`,
  })),
});

function productSchema(p, canonical) {
  const url = `${SITE_URL}${canonical}`;
  const schema = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    '@id': url,
    name: p.name,
    description: p.description,
    image: p.images,
    brand: { '@type': 'Brand', name: p.brand },
    category: p.category,
    sku: p.asin || p.id,
    url,
  };
  // DB products carry real prices + ratings. Curated Amazon products
  // intentionally omit prices, so we never emit a fake $0 offer.
  if (p.price > 0) {
    schema.offers = p.originalPrice
      ? {
          '@type': 'AggregateOffer',
          lowPrice: p.price,
          highPrice: p.originalPrice,
          priceCurrency: 'USD',
          offerCount: 1,
          availability: p.stock > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
          itemCondition: 'https://schema.org/NewCondition',
        }
      : {
          '@type': 'Offer',
          price: p.price,
          priceCurrency: 'USD',
          availability: p.stock > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
          itemCondition: 'https://schema.org/NewCondition',
        };
  }
  if (p.reviewCount > 0) {
    schema.aggregateRating = {
      '@type': 'AggregateRating',
      ratingValue: p.rating,
      reviewCount: p.reviewCount,
      bestRating: 5,
      worstRating: 1,
    };
  }
  return schema;
}

function collectionSchema(products, canonical) {
  return {
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    url: `${SITE_URL}${canonical}`,
    mainEntity: {
      '@type': 'ItemList',
      itemListElement: products.slice(0, 48).map((p, i) => ({
        '@type': 'ListItem',
        position: i + 1,
        name: p.name,
        url: `${SITE_URL}${p.url}`,
        image: p.images?.[0] ?? '',
      })),
    },
  };
}

function articleSchema(page, canonical) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: page.title,
    description: page.description,
    url: `${SITE_URL}${canonical}`,
    inLanguage: 'en-US',
    publisher: { '@type': 'Organization', name: 'ClickShop', url: `${SITE_URL}/` },
  };
}

const jsonLd = (...schemas) =>
  schemas.filter(Boolean).map((s) => `<script type="application/ld+json">${json(s)}</script>`).join('\n  ');

// ---------------------------------------------------------------- page shell

const BRAND_COLOR = '#03704a';

const bootstrapSnippet = `  <div id="flt-loading" style="position:fixed;inset:0;display:flex;align-items:center;justify-content:center;background:#fff;z-index:9999;font-family:-apple-system,Segoe UI,Roboto,sans-serif;">
    <p style="color:#555;font-size:14px;">Loading ClickShop…</p>
  </div>
  <script>
    window.addEventListener('flutter-first-frame', function () {
      var el = document.getElementById('flt-loading');
      if (el) { el.style.transition = 'opacity .25s'; el.style.opacity = '0'; setTimeout(function(){ el.remove(); }, 300); }
    });
    window.addEventListener('load', function () {
      setTimeout(function () {
        var el = document.getElementById('flt-loading');
        if (el) { el.remove(); }
      }, 15000);
    });
  </script>
  <script src="flutter_bootstrap.js" async></script>
`;

function head({ title, description, canonical, robots = 'index, follow, max-image-preview:large, max-snippet:-1', ogImage = '', ogType = 'website', schemas = [] }) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <base href="/">
  <meta name="google-site-verification" content="om6wtq_QAg9T6agjMo6fyHI6l9tKYxid3x2KZ7zqZmQ" />
  <title>${esc(title)}</title>
  <meta name="description" content="${esc(description)}">
  <meta name="robots" content="${esc(robots)}">
  <link rel="canonical" href="${SITE_URL}${canonical}">
  <meta property="og:site_name" content="ClickShop">
  <meta property="og:type" content="${esc(ogType)}">
  <meta property="og:title" content="${esc(title)}">
  <meta property="og:description" content="${esc(description)}">
  <meta property="og:url" content="${SITE_URL}${canonical}">
  ${ogImage ? `<meta property="og:image" content="${esc(ogImage)}">\n  <meta name="twitter:image" content="${esc(ogImage)}">` : ''}
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${esc(title)}">
  <meta name="twitter:description" content="${esc(description)}">
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="sitemap" type="application/xml" href="/sitemap.xml">
  ${jsonLd(siteGraph(), ...schemas)}
</head>
<body style="margin:0;font-family:-apple-system,Segoe UI,Roboto,sans-serif;background:#fafafa;color:#222;">
  <header style="background:${BRAND_COLOR};color:#fff;padding:18px 24px;">
    <a href="/" style="color:#fff;text-decoration:none;font-weight:800;font-size:20px;">ClickShop</a>
    <nav style="margin-top:10px;display:flex;gap:14px;flex-wrap:wrap;font-size:13px;">
      <a href="/category/all" style="color:#fff;text-decoration:none;">All products</a>
      <a href="/category/mens-fashion" style="color:#fff;text-decoration:none;">Men's Fashion</a>
      <a href="/category/womens-fashion" style="color:#fff;text-decoration:none;">Women's Fashion</a>
      <a href="/category/gaming" style="color:#fff;text-decoration:none;">Gaming</a>
      <a href="/category/electronics" style="color:#fff;text-decoration:none;">Electronics</a>
      <a href="/category/home-kitchen" style="color:#fff;text-decoration:none;">Home &amp; Kitchen</a>
    </nav>
  </header>`;
}

function shell({ title, description, canonical, schemas = [], ogImage = '', ogType = 'website', body }) {
  return `${head({ title, description, canonical, ogImage, ogType, schemas })}
  <main style="max-width:1080px;margin:0 auto;padding:28px 24px;background:#fff;min-height:60vh;">
    ${body}
  </main>
  <footer style="max-width:1080px;margin:0 auto;padding:24px;border-top:1px solid #eee;font-size:13px;color:#666;">
    <p><strong>Affiliate disclosure:</strong> As an affiliate, ClickShop may earn a commission from partner <a href="#" ${sponsoredRel}>retailer links</a> — you never pay extra. Ad placements are clearly marked.</p>
    <p>&copy; ${new Date().getFullYear()} ClickShop. All rights reserved.</p>
  </footer>
${bootstrapSnippet}
</body>
</html>`;
}

// ---------------------------------------------------------------- components

function priceHtml(p) {
  if (p.kind !== 'db' || p.price <= 0) {
    return `<span style="color:${BRAND_COLOR};font-weight:600;">View price on Amazon ›</span>`;
  }
  return p.originalPrice
    ? `<s style="color:#999;">$${Number(p.originalPrice).toFixed(2)}</s> <strong style="color:${BRAND_COLOR};">$${Number(p.price).toFixed(2)}</strong>`
    : `<strong style="color:${BRAND_COLOR};">$${Number(p.price).toFixed(2)}</strong>`;
}

function productCard(p) {
  return `<article style="border:1px solid #eee;border-radius:14px;overflow:hidden;background:#fff;">
    <a href="${esc(p.url)}" style="text-decoration:none;color:inherit;">
      ${p.images?.[0] ? `<img src="${esc(p.images[0])}" alt="${esc(p.name)}" width="300" height="300" style="width:100%;display:block;aspect-ratio:1/1;object-fit:cover;" loading="lazy">` : `<div style="height:200px;background:#f2f2f2;"></div>`}
      <div style="padding:14px;">
        <div style="font-size:12px;color:#888;">${esc(p.brand)}</div>
        <h2 style="font-size:15px;margin:6px 0;">${esc(p.name)}</h2>
        <div style="font-size:14px;">${priceHtml(p)}</div>
        ${p.reviewCount > 0 ? `<div style="font-size:12px;color:#888;margin-top:4px;">&#9733; ${p.rating} (${p.reviewCount} reviews)</div>` : ''}
      </div>
    </a>
  </article>`;
}

function productGrid(list, label = 'More products') {
  if (!list.length) return '';
  return `<h2>${esc(label)}</h2>
  <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;">
    ${list.map(productCard).join('\n')}
  </div>`;
}

function categoryLinks(categories, activeSlug = '') {
  const items = categories
    .filter((c) => c.slug !== activeSlug)
    .map((c) => `<a href="/category/${esc(c.slug)}">${esc(c.name)}</a>`)
    .join('');
  return items
    ? `<p style="font-size:13px;color:#666;">Browse: ${items} · <a href="/category/all">All products</a></p>`
    : '';
}

// ---------------------------------------------------------------- page builders

async function writePage(relPath, html, list) {
  const full = join(OUT_DIR, relPath);
  await mkdir(dirname(full), { recursive: true });
  await writeFile(full, html, 'utf8');
  list.push(relPath);
  return relPath;
}

function buildProductPage(p, related) {
  const canonical = p.url;
  const title = `${p.name} — ${p.brand} | ClickShop`;
  const description = (p.description || '').slice(0, 220);
  const crumbs = [
    { name: 'Home', path: '/' },
    ...(p.category ? [{ name: p.category, path: `/category/${p.category}` }] : []),
    { name: p.name, path: canonical },
  ];

  const buyButton = p.kind === 'amazon'
    ? `<p><a href="${esc(p.amazonUrl)}" ${sponsoredRel} style="display:inline-block;background:#ff9900;color:#fff;font-weight:700;padding:12px 22px;border-radius:28px;text-decoration:none;">Buy on Amazon</a></p>`
    : (p.price > 0
        ? `<p style="font-size:18px;">Price: <strong style="color:${BRAND_COLOR};">$${Number(p.price).toFixed(2)}</strong>${p.originalPrice ? ` <s style="color:#999;">$${Number(p.originalPrice).toFixed(2)}</s>` : ''} · ${p.stock > 0 ? 'In stock' : 'Out of stock'}</p>`
        : '');

  return shell({
    title,
    description: `${description}${p.price > 0 ? ` Price $${Number(p.price).toFixed(2)}.` : ''}`,
    canonical,
    ogImage: p.images?.[0] || '',
    ogType: 'product',
    schemas: [breadcrumb(crumbs), productSchema(p, canonical)],
    body: `
      <p style="font-size:13px;color:#888;"><a href="/" style="color:#888;">Home</a> › ${p.category ? `<a href="/category/${esc(p.category)}" style="color:#888;">${esc(p.category)}</a> › ` : ''}${esc(p.name)}</p>
      <h1 style="font-size:28px;margin:8px 0;">${esc(p.name)}</h1>
      <p style="color:#666;">${esc(p.brand)}${p.reviewCount > 0 ? ` · &#9733; ${p.rating} (${p.reviewCount} reviews)` : ''}</p>
      ${p.images?.[0] ? `<img src="${esc(p.images[0])}" alt="${esc(p.name)}" style="max-width:440px;width:100%;border-radius:14px;">` : ''}
      <p style="line-height:1.6;">${esc(p.description)}</p>
      ${buyButton}
      <p style="line-height:1.6;font-size:14px;color:#555;">${esc(description)}</p>
      ${productGrid(related, 'Related products')}
      <p style="font-size:13px;color:#666;"><small>As an Amazon Associate, ClickShop earns from qualifying purchases. Prices and availability are shown by the retailer.</small></p>`,
  });
}

function buildCategoryPage(slug, name, list, allCategories) {
  const canonical = `/category/${slug}`;
  const sample = list.slice(0, 4).map((p) => p.name).join(', ');
  const desc = list.length
    ? `Shop ${name.toLowerCase()} at ClickShop: ${sample}.`
    : `Explore ${name} at ClickShop.`;
  const crumbs = [
    { name: 'Home', path: '/' },
    { name, path: canonical },
  ];
  return shell({
    title: slug === 'all' ? 'All Products | ClickShop' : `${name} | ClickShop`,
    description: `${desc} ${list.length} products.`,
    canonical,
    ogType: 'website',
    schemas: [breadcrumb(crumbs), collectionSchema(list, canonical)],
    body: `
      <h1 style="font-size:28px;margin:8px 0;">${slug === 'all' ? 'All Products' : name}</h1>
      <p style="color:#666;">${list.length} products in this collection.</p>
      ${categoryLinks(allCategories, slug)}
      <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;margin-top:16px;">
        ${list.length ? list.map(productCard).join('\n') : '<p>No products in this category yet — check back soon.</p>'}
      </div>`,
  });
}

function buildGuidePage(guide, categoryMap, byAsin) {
  const canonical = `/guides/${guide.slug}`;
  const featured = (guide.featuredAsins || []).map((a) => byAsin.get(a)).filter(Boolean);
  const crumbs = [
    { name: 'Home', path: '/' },
    { name: 'Buying Guides', path: '/guides' },
    { name: guide.title, path: canonical },
  ];
  const sections = (guide.sections || [])
    .map(
      (s) => `<h2>${esc(s.heading)}</h2>${(s.paragraphs || []).map((para) => `<p style="line-height:1.6;">${esc(para)}</p>`).join('')}`,
    )
    .join('\n');
  const relatedCatLinks = (guide.relatedCategories || [])
    .map((slug) => {
      const c = categoryMap.get(slug);
      return c ? ` · <a href="/category/${esc(c.slug)}">${esc(c.name)}</a>` : '';
    })
    .join('');
  return shell({
    title: `${guide.title} | ClickShop`,
    description: guide.description || guide.title,
    canonical,
    ogType: 'article',
    schemas: [articleSchema(guide, canonical), breadcrumb(crumbs)],
    body: `
      <p style="font-size:13px;color:#888;"><a href="/" style="color:#888;">Home</a> › <a href="/guides" style="color:#888;">Buying guides</a> › ${esc(guide.title)}</p>
      <h1 style="font-size:28px;margin:8px 0;">${esc(guide.title)}</h1>
      <p style="color:#555;line-height:1.6;">${esc(guide.description)}</p>
      ${sections}
      ${featured.length ? `<h2>Products referenced in this guide</h2>\n  <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;">${featured.map(productCard).join('\n')}</div>` : ''}
      ${relatedCatLinks ? `<p style="font-size:13px;color:#666;">Browse:${relatedCatLinks}</p>` : ''}
      ${guide.relatedGuides?.length ? `<h2>Related guides</h2><ul>${guide.relatedGuides.map((s) => `<li><a href="/guides/${esc(s)}">${esc(s)}</a></li>`).join('')}</ul>` : ''}
      <p style="font-size:13px;color:#888;"><small>Buying-guide content reflects the retailer's product listings at curation time. Prices are shown by the retailer and may change.</small></p>`,
  });
}

function buildComparePage(c, left, right, bySlug) {
  const canonical = `/compare/${c.slug}`;
  const rows = [
    { label: 'Brand', left: left.brand, right: right.brand },
    { label: 'Category', left: left.category, right: right.category },
    { label: 'Form factor', left: left.kind === 'amazon' ? 'Curated Amazon listing' : 'In-store product', right: right.kind === 'amazon' ? 'Curated Amazon listing' : 'In-store product' },
    { label: 'Key specs & features', left: left.description, right: right.description },
    { label: 'Retail price', left: left.price > 0 ? `$${Number(left.price).toFixed(2)}` : 'Shown by Amazon', right: right.price > 0 ? `$${Number(right.price).toFixed(2)}` : 'Shown by Amazon' },
    { label: 'Rating', left: left.reviewCount > 0 ? `${left.rating} (${left.reviewCount})` : '—', right: right.reviewCount > 0 ? `${right.rating} (${right.reviewCount})` : '—' },
  ];
  const crumbs = [
    { name: 'Home', path: '/' },
    { name: 'Comparisons', path: '/compare' },
    { name: c.title, path: canonical },
  ];
  return shell({
    title: `${c.title} | ClickShop`,
    description: c.description,
    canonical,
    ogType: 'article',
    schemas: [articleSchema(c, canonical), breadcrumb(crumbs)],
    body: `
      <p style="font-size:13px;color:#888;"><a href="/" style="color:#888;">Home</a> › <a href="/compare" style="color:#888;">Compare</a> › ${esc(c.title)}</p>
      <h1 style="font-size:28px;margin:8px 0;">${esc(c.title)}</h1>
      <p style="line-height:1.6;color:#555;">${esc(c.introduction)}</p>
      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;margin:18px 0;">
        ${productCard(left)}
        ${productCard(right)}
      </div>
      <table style="width:100%;border-collapse:collapse;font-size:14px;">
        ${rows.map((r) => `<tr style="border-bottom:1px solid #eee;"><td style="padding:10px 8px;font-weight:600;width:30%;vertical-align:top;">${esc(r.label)}</td><td style="padding:10px 8px;vertical-align:top;">${esc(r.left)}</td><td style="padding:10px 8px;vertical-align:top;">${esc(r.right)}</td></tr>`).join('')}
      </table>
      <h2>Bottom line</h2>
      <p style="line-height:1.6;">${esc(c.conclusion)}</p>
      ${c.relatedGuides?.length ? `<h2>Related guides</h2><ul>${c.relatedGuides.map((s) => `<li><a href="/guides/${esc(s)}">${esc(s)}</a></li>`).join('')}</ul>` : ''}
      <p style="font-size:13px;color:#888;"><small>Data is pulled directly from each product's current listing — we never invent specs, prices or ratings.</small></p>`,
  });
}

// ---------------------------------------------------------------- index.html

async function injectIndex(products, categoryMap, bySlug, guides) {
  const index = await readFile(HOST_INDEX, 'utf8');
  const cats = [...categoryMap.values()].slice(0, 8);
  const featured = products.slice(0, 8);

  const noscriptBody = `
      <h1>ClickShop — Premium Fashion, Sneakers, Electronics &amp; Tech</h1>
      <p>ClickShop curates real products across fashion, sneakers, electronics, gaming gear and home essentials. Compare prices, read buying guides and shop securely with JavaScript enabled — or contact our team any time.</p>
      <h2>Shop by category</h2>
      <ul>
        ${cats.map((c) => `<li><a href="/category/${esc(c.slug)}">${esc(c.name)}</a></li>`).join('\n        ')}
        <li><a href="/category/all">All products</a></li>
      </ul>
      <h2>Popular products</h2>
      <ul>
        ${featured.map((p) => `<li><a href="${esc(p.url)}">${esc(p.name)}</a></li>`).join('\n        ')}
      </ul>
      <h2>Buying guides &amp; comparisons</h2>
      <ul>
        ${guides.map((g) => `<li><a href="/guides/${esc(g.slug)}">${esc(g.title)}</a></li>`).join('\n        ')}
      </ul>
      <p><small>As an affiliate, ClickShop may earn a commission from partner links. Ad placements are clearly marked and reserved in fixed-size boxes.</small></p>`;

  const schemaBody = jsonLd(
    collectionSchema(featured, '/'),
    {
      '@context': 'https://schema.org',
      '@type': 'ItemList',
      name: 'ClickShop featured products',
      itemListElement: featured.map((p, i) => ({
        '@type': 'ListItem',
        position: i + 1,
        url: `${SITE_URL}${p.url}`,
      })),
    },
  );

  const withNoscript = index.includes('<!--PRERENDER:NOSCRIPT-->')
    ? index.replace(/<!--PRERENDER:NOSCRIPT-->[\s\S]*?<!--\/PRERENDER:NOSCRIPT-->/, `<!--PRERENDER:NOSCRIPT-->${noscriptBody}<!--/PRERENDER:NOSCRIPT-->`)
    : index;

  const final = withNoscript.includes('<!--PRERENDER:SCHEMA-->')
    ? withNoscript.replace(/<!--PRERENDER:SCHEMA-->[\s\S]*?<!--\/PRERENDER:SCHEMA-->/, `<!--PRERENDER:SCHEMA-->${schemaBody}<!--/PRERENDER:SCHEMA-->`)
    : withNoscript;

  await writeFile(HOST_INDEX, final, 'utf8');
  return 'index.html (injected)';
}

// ---------------------------------------------------------------- sitemap

function buildSitemapURLs(products, allCategoryPages, guides, compares) {
  return [
    '/',
    ...[...allCategoryPages].map((c) => `/category/${c.slug}`),
    ...products.map((p) => p.url),
    ...guides.map((g) => `/guides/${g.slug}`),
    ...compares.map((c) => `/compare/${c.slug}`),
  ];
}

function sitemapXml(urls) {
  return `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="${xmlns}">\n${urls
    .map((u) => {
      const priority = u === '/' ? '1.0' : u.startsWith('/product/') ? '0.6' : u.startsWith('/category/') ? '0.8' : '0.7';
      return `  <url>\n    <loc>${SITE_URL}${u}</loc>\n    <changefreq>${u === '/' ? 'daily' : 'weekly'}</changefreq>\n    <priority>${priority}</priority>\n  </url>`;
    })
    .join('\n')}
</urlset>\n`;
}

// ---------------------------------------------------------------- main

async function main() {
  const catalog = await loadCatalog();
  const { products, bySlug, byAsin, categoryMap } = catalog;

  const guidesJson = await readFile(join(SEO_DIR, 'guides.json'), 'utf8').then((t) => JSON.parse(t)).catch(() => []);
  const comparesJson = await readFile(join(SEO_DIR, 'comparisons.json'), 'utf8').then((t) => JSON.parse(t)).catch(() => []);

  console.log(`[prerender] ${products.length} products, ${categoryMap.size} categories, ${guidesJson.length} guides, ${comparesJson.length} comparisons.`);
  console.log(`[prerender] site=${SITE_URL}  api=${STORE_API_BASE}  out=${OUT_DIR}`);

  // Clear generated dirs but keep the Flutter build output untouched.
  for (const rel of ['product', 'category', 'guides', 'compare']) {
    await rm(join(OUT_DIR, rel), { recursive: true, force: true });
  }

  const written = [];

  // Home index.html injection (works on the Flutter build shell).
  await injectIndex(products, categoryMap, bySlug, guidesJson);

  // Category pages: DB + curated slugs (+ umbrella 'all' and 'gaming').
  const allCategories = [
    { slug: 'all', name: 'All Products' },
    ...[...categoryMap.values()].sort((a, b) => a.name.localeCompare(b.name)),
  ];
  if (!categoryMap.has('gaming')) {
    allCategories.push({ slug: 'gaming', name: 'Gaming' });
  }
  for (const c of allCategories) {
    // Backend treats 'gaming' as the umbrella for the whole curated Amazon
    // catalog, mirroring that here.
    const list =
      c.slug === 'gaming'
        ? products.filter((p) => p.kind === 'amazon')
        : products.filter((p) => {
            if (c.slug === 'all') return true;
            return (p.category || '').toLowerCase() === c.slug.toLowerCase();
          });
    await writePage(`/category/${c.slug}.html`.slice(1), buildCategoryPage(c.slug, c.name, list, allCategories), written);
  }

  // Product pages + related (same category, up to 4).
  for (const p of products) {
    const related = products
      .filter((x) => x.url !== p.url && x.category === p.category)
      .slice(0, 4);
    await writePage(`/product/${p.slug}.html`.slice(1), buildProductPage(p, related), written);
  }

  // Guide pages.
  for (const g of guidesJson) {
    await writePage(`/guides/${g.slug}.html`.slice(1), buildGuidePage(g, categoryMap, byAsin), written);
  }

  // Comparison pages.
  for (const c of comparesJson) {
    const left = byAsin.get(c.leftAsin);
    const right = byAsin.get(c.rightAsin);
    if (!left || !right) {
      console.warn(`[prerender] skipping comparison '${c.slug}' (missing curated product).`);
      continue;
    }
    await writePage(`/compare/${c.slug}.html`.slice(1), buildComparePage(c, left, right, bySlug), written);
  }

  // 404 page (soft-404, noindex).
  await writePage('/404.html'.slice(1), shell({
    title: 'Page Not Found | ClickShop',
    description: 'The page you are looking for does not exist or has moved.',
    canonical: '/404',
    robots: 'noindex, follow',
    body: '<h1 style="font-size:28px;">Page not found</h1><p>The page you are looking for may have moved. Try the <a href="/">homepage</a> or <a href="/sitemap.xml">sitemap</a>.</p>',
  }), written);

  // Sitemap + robots.
  const urls = buildSitemapURLs(products, allCategories, guidesJson, comparesJson);
  const sitemap = sitemapXml(urls);
  await writeFile(join(OUT_DIR, 'sitemap.xml'), sitemap, 'utf8');
  await writeFile(SITEMAP_REPO, sitemap, 'utf8');

  if (join(WEB_DIR, 'robots.txt') !== join(OUT_DIR, 'robots.txt')) {
    await copyFile(join(WEB_DIR, 'robots.txt'), join(OUT_DIR, 'robots.txt'));
  }

  console.log(`[prerender] wrote ${written.length} pages to ${OUT_DIR}`);
  console.log(`[prerender] regenerated sitemap.xml (${urls.length} URLs)`);
}

main().catch((error) => {
  console.error('[prerender] failed:', error);
  process.exit(1);
});