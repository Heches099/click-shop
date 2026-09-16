import '../../core/network/dio_client.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    String? refCode,
    String paymentMethod,
  });

  Future<List<OrderModel>> getOrders();

  Future<OrderModel> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl(this.dioClient);

  @override
  Future<OrderModel> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    String? refCode,
    String paymentMethod = 'card',
  }) async {
    final response = await dioClient.dio.post(
      '/orders',
      data: {
        'items': [
          for (final item in items)
            {
              'product_id': item.product.id,
              'quantity': item.quantity,
              'selected_color': item.selectedColor ?? 'Default',
              'selected_size': item.selectedSize,
            },
        ],
        'shipping_address': {
          'name': shippingAddress.name,
          'phone': shippingAddress.phone,
          'street': shippingAddress.street,
          'city': shippingAddress.city,
          'state': shippingAddress.state,
          'zip_code': shippingAddress.zipCode,
          'country': shippingAddress.country,
          'is_default': shippingAddress.isDefault,
        },
        'payment_method': paymentMethod,
        'ref_code': refCode,
      },
    );
    return OrderModel.fromJson(_asObject(response.data));
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await dioClient.dio.get('/orders');
    return _extractList(response.data)
        .map((json) => OrderModel.fromJson(_asObject(json)))
        .toList();
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    final response = await dioClient.dio.post('/orders/$orderId/cancel');
    return OrderModel.fromJson(_asObject(response.data));
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const ['data', 'orders', 'items']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asObject(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.cast<String, dynamic>();
    throw const FormatException('Expected a JSON object');
  }
}