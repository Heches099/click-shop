class AppConstants {
  static const String appName = 'ClickShop';
  static const String baseUrl = 'https://api.example.com/v1';
  static const String tokenKey = 'auth_token';
  static const String userBox = 'userBox';
  static const String cartBox = 'cartBox';
  static const String wishlistBox = 'wishlistBox';
  static const String recentViewsBox = 'recentViewsBox';
  static const String affiliateBox = 'affiliateBox';

  /// Stripe publishable key (safe to include in the client).
  /// Replace with your real key before going live.
  static const String stripePublishableKey = 'pk_test_REPLACE_ME';

  /// Stripe secret key.
  /// NEVER ship this in a client app in production - create PaymentIntents
  /// on your backend (e.g. a Firebase Cloud Function) instead.
  static const String stripeSecretKey = 'sk_test_REPLACE_ME';

  /// Public store URL used to build affiliate referral links.
  /// Replace with your deployed web/domain URL before going live.
  static const String storeBaseUrl = 'https://clickshop.example.com';

  /// Default affiliate commission rate (10% of each referred order).
  static const double affiliateCommissionRate = 0.10;
}
