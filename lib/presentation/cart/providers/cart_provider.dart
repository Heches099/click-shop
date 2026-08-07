import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Product product, {String? color, String? size}) {
    final index = state.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedColor == color && 
      item.selectedSize == size);

    if (index != -1) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, CartItem(
        product: product, 
        quantity: 1, 
        selectedColor: color, 
        selectedSize: size
      )];
    }
  }

  void removeItem(String productId, {String? color, String? size}) {
    state = state.where((item) => 
      !(item.product.id == productId && 
        item.selectedColor == color && 
        item.selectedSize == size)).toList();
  }

  void updateQuantity(String productId, int quantity, {String? color, String? size}) {
    if (quantity <= 0) {
      removeItem(productId, color: color, size: size);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId && 
          item.selectedColor == color && 
          item.selectedSize == size) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void clearCart() {
    state = [];
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.totalPrice);
}
