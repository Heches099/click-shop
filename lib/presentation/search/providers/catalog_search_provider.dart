import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product_usecase.dart';

final _catalogUseCaseProvider = Provider<ProductUseCase>((ref) {
  return sl<ProductUseCase>();
});

/// Real backend catalog search (GET /products with filters). Used by both the
/// rewritten Search tab and the Help-Me-Choose flow so search results always
/// come from the server, never a client-side lie.
final catalogSearchProvider =
    FutureProvider.autoDispose
        .family<List<Product>, ({String query, double? minPrice, double? maxPrice})>(
      (ref, params) async {
        if (params.query.trim().isEmpty) return const [];
        return ref.watch(_catalogUseCaseProvider).search(
              q: params.query,
              minPrice: params.minPrice,
              maxPrice: params.maxPrice,
            );
      },
    );