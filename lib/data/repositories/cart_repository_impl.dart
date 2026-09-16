import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasource/local_cart_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final LocalCartDataSource localDataSource;

  CartRepositoryImpl(this.localDataSource);

  @override
  List<CartItem> getCartItems() {
    return localDataSource.getCartItems().map((m) => m.toEntity()).toList();
  }

  @override
  void saveAll(List<CartItem> items) {
    localDataSource.saveAll(items.map(CartItemModel.fromEntity).toList());
  }
}