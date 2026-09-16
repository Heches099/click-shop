import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Address;
import '../../constants/app_constants.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';
import '../service_locator.dart';

abstract class PaymentService {
  Future<bool> processPayment({
    required double amount,
    required String currency,
  });

  /// Creates the order server-side, opens the Stripe payment sheet and returns
  /// the result. When Stripe is not configured the backend returns a mock
  /// client secret, which is treated as a successful (dev mode) purchase.
  Future<PaymentResult> processCheckout({
    required List<CartItem> items,
    required Address shippingAddress,
    String? refCode,
    String paymentMethod = 'card',
  });
}

class PaymentResult {
  final bool success;
  final OrderEntity? order;
  final String? error;

  const PaymentResult.success(this.order)
      : success = true,
        error = null;
  const PaymentResult.failure(this.error)
      : success = false,
        order = null;
}

class StripePaymentService implements PaymentService {
  StripePaymentService() {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
  }

  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
  }) async {
    debugPrint('Payment unavailable: use processCheckout() for the full flow.');
    return false;
  }

  @override
  Future<PaymentResult> processCheckout({
    required List<CartItem> items,
    required Address shippingAddress,
    String? refCode,
    String paymentMethod = 'card',
  }) async {
    // 1. Create the order on the backend (stock is checked/decremented there
    //    and affiliate commissions are attributed server-side).
    final orderResult = await sl<OrderRepository>().createOrder(
      items: items,
      shippingAddress: shippingAddress,
      refCode: refCode,
      paymentMethod: paymentMethod,
    );
    final order = orderResult.fold((failure) => null, (o) => o);
    if (order == null) {
      return PaymentResult.failure(
          'We could not place your order. Please try again.');
    }

    // 2. Create a Stripe PaymentIntent for this order.
    String? clientSecret;
    try {
      final intentResponse =
          await sl<Dio>().post('/payments/create-intent', data: {'order_id': order.id});
      final data = intentResponse.data is Map
          ? (intentResponse.data as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      clientSecret = data['client_secret'] as String?;
    } catch (_) {
      return PaymentResult.failure('Payment could not be started.');
    }

    if (clientSecret == null || clientSecret.isEmpty) {
      return PaymentResult.failure('Payment could not be started.');
    }

    // 3. Dev fallback: the backend returns a mock secret when Stripe is not
    //    configured. Treat it as a successful simulated payment.
    if (clientSecret.startsWith('mock_')) {
      return PaymentResult.success(order);
    }

    // 4. Real Stripe payment sheet.
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: AppConstants.appName,
          paymentIntentClientSecret: clientSecret,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return PaymentResult.success(order);
    } on StripeException catch (e) {
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed. Please try again.',
      );
    } catch (_) {
      return PaymentResult.failure('Payment failed. Please try again.');
    }
  }
}