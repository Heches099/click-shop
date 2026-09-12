import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../../domain/usecases/amazon_usecase.dart';

/// ---------------------------------------------------------------------------
/// AMAZON ASSOCIATES INTEGRATION
/// Riverpod providers for Amazon data.
/// Tracks: clickshop03b-20
/// ---------------------------------------------------------------------------

/// Bridge: GetIt -> Riverpod
final amazonUseCaseProvider = Provider<AmazonUseCase>((ref) {
  return sl<AmazonUseCase>();
});

/// Curated affiliate destination categories (link mode — active now).
/// Always available; the backend builds the destination URLs server-side.
final amazonAffiliateCategoriesProvider =
    FutureProvider<List<AmazonAffiliateCategory>>((ref) async {
  final useCase = ref.watch(amazonUseCaseProvider);
  return useCase.getAffiliateCategories();
});

/// Fetches Amazon gaming products from the backend.
/// Returns an empty list while PA-API/Creators API access is disabled;
/// the UI shows no "live inventory" claim in that case.
final amazonGamingProductsProvider =
    FutureProvider<List<AmazonProduct>>((ref) async {
  final useCase = ref.watch(amazonUseCaseProvider);
  return useCase.searchProducts(
    query: 'gaming',
    category: 'gaming',
    limit: 20,
  );
});

/// The full curated Amazon catalog (all categories) used by the Search tab.
final amazonAllProductsProvider =
    FutureProvider<List<AmazonProduct>>((ref) async {
  final useCase = ref.watch(amazonUseCaseProvider);
  return useCase.searchProducts(
    query: '',
    category: '',
    limit: 50,
  );
});