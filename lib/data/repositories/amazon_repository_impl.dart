import '../../domain/entities/amazon_product.dart';
import '../../domain/repositories/amazon_repository.dart';
import '../datasource/amazon_remote_datasource.dart';

/// ---------------------------------------------------------------------------
/// AMAZON ASSOCIATES TEST INTEGRATION
/// Repository implementation bridging the remote Amazon datasource
/// to the domain layer. No local caching — products come live from
/// the backend which calls Amazon PA-API.
/// ---------------------------------------------------------------------------

class AmazonRepositoryImpl implements AmazonRepository {
  final AmazonRemoteDataSource remoteDataSource;

  AmazonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AmazonAffiliateCategory>> getAffiliateCategories() {
    return remoteDataSource.getAffiliateCategories();
  }

  @override
  Future<List<AmazonProduct>> searchProducts({
    String query = 'gaming',
    String category = 'gaming',
    int limit = 20,
  }) {
    return remoteDataSource.searchProducts(
      query: query,
      category: category,
      limit: limit,
    );
  }

  @override
  Future<AmazonProduct?> getProductByAsin(String asin) {
    return remoteDataSource.getProductByAsin(asin);
  }
}
