import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';
import 'address_model.dart';
import 'cart_item_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingFee,
    required double tax,
    required double total,
    required AddressModel shippingAddress,
    required String status, // Store enum as string
    required DateTime createdAt,
    String? trackingNumber,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromEntity(OrderEntity order) => OrderModel(
        id: order.id,
        userId: order.userId,
        items: order.items.map((i) => CartItemModel.fromEntity(i)).toList(),
        subtotal: order.subtotal,
        shippingFee: order.shippingFee,
        tax: order.tax,
        total: order.total,
        shippingAddress: AddressModel.fromEntity(order.shippingAddress),
        status: order.status.name,
        createdAt: order.createdAt,
        trackingNumber: order.trackingNumber,
      );
}

extension OrderModelX on OrderModel {
  OrderEntity toEntity() => OrderEntity(
        id: id,
        userId: userId,
        items: items.map((i) => i.toEntity()).toList(),
        subtotal: subtotal,
        shippingFee: shippingFee,
        tax: tax,
        total: total,
        shippingAddress: shippingAddress.toEntity(),
        status: OrderStatus.values.byName(status),
        createdAt: createdAt,
        trackingNumber: trackingNumber,
      );
}
