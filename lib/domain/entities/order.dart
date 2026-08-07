import 'cart_item.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class OrderEntity {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final Address shippingAddress;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingNumber;

  /// Affiliate promo code that referred this order, if any.
  final String? affiliateCode;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.status,
    required this.createdAt,
    this.trackingNumber,
    this.affiliateCode,
  });
}

class Address {
  final String id;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $state $zipCode, $country';
}
