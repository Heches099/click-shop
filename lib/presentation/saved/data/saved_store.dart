import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/amazon_product.dart';

class SavedStore {
  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>('saved_amazon');
    return _box!;
  }

  static Map<String, dynamic> _toMap(AmazonProduct product) {
    return {
      'id': product.id,
      'asin': product.asin,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'images': product.images,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'category': product.category,
      'brand': product.brand,
      'amazonUrl': product.amazonUrl,
    };
  }

  Future<List<AmazonProduct>> load() async {
    final raw = (await _getBox()).get('items');
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AmazonProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> persist(List<AmazonProduct> products) async {
    final json = jsonEncode(products.map(_toMap).toList());
    await (await _getBox()).put('items', json);
  }
}