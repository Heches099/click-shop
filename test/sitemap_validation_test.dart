import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Validates that `web/sitemap.xml` is well-formed, contains the expected
/// seed URLs, and has no private/internal/admin paths exposed.
void main() {
  const sitemapPath = 'web/sitemap.xml';
  late String raw;

  setUpAll(() {
    raw = File(sitemapPath).readAsStringSync();
  });

  test('sitemap.xml is valid XML', () {
    // Quick structural checks — proper XML open/close tags.
    expect(raw.trimLeft().startsWith('<?xml'), isTrue,
        reason: 'sitemap must start with XML declaration');
    expect(raw.trim().endsWith('</urlset>'), isTrue,
        reason: 'sitemap must close with </urlset>');
  });

  test('sitemap contains the homepage URL', () {
    expect(raw, contains('https://click-shop-d62ad.web.app/'));
  });

  test('sitemap contains category URLs', () {
    expect(raw, contains('/category/all'));
    expect(raw, contains('/category/sneakers'));
  });

  test('sitemap contains product URLs', () {
    expect(raw, contains('/product/'));
  });

  test('sitemap contains guide URLs', () {
    expect(raw, contains('/guides/'));
  });

  test('sitemap contains compare URLs', () {
    expect(raw, contains('/compare/'));
  });

  test('sitemap has no private or admin URLs', () {
    final lowercase = raw.toLowerCase();
    expect(lowercase.contains('/admin'), isFalse,
        reason: 'sitemap should never expose /admin routes');
    expect(lowercase.contains('/login'), isFalse,
        reason: 'login page should not be in sitemap');
    expect(lowercase.contains('/owner'), isFalse,
        reason: 'owner dashboard should not be in sitemap');
  });

  test('no duplicate URLs in sitemap', () {
    final lines = raw.split('\n').where((l) => l.contains('<loc>')).toList();
    final urls = lines
        .map((l) => l.replaceAll(RegExp(r'</?loc>'), '').trim())
        .toList();
    final unique = urls.toSet();
    expect(urls.length, unique.length,
        reason: 'Duplicate URLs found in sitemap');
  });

  test('sitemap has no empty location values', () {
    final locPattern = RegExp(r'<loc>(.*?)</loc>');
    final matches = locPattern.allMatches(raw);
    expect(matches.isNotEmpty, isTrue, reason: 'No <loc> tags found');
    for (final m in matches) {
      expect(m.group(1)!.trim().isNotEmpty, isTrue,
          reason: 'Empty <loc> tag found');
    }
  });
}