import '../../domain/entities/cart_item.dart';
import '../datasource/local_cart_datasource.dart';
import '../models/cart_item_model.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(CartItem item);
  Future<void> removeFromCart(String productId);
  Future<void> clearCart();
}

class CartRepositoryImpl implements CartRepository {
  final LocalCartDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItem>> getCartItems() async {
    final models = await localDataSource.getCartItems();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addToCart(CartItem item) async {
    await localDataSource.saveCartItem(CartItemModel.fromEntity(item));
  }

  @override
  Future<void> removeFromCart(String productId) async {
    await localDataSource.removeCartItem(productId);
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.clearCart();
  }
}
