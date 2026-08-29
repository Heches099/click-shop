import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';

abstract class PaymentService {
  Future<bool> processPayment({
    required double amount,
    required String currency,
  });
}

class StripePaymentService implements PaymentService {
  final Dio _dio = Dio();

  StripePaymentService() {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
  }

  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      // In production, create the PaymentIntent on your backend
      // (e.g. a Firebase Cloud Function) so the secret key never ships
      // in the client app.
      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': (amount * 100).toInt().toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.stripeSecretKey}',
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
