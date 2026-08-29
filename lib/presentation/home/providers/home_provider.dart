import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/product_usecase.dart';

final productUseCaseProvider = Provider<ProductUseCase>((ref) {
  return sl<ProductUseCase>();
});

// Shared product catalog used by the home grid, search and filters.
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = ref.watch(productUseCaseProvider);
  return useCase.getProducts();
});

// Active tab in the main scaffold (Home / Search / Bag / Profile).
final mainTabIndexProvider = StateProvider<int>((ref) => 0);

// Category State
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) {
  final useCase = ref.watch(productUseCaseProvider);
  return useCase.getCategories();
});

// Products fetching with filtering logic
final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final useCase = ref.watch(productUseCaseProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  final allProducts = await useCase.getProducts();

  if (selectedCategory == 'all') {
    return allProducts;
  }

  return allProducts
      .where((p) =>
          p.category.toLowerCase() == selectedCategory.toLowerCase())
      .toList();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  final useCase = ref.watch(productUseCaseProvider);
  return useCase.getFeaturedProducts();
});
