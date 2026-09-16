import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cart_item.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    String? refCode,
    String paymentMethod = 'card',
  });

  Future<Either<Failure, List<OrderEntity>>> getOrders();

  Future<Either<Failure, OrderEntity>> cancelOrder(String orderId);
}