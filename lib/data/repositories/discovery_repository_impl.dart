import '../../core/network/network_info.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/guide.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasource/discovery_remote_datasource.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DiscoveryRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<List<CollectionEntity>> getCollections() =>
      remoteDataSource.getCollections();

  @override
  Future<CollectionEntity?> getCollectionDetail(String slug) =>
      remoteDataSource.getCollectionDetail(slug);

  @override
  Future<List<GuideEntity>> getGuides() => remoteDataSource.getGuides();

  @override
  Future<GuideEntity?> getGuideDetail(String slug) =>
      remoteDataSource.getGuideDetail(slug);

  @override
  Future<SearchSuggestionsResult> getSuggestions(String query) =>
      remoteDataSource.getSuggestions(query);

  @override
  Future<List<String>> getPopularSearches() =>
      remoteDataSource.getPopularSearches();

  @override
  Future<void> trackEvent({
    required String eventType,
    String? productId,
    String? clientId,
    Map<String, dynamic> payload = const {},
  }) =>
      remoteDataSource.trackEvent(
        eventType: eventType,
        productId: productId,
        clientId: clientId,
        payload: payload,
      );

  @override
  Future<bool> submitContact({
    required String name,
    required String email,
    String? subject,
    required String message,
  }) =>
      remoteDataSource.submitContact(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
}