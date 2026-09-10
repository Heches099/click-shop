import '../../../domain/entities/amazon_product.dart';

/// Abstract repository for Amazon data.
abstract class AmazonRepository {
  /// Curated affiliate destination categories (link mode — active now).
  Future<List<AmazonAffiliateCategory>> getAffiliateCategories();

  Future<List<AmazonProduct>> searchProducts({
    String query = 'gaming',
    String category = 'gaming',
    int limit = 20,
  });

  Future<AmazonProduct?> getProductByAsin(String asin);
}
