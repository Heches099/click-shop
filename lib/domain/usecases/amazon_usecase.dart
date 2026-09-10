import '../entities/amazon_product.dart';
import '../repositories/amazon_repository.dart';

/// ---------------------------------------------------------------------------
/// AMAZON ASSOCIATES TEST INTEGRATION
/// Use case for fetching Amazon products. Thin pass-through following
/// the existing ProductUseCase pattern.
/// ---------------------------------------------------------------------------

class AmazonUseCase {
  final AmazonRepository repository;

  AmazonUseCase(this.repository);

  /// Curated affiliate destination categories (link mode — active now).
  Future<List<AmazonAffiliateCategory>> getAffiliateCategories() {
    return repository.getAffiliateCategories();
  }

  Future<List<AmazonProduct>> searchProducts({
    String query = 'gaming',
    String category = 'gaming',
    int limit = 20,
  }) {
    return repository.searchProducts(
      query: query,
      category: category,
      limit: limit,
    );
  }

  Future<AmazonProduct?> getProductByAsin(String asin) {
    return repository.getProductByAsin(asin);
  }
}
