import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<OrderEntity>>(OrdersNotifier.new);

class OrdersNotifier extends Notifier<List<OrderEntity>> {
  @override
  List<OrderEntity> build() {
    _load();
    return [];
  }

  /// Loads the signed-in user's orders from the backend.
  Future<void> _load() async {
    final result = await sl<OrderRepository>().getOrders();
    result.fold(
      (_) {/* keep whatever is shown on transient network failures */},
      (orders) => state = orders,
    );
  }

  /// Refreshes the list after a successful checkout.
  Future<void> refresh() => _load();

  /// Optimistically marks the order cancelled, then syncs with the backend
  /// (which reverses any pending affiliate commission).
  Future<void> cancelOrder(String id) async {
    state = state.map((order) {
      if (order.id != id || order.status == OrderStatus.delivered) return order;
      return OrderEntity(
        id: order.id,
        userId: order.userId,
        items: order.items,
        subtotal: order.subtotal,
        shippingFee: order.shippingFee,
        tax: order.tax,
        total: order.total,
        shippingAddress: order.shippingAddress,
        status: OrderStatus.cancelled,
        createdAt: order.createdAt,
        trackingNumber: order.trackingNumber,
      );
    }).toList();

    final result = await sl<OrderRepository>().cancelOrder(id);
    result.fold(
      (_) => _load(),
      (order) {
        state = state.map((o) => o.id == order.id ? order : o).toList();
      },
    );
  }
}