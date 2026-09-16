import '../entities/collection.dart';
import '../entities/guide.dart';
import '../entities/search_suggestion.dart';
import '../repositories/discovery_repository.dart';

class DiscoveryUseCase {
  final DiscoveryRepository repository;
  DiscoveryUseCase(this.repository);

  Future<List<CollectionEntity>> getCollections() =>
      repository.getCollections();

  Future<CollectionEntity?> getCollectionDetail(String slug) =>
      repository.getCollectionDetail(slug);

  Future<List<GuideEntity>> getGuides() => repository.getGuides();

  Future<GuideEntity?> getGuideDetail(String slug) =>
      repository.getGuideDetail(slug);

  Future<SearchSuggestionsResult> getSuggestions(String query) =>
      repository.getSuggestions(query);

  Future<List<String>> getPopularSearches() => repository.getPopularSearches();

  /// Honest, best-effort funnel event. Never blocks the UI.
  Future<void> trackEvent({
    required String eventType,
    String? productId,
    String? clientId,
    Map<String, dynamic> payload = const {},
  }) =>
      repository.trackEvent(
        eventType: eventType,
        productId: productId,
        clientId: clientId,
        payload: payload,
      );

  Future<bool> submitContact({
    required String name,
    required String email,
    String? subject,
    required String message,
  }) =>
      repository.submitContact(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
}