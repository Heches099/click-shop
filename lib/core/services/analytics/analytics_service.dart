import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logPurchase({
    required String orderId,
    required double amount,
    String currency = 'USD',
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      value: amount,
      currency: currency,
    );
  }

  Future<void> logAdClick(String adUnitId) async {
    await _analytics.logEvent(
      name: 'ad_click',
      parameters: {'ad_unit_id': adUnitId},
    );
  }
}
