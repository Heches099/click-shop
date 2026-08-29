/// Native (non-web) stub for [SeoService]. SEO is a web-only concern, so all
/// mutations are safe no-ops. Using `dart.library.js_interop` means this stub
/// is also selected for iOS/Android/desktop builds.
library;
import 'dart:async';

import '../../../domain/entities/product.dart';

void setPageMeta({String? title, String? description, String? canonicalPath}) {}

bool injectJsonLd(Map<String, dynamic> json, {String id = 'default'}) => false;

void clearJsonLd(String id) {}

void injectProductSchema(Product product, {String? canonicalPath}) {}

void injectCollectionPage(List<Product> products, {String? canonicalPath}) {}

void injectSiteSchema() {}

final Future<void> firstFrame = Future<void>.value();
