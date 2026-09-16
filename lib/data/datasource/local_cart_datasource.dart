import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';

abstract class LocalCartDataSource {
  List<CartItemModel> getCartItems();
  void saveAll(List<CartItemModel> items);
}

/// Hive-backed cart. The box is opened once during service-locator init so all
/// reads/writes are synchronous and the cart survives page refreshes.
class HiveCartDataSource implements LocalCartDataSource {
  final Box<String> _box;

  HiveCartDataSource(this._box);

  @override
  List<CartItemModel> getCartItems() {
    return _box.values
        .map((jsonStr) => CartItemModel.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  @override
  void saveAll(List<CartItemModel> items) {
    _box.clear();
    for (final item in items) {
      _box.put(item.product.id, jsonEncode(item.toJson()));
    }
  }
}