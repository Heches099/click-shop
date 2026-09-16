import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasource/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    String? refCode,
    String paymentMethod = 'card',
  }) async {
    try {
      final model = await remoteDataSource.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        refCode: refCode,
        paymentMethod: paymentMethod,
      );
      return Right(model.toEntity());
    } catch (e) {
      if (e.toString().contains('401')) return const Left(Failure.unauthorized());
      return Left(Failure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      final models = await remoteDataSource.getOrders();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (e.toString().contains('401')) return const Left(Failure.unauthorized());
      return Left(Failure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(String orderId) async {
    try {
      final model = await remoteDataSource.cancelOrder(orderId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure.serverError(e.toString()));
    }
  }
}