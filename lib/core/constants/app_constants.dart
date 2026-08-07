class AppConstants {
  static const String appName = 'ShopEase';
  static const String baseUrl = 'https://api.example.com/v1';
  static const String tokenKey = 'auth_token';
  static const String userBox = 'userBox';
  static const String cartBox = 'cartBox';
  static const String wishlistBox = 'wishlistBox';
  static const String recentViewsBox = 'recentViewsBox';
  static const String affiliateBox = 'affiliateBox';

  /// Toggle this to false if you want to use local mock data (Hive) 
  /// instead of live Firestore data for testing.
  static const bool useRemoteDataSource = true;

  /// Public store URL used to build affiliate referral links.
  /// Replace with your deployed web/domain URL before going live.
  static const String storeBaseUrl = 'https://clickshop.example.com';

  /// Default affiliate commission rate (10% of each referred order).
  static const double affiliateCommissionRate = 0.10;
}
