import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../constants/app_constants.dart';

abstract class PaymentService {
  Future<bool> processPayment({
    required double amount,
    required String currency,
  });
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
    // No live checkout exists in the app: payment intents must be created
    // server-side (e.g. a backend/Cloud Function with the Stripe private key).
    // The Stripe secret key must never be shipped or used in a client app.
    debugPrint('Payment unavailable: no backend PaymentIntent endpoint configured.');
    return false;
  }
}
