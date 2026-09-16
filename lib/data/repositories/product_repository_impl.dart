import '../../core/network/network_info.dart';
import '../../domain/entities/admin_analytics.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_remote_datasource.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Product>> getFeaturedProducts() async {
    final models = await remoteDataSource.getFeaturedProducts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Product>> getProducts() async {
    final models = await remoteDataSource.getNewArrivals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final model = await remoteDataSource.getProductById(id);
    return model.toEntity();
  }

  @override
  Future<Product> getProductBySlug(String slug) async {
    final model = await remoteDataSource.getProductBySlug(slug);
    return model.toEntity();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categorySlug) async {
    final models =
        await remoteDataSource.getProductsByCategory(categorySlug);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Product>> searchProducts({
    String q = '',
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
  }) async {
    final models = await remoteDataSource.searchProducts(
      q: q,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      brands: brands,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RelatedProducts> getRelatedProducts(String productId) async {
    final result = await remoteDataSource.getRelatedProducts(productId);
    return (
      similar: result.similar.map((m) => m.toEntity()).toList(),
      cheaper: result.cheaper.map((m) => m.toEntity()).toList(),
      higherEnd: result.higherEnd.map((m) => m.toEntity()).toList(),
      complementary: result.complementary.map((m) => m.toEntity()).toList(),
    );
  }
}
