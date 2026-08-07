import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;

  const CartItem({
    required this.product,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}
