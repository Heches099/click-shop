import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product_usecase.dart';

final _catalogUseCaseProvider = Provider<ProductUseCase>((ref) {
  return sl<ProductUseCase>();
});

typedef CatalogSearchParams = ({
  String query,
  double? minPrice,
  double? maxPrice,
  String sort,
  List<String> brands,
});

/// Real backend catalog search (GET /products with filters). Used by both the
/// rewritten Search tab and the Help-Me-Choose flow so search results always
/// come from the server, never a client-side lie.
final catalogSearchProvider =
    FutureProvider.autoDispose
        .family<List<Product>, CatalogSearchParams>(
      (ref, params) async {
        if (params.query.trim().isEmpty) return const [];
        return ref.watch(_catalogUseCaseProvider).search(
              q: params.query,
              minPrice: params.minPrice,
              maxPrice: params.maxPrice,
              brands: params.brands.isEmpty ? null : params.brands,
            );
      },
    );

/// Applies client-side sort filtering on top of the server result set.
/// The backend already filters price/brand; sort is applied here so the UI
/// stays snappy without an extra network round trip per toggle.
List<Product> applyLocalFilters(
  List<Product> products,
  CatalogSearchParams params,
) {
  final sorted = List<Product>.of(products);
  switch (params.sort) {
    case 'Price: Low to High':
      sorted.sort((a, b) => a.price.compareTo(b.price));
    case 'Price: High to Low':
      sorted.sort((a, b) => b.price.compareTo(a.price));
    default:
      break;
  }
  return sorted;
}