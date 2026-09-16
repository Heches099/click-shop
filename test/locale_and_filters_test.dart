import 'dart:ui';

import 'package:click_shop/domain/entities/product.dart';
import 'package:click_shop/presentation/search/providers/catalog_search_provider.dart';
import 'package:click_shop/presentation/settings/providers/locale_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocales.resolve', () {
    test('resolves supported language codes', () {
      expect(AppLocales.resolve('en'), const Locale('en'));
      expect(AppLocales.resolve('sw'), const Locale('sw'));
      expect(AppLocales.resolve('fr'), const Locale('fr'));
      expect(AppLocales.resolve('ar'), const Locale('ar'));
    });

    test('strips regional suffixes before matching', () {
      expect(AppLocales.resolve('fr_CA'), const Locale('fr'));
      expect(AppLocales.resolve('ar_EG'), const Locale('ar'));
      expect(AppLocales.resolve('sw-KE'), const Locale('sw'));
    });

    test('falls back to English for unsupported languages', () {
      expect(AppLocales.resolve('zh'), const Locale('en'));
      expect(AppLocales.resolve('de'), const Locale('en'));
      expect(AppLocales.resolve(''), const Locale('en'));
      expect(AppLocales.resolve(null), const Locale('en'));
    });

    test('isRtl only for Arabic', () {
      expect(AppLocales.isRtl('ar'), isTrue);
      expect(AppLocales.isRtl('en'), isFalse);
      expect(AppLocales.isRtl('fr'), isFalse);
      expect(AppLocales.isRtl('sw'), isFalse);
    });
  });

  group('applyLocalFilters (search sort)', () {
    Product product(String id, double price) => Product(
          id: id,
          name: id,
          description: '',
          price: price,
          images: const [],
          rating: 4,
          reviewCount: 10,
          category: 'x',
          stock: 5,
          brand: 'Nike',
        );

    final products = [
      product('cheap', 10),
      product('mid', 50),
      product('expensive', 200),
    ];

    CatalogSearchParams params({String sort = 'Popularity'}) => (
          query: 'test',
          minPrice: null,
          maxPrice: null,
          sort: sort,
          brands: const [],
        );

    test('Popularity keeps original order', () {
      final result =
          applyLocalFilters(products, params(sort: 'Popularity'));
      expect(result.map((p) => p.id).toList(), ['cheap', 'mid', 'expensive']);
    });

    test('Price: Low to High sorts ascending', () {
      final result =
          applyLocalFilters(products, params(sort: 'Price: Low to High'));
      expect(result.map((p) => p.price).toList(), [10, 50, 200]);
    });

    test('Price: High to Low sorts descending', () {
      final result =
          applyLocalFilters(products, params(sort: 'Price: High to Low'));
      expect(result.map((p) => p.price).toList(), [200, 50, 10]);
    });

    test('does not mutate the input list', () {
      final copy = List<Product>.of(products);
      applyLocalFilters(products, params(sort: 'Price: High to Low'));
      expect(products.map((p) => p.id).toList(),
          copy.map((p) => p.id).toList());
    });
  });
}