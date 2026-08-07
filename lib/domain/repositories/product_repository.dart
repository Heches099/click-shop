import '../entities/product.dart';
import '../entities/category.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(String id);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> getFeaturedProducts();
  Future<List<CategoryEntity>> getCategories();
}
