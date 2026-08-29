// Web implementation of the SEO service. Built on `package:web`
// (dart:js_interop) so it compiles and runs under both JS and Wasm/Skwasm
// builds — never `dart:html`.
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../constants/app_constants.dart';
import '../../../domain/entities/product.dart';

/// Updates `<title>`, meta description, canonical and Open Graph tags.
void setPageMeta({
  String? title,
  String? description,
  String? canonicalPath,
}) {
  final doc = web.document;
  final url = '${AppConstants.storeBaseUrl}$canonicalPath';

  if (title != null && title.isNotEmpty) {
    doc.title = title;
    _setMeta('og:title', title, property: true);
    _setMeta('twitter:title', title);
  }
  if (description != null && description.isNotEmpty) {
    _setMeta('description', description);
    _setMeta('og:description', description, property: true);
    _setMeta('twitter:description', description);
  }
  if (canonicalPath != null) {
    _setCanonical(url);
    _setMeta('og:url', url, property: true);
    _setMeta('twitter:url', url);
  }
}

/// Appends (or replaces) a JSON-LD script in `<head>` tagged by [id].
bool injectJsonLd(Map<String, dynamic> json, {String id = 'default'}) {
  final doc = web.document;
  final tag = 'data-seo-jsonld="$id"';
  final existing = doc.querySelector('script[$tag]');
  existing?.remove();

  final script = doc.createElement('script') as web.HTMLScriptElement;
  script.setAttribute('type', 'application/ld+json');
  script.setAttribute('data-seo-jsonld', id);
  script.text = jsonEncode(json);
  doc.head?.appendChild(script);
  return true;
}

void clearJsonLd(String id) {
  web.document.querySelector('script[data-seo-jsonld="$id"]')?.remove();
}

/// schema.org/Product JSON-LD for an individual product page.
void injectProductSchema(Product product, {String? canonicalPath}) {
  final canonical = canonicalPath ?? '/products/${product.id}';
  final url = '${AppConstants.storeBaseUrl}$canonical';

  final schema = <String, dynamic>{
    '@context': 'https://schema.org',
    '@type': 'Product',
    '@id': url,
    'name': product.name,
    'description': product.description,
    'image': product.images.isNotEmpty ? product.images : null,
    'brand': {
      '@type': 'Brand',
      'name': product.brand,
    },
    'category': product.category,
    'sku': product.id,
    'url': url,
    if (product.hasDiscount)
      'offers': {
        '@type': 'AggregateOffer',
        'lowPrice': product.price,
        'highPrice': product.originalPrice,
        'priceCurrency': 'USD',
        'offerCount': 1,
        'availability': product.stock > 0
            ? 'https://schema.org/InStock'
            : 'https://schema.org/OutOfStock',
        'itemCondition': 'https://schema.org/NewCondition',
      }
    else
      'offers': {
        '@type': 'Offer',
        'price': product.price,
        'priceCurrency': 'USD',
        'availability': product.stock > 0
            ? 'https://schema.org/InStock'
            : 'https://schema.org/OutOfStock',
        'itemCondition': 'https://schema.org/NewCondition',
      },
    if (product.reviewCount > 0)
      'aggregateRating': {
        '@type': 'AggregateRating',
        'ratingValue': product.rating,
        'reviewCount': product.reviewCount,
        'bestRating': 5,
        'worstRating': 1,
      },
  };

  injectJsonLd(schema, id: 'product_${product.id}');
}

/// schema.org/ItemList JSON-LD for category and collection pages.
void injectCollectionPage(List<Product> products, {String? canonicalPath}) {
  final canonical = canonicalPath ?? '/';
  final url = '${AppConstants.storeBaseUrl}$canonical';

  final schema = <String, dynamic>{
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    'url': url,
    'mainEntity': {
      '@type': 'ItemList',
      'itemListElement': [
        for (final (index, product) in products.take(48).indexed)
          {
            '@type': 'ListItem',
            'position': index + 1,
            'name': product.name,
            'url': '${AppConstants.storeBaseUrl}/products/${product.id}',
            'image': product.firstImage,
          },
      ],
    },
  };

  injectJsonLd(schema, id: 'collection_$canonical');
}

/// WebSite + Organization schemas. Called once at startup; crawlable from the
/// static HTML snapshot even before the Flutter engine initialises.
void injectSiteSchema() {
  final site = AppConstants.storeBaseUrl;
  injectJsonLd({
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'WebSite',
        '@id': '$site/#website',
        'url': site,
        'name': AppConstants.appName,
        'description': 'Premium fashion, sneakers and electronics at the best prices.',
        'inLanguage': 'en-US',
      },
      {
        '@type': 'Organization',
        '@id': '$site/#organization',
        'url': site,
        'name': AppConstants.appName,
        'logo': '$site/icons/Icon-512.png',
      },
    ],
  }, id: 'site_schema');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _setMeta(String name, String content, {bool property = false}) {
  final doc = web.document;
  final attr = property ? 'property' : 'name';
  var tag = doc.querySelector('meta[$attr="$name"]') as web.HTMLMetaElement?;
  if (tag == null) {
    tag = doc.createElement('meta') as web.HTMLMetaElement;
    tag.setAttribute(attr, name);
    doc.head?.appendChild(tag);
  }
  tag.setAttribute('content', content);
}

void _setCanonical(String url) {
  final doc = web.document;
  var tag = doc.querySelector('link[rel="canonical"]') as web.HTMLLinkElement?;
  if (tag == null) {
    tag = doc.createElement('link') as web.HTMLLinkElement;
    tag.setAttribute('rel', 'canonical');
    doc.head?.appendChild(tag);
  }
  tag.setAttribute('href', url);
}

/// Completes on the engine's `flutter-first-frame` DOM event. If the event has
/// already fired (or a browser never dispatches it) we resolve immediately so
/// deferred work is never permanently blocked.
final Future<void> firstFrame = _resolveFirstFrame();

Future<void> _resolveFirstFrame() {
  final completer = Completer<void>();

  void done() {
    if (completer.isCompleted) return;
    completer.complete();
  }

  // The engine dispatches `flutter-first-frame` on window once the first
  // frame is rendered.
  web.window.addEventListener(
      'flutter-first-frame', ((web.Event _) => done()).toJS);
  web.window.addEventListener('load', ((web.Event _) => done()).toJS);

  // Safety valve: never wait longer than 12s.
  Timer(const Duration(seconds: 12), done);

  return completer.future;
}
