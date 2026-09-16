import 'product.dart';

/// Owner-only, read-only analytics summary (`/admin/analytics/summary`).
/// Shows honest signals: what customers searched, what they viewed, and the
/// funnel between those stages — no fabricated numbers.
class AdminAnalytics {
  final int days;
  final List<({String query, int count})> topSearches;
  final List<({String productId, String name, int views})> topProductViews;
  final AdminFunnel funnel;

  const AdminAnalytics({
    this.days = 30,
    this.topSearches = const [],
    this.topProductViews = const [],
    this.funnel = const AdminFunnel(),
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    final rawSearches = json['topSearches'];
    final rawViews = json['topProductViews'];
    final rawFunnel = json['funnel'];
    return AdminAnalytics(
      days: (json['days'] as num?)?.toInt() ?? 30,
      topSearches: rawSearches is List
          ? rawSearches
              .whereType<Map>()
              .map((e) {
                final m = e.cast<String, dynamic>();
                return (
                  query: m['query'] as String? ?? '',
                  count: (m['count'] as num?)?.toInt() ?? 0,
                );
              })
              .toList()
          : const [],
      topProductViews: rawViews is List
          ? rawViews
              .whereType<Map>()
              .map((e) {
                final m = e.cast<String, dynamic>();
                return (
                  productId: m['productId'] as String? ?? '',
                  name: m['name'] as String? ?? '',
                  views: (m['views'] as num?)?.toInt() ?? 0,
                );
              })
              .toList()
          : const [],
      funnel: rawFunnel is Map
          ? AdminFunnel.fromJson(rawFunnel.cast<String, dynamic>())
          : const AdminFunnel(),
    );
  }
}

class AdminFunnel {
  final int viewProduct;
  final int addToCart;
  final int beginCheckout;
  final int purchase;
  final int saveProduct;
  final int addToCompare;
  final int affiliateClick;
  final int search;

  const AdminFunnel({
    this.viewProduct = 0,
    this.addToCart = 0,
    this.beginCheckout = 0,
    this.purchase = 0,
    this.saveProduct = 0,
    this.addToCompare = 0,
    this.affiliateClick = 0,
    this.search = 0,
  });

  factory AdminFunnel.fromJson(Map<String, dynamic> json) {
    return AdminFunnel(
      viewProduct: (json['viewProduct'] as num?)?.toInt() ?? 0,
      addToCart: (json['addToCart'] as num?)?.toInt() ?? 0,
      beginCheckout: (json['beginCheckout'] as num?)?.toInt() ?? 0,
      purchase: (json['purchase'] as num?)?.toInt() ?? 0,
      saveProduct: (json['saveProduct'] as num?)?.toInt() ?? 0,
      addToCompare: (json['addToCompare'] as num?)?.toInt() ?? 0,
      affiliateClick: (json['affiliateClick'] as num?)?.toInt() ?? 0,
      search: (json['search'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Owner dashboard overview (admin.stats). Mirrors the backend fields exactly.
class AdminStats {
  final double revenue;
  final int orderCount;
  final int productCount;
  final int userCount;
  final int lowStockCount;
  final int salesToday;

  const AdminStats({
    this.revenue = 0,
    this.orderCount = 0,
    this.productCount = 0,
    this.userCount = 0,
    this.lowStockCount = 0,
    this.salesToday = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orderCount: (json['orders'] as num?)?.toInt() ?? 0,
      productCount: (json['products'] as num?)?.toInt() ?? 0,
      userCount: (json['users'] as num?)?.toInt() ?? 0,
      lowStockCount: (json['lowStock'] as num?)?.toInt() ?? 0,
      salesToday: (json['salesToday'] as num?)?.toInt() ?? 0,
    );
  }
}

typedef RelatedProducts = ({
  List<Product> similar,
  List<Product> cheaper,
  List<Product> higherEnd,
  List<Product> complementary,
});