import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';

abstract class LocalCartDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItem(CartItemModel item);
  Future<void> removeCartItem(String productId);
  Future<void> clearCart();
}

class HiveCartDataSource implements LocalCartDataSource {
  static const String _boxName = 'cart_box';

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.values
        .map((jsonStr) => CartItemModel.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  @override
  Future<void> saveCartItem(CartItemModel item) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.put(item.product.id, jsonEncode(item.toJson()));
  }

  @override
  Future<void> removeCartItem(String productId) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.delete(productId);
  }

  @override
  Future<void> clearCart() async {
    final box = await Hive.openBox<String>(_boxName);
    await box.clear();
  }
}
