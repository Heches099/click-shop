import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';

abstract class PaymentService {
  Future<bool> processPayment({
    required double amount,
    required String currency,
  });
}

class StripePaymentService implements PaymentService {
  final Dio _dio = Dio();
  
  // Replace with your real Stripe Secret Key (Server-side)
  // NEVER keep this in the client app in a real production environment.
  // Use a Firebase Cloud Function to create PaymentIntents.
  static const String _secretKey = 'sk_test_...';
  
  static const String _publishableKey = 'pk_test_...';

  StripePaymentService() {
    Stripe.publishableKey = _publishableKey;
  }

  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      // 1. Create PaymentIntent (This should ideally happen on your backend)
      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': (amount * 100).toInt().toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final paymentIntent = response.data;

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Click Shop',
          style: ThemeMode.light,
        ),
      );

      // 3. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      debugPrint('Stripe Error: $e');
      return false;
    }
  }
}

/// A mock payment service for testing.
class MockPaymentService implements PaymentService {
  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
