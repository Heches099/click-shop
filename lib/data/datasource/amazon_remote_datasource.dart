import '../../../core/network/dio_client.dart';
import '../../../domain/entities/amazon_product.dart';

/// ---------------------------------------------------------------------------
/// AMAZON ASSOCIATES INTEGRATION
/// Remote data source for Amazon data via the ClickShop backend.
/// The browser NEVER talks to Amazon directly — it only talks to the
/// backend, and the backend owns all Affiliate URL generation.
///
/// Tracking ID: clickshop03b-20
/// ---------------------------------------------------------------------------

abstract class AmazonRemoteDataSource {
  /// Curated affiliate destination categories (link mode — always available).
  Future<List<AmazonAffiliateCategory>> getAffiliateCategories();

  /// Search Amazon products via the backend endpoint.
  /// Returns [] while Amazon API access is disabled/ineligible.
  Future<List<AmazonProduct>> searchProducts({
    String query = 'gaming',
    String category = 'gaming',
    int limit = 20,
  });

  /// Fetch a single Amazon product by ASIN.
  Future<AmazonProduct?> getProductByAsin(String asin);
}

class AmazonRemoteDataSourceImpl implements AmazonRemoteDataSource {
  final DioClient dioClient;

  AmazonRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<AmazonAffiliateCategory>> getAffiliateCategories() async {
    final response = await dioClient.dio.get('/amazon/categories');

    final data = response.data;
    final items = data is List ? data : <dynamic>[];
    return items
        .map((json) => AmazonAffiliateCategory.fromJson(
            json is Map<String, dynamic> ? json : <String, dynamic>{}))
        .toList();
  }

  @override
  Future<List<AmazonProduct>> searchProducts({
    String query = 'gaming',
    String category = 'gaming',
    int limit = 20,
  }) async {
    final response = await dioClient.dio.get(
      '/amazon/products',
      queryParameters: {'q': query, 'category': category, 'limit': limit},
    );

    final data = response.data;
    final items = data is List ? data : <dynamic>[];
    return items
        .map((json) => AmazonProduct.fromJson(
            json is Map<String, dynamic> ? json : <String, dynamic>{}))
        .toList();
  }

  @override
  Future<AmazonProduct?> getProductByAsin(String asin) async {
    try {
      final response = await dioClient.dio.get('/amazon/products/$asin');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AmazonProduct.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
