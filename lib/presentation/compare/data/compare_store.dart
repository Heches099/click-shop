import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/product.dart';

/// Persists the "Compare" shortlist (Hive). Comparing is facts, not
/// rankings: we store the products and let the UI surface what differs.
class CompareStore {
  Box<String>? _box;

  static const int maxItems = 4;

  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>('compare_box');
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
      'specifications': product.specifications,
      'colors': product.colors,
      'sizes': product.sizes,
      'asin': product.asin,
      'amazonUrl': product.amazonUrl,
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
      specifications: (map['specifications'] is Map)
          ? (map['specifications'] as Map).cast<String, String>()
          : const {},
      colors: (map['colors'] as List<dynamic>?)?.cast<String>() ?? const [],
      sizes: (map['sizes'] as List<dynamic>?)?.cast<String>() ?? const [],
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

  Future<void> persist(List<Product> products) async {
    final json = jsonEncode(products.map(_toMap).toList());
    await (await _getBox()).put('items', json);
  }
}