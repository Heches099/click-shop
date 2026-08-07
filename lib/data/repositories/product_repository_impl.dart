import '../../core/network/network_info.dart';
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
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    // In a real app, we might pass categoryId to datasource
    final models = await remoteDataSource.getNewArrivals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.map((m) => m.toEntity()).toList();
  }
}
