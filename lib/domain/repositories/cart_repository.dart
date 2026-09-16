import '../entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> getCartItems();
  void saveAll(List<CartItem> items);
}