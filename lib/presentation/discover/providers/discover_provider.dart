import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/collection.dart';
import '../../../domain/entities/guide.dart';
import '../../../domain/entities/search_suggestion.dart';
import '../../../domain/usecases/discovery_usecase.dart';

final discoveryUseCaseProvider = Provider<DiscoveryUseCase>((ref) {
  return sl<DiscoveryUseCase>();
});

final collectionsProvider = FutureProvider<List<CollectionEntity>>((ref) async {
  return ref.watch(discoveryUseCaseProvider).getCollections();
});

final guidesProvider = FutureProvider<List<GuideEntity>>((ref) async {
  return ref.watch(discoveryUseCaseProvider).getGuides();
});

final popularSearchesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(discoveryUseCaseProvider).getPopularSearches();
});

/// Debounced autocomplete suggestions for a query.
final searchSuggestionsProvider =
    FutureProvider.autoDispose.family<SearchSuggestionsResult, String>(
        (ref, query) async {
  final q = query.trim();
  if (q.length < 2) {
    return const SearchSuggestionsResult();
  }
  await Future<void>.delayed(const Duration(milliseconds: 120));
  return ref.watch(discoveryUseCaseProvider).getSuggestions(q);
});

final collectionDetailProvider = FutureProvider.autoDispose
    .family<CollectionEntity?, String>((ref, slug) async {
  return ref.watch(discoveryUseCaseProvider).getCollectionDetail(slug);
});

final guideDetailProvider =
    FutureProvider.autoDispose.family<GuideEntity?, String>((ref, slug) async {
  return ref.watch(discoveryUseCaseProvider).getGuideDetail(slug);
});