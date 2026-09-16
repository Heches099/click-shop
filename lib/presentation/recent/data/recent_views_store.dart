import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/product.dart';

/// Persists the last few viewed products so shoppers can pick up where they
/// left off. Radial: most recent first, capped at a small number.
class RecentViewsStore {
  Box<String>? _box;

  static const int maxItems = 12;

  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>('recentViewsBox');
    return _box!;
  }

  static Map<String, dynamic> _toMap(Product product) {
    return {
      'id': product.id,
      'slug': product.slug,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'images': product.images,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'category': product.category,
      'stock': product.stock,
      'brand': product.brand,
      'asin': product.asin,
      'amazonUrl': product.amazonUrl,
      'viewedAt': DateTime.now().toIso8601String(),
    };
  }

  static Product _fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String? ?? '',
      slug: map['slug'] as String?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      images: (map['images'] as List<dynamic>?)?.cast<String>() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      brand: map['brand'] as String? ?? '',
      asin: map['asin'] as String?,
      amazonUrl: map['amazonUrl'] as String?,
    );
  }

  Future<List<Product>> load() async {
    final raw = (await _getBox()).get('items');
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => _fromMap(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> record(Product product) async {
    final current = await load();
    final next = [
      product,
      ...current.where((p) => p.id != product.id),
    ].take(maxItems).toList();
    final json = jsonEncode(next.map(_toMap).toList());
    await (await _getBox()).put('items', json);
  }

  Future<void> clear() async {
    await (await _getBox()).put('items', jsonEncode(const []));
  }
}