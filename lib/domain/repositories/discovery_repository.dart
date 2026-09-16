import '../entities/collection.dart';
import '../entities/guide.dart';
import '../entities/search_suggestion.dart';

abstract class DiscoveryRepository {
  Future<List<CollectionEntity>> getCollections();
  Future<CollectionEntity?> getCollectionDetail(String slug);
  Future<List<GuideEntity>> getGuides();
  Future<GuideEntity?> getGuideDetail(String slug);
  Future<SearchSuggestionsResult> getSuggestions(String query);
  Future<List<String>> getPopularSearches();
  Future<void> trackEvent({
    required String eventType,
    String? productId,
    String? clientId,
    Map<String, dynamic> payload,
  });
  Future<bool> submitContact({
    required String name,
    required String email,
    String? subject,
    required String message,
  });
}