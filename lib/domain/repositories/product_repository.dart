import '../entities/product.dart';
import '../entities/category.dart';
import '../entities/admin_analytics.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(String id);
  Future<Product> getProductBySlug(String slug);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> getFeaturedProducts();
  Future<List<CategoryEntity>> getCategories();
  Future<List<Product>> searchProducts({
    String q,
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
  });
  Future<RelatedProducts> getRelatedProducts(String productId);
}
