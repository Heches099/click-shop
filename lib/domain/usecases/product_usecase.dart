import '../entities/product.dart';
import '../entities/category.dart';
import '../repositories/product_repository.dart';

class ProductUseCase {
  final ProductRepository repository;

  ProductUseCase(this.repository);

  Future<List<Product>> getProducts() => repository.getProducts();

  Future<Product> getProductById(String id) => repository.getProductById(id);

  Future<List<Product>> getProductsByCategory(String categoryId) =>
      repository.getProductsByCategory(categoryId);

  Future<List<Product>> getFeaturedProducts() => repository.getFeaturedProducts();

  Future<List<CategoryEntity>> getCategories() => repository.getCategories();
}
