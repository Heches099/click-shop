import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/order.dart';

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<OrderEntity>>(OrdersNotifier.new);

class OrdersNotifier extends Notifier<List<OrderEntity>> {
  @override
  List<OrderEntity> build() => [];

  OrderEntity placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required Address shippingAddress,
    String? affiliateCode,
  }) {
    final shipping = subtotal > 500 ? 0.0 : 15.0;
    final order = OrderEntity(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1',
      items: items,
      subtotal: subtotal,
      shippingFee: shipping,
      tax: 0,
      total: subtotal + shipping,
      shippingAddress: shippingAddress,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
      trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch % 1000000}',
      affiliateCode: affiliateCode,
    );
    state = [order, ...state];
    return order;
  }

  void cancelOrder(String id) {
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
  }
}
