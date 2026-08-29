import '../../../domain/entities/product.dart';
import 'seo_service_stub.dart'
    if (dart.library.js_interop) 'seo_service_web.dart' as impl;

/// Platform-agnostic facade for on-page SEO mutations.
///
/// - Web (JS + Wasm): updates `<title>`, meta description, canonical + Open
///   Graph tags and injects JSON-LD structured data into `<head>`.
/// - Native: every call is a no-op so the rest of the app is untouched.
class SeoService {
  SeoService._();

  static final SeoService instance = SeoService._();

  /// Set the document `<title>`, meta description, canonical URL and Open
  /// Graph / Twitter social tags. No-ops on native platforms.
  void setPageMeta({
    String? title,
    String? description,
    String? canonicalPath,
  }) =>
      impl.setPageMeta(title: title, description: description, canonicalPath: canonicalPath);

  /// Injects a raw JSON-LD object into `<head>`, replacing any previous script
  /// carrying the same [id]. Returns true when the tag was written.
  bool injectJsonLd(Map<String, dynamic> json, {String id = 'default'}) =>
      impl.injectJsonLd(json, id: id);

  /// Removes a previously injected JSON-LD script by [id].
  void clearJsonLd(String id) => impl.clearJsonLd(id);

  /// Injects the Google Product schema (`@graph` of [schema.org/Product](https://schema.org/Product))
  /// for a single product page.
  void injectProductSchema(Product product, {String? canonicalPath}) =>
      impl.injectProductSchema(product, canonicalPath: canonicalPath);

  /// Injects an `ItemList` schema for category / collection pages.
  void injectCollectionPage(List<Product> products, {String? canonicalPath}) =>
      impl.injectCollectionPage(products, canonicalPath: canonicalPath);

  /// Injects the WebSite + Organization schemas (called once at startup).
  void injectSiteSchema() => impl.injectSiteSchema();

  /// Resolves once the Flutter engine has painted its first frame
  /// (`flutter-first-frame` DOM event). Ads & third-party scripts must await
  /// this so they never delay or shift the initial render (LCP/INP safe).
  Future<void> get firstFrame => impl.firstFrame;
}
