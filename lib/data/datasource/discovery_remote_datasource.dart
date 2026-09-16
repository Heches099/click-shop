import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/guide.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../data/models/product_model.dart';

/// Public, credential-free dataset that powers Discoverable shopping:
/// curated collections, buying guides, autocomplete/popular search, the
/// funnel analytics sink and the contact form.
abstract class DiscoveryRemoteDataSource {
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

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final DioClient dioClient;
  DiscoveryRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<CollectionEntity>> getCollections() async {
    final response = await dioClient.dio.get('/content/collections');
    return _list(response.data, CollectionEntity.fromJson);
  }

  @override
  Future<CollectionEntity?> getCollectionDetail(String slug) async {
    try {
      final response = await dioClient.dio.get('/content/collections/$slug');
      final data = _obj(response.data);
      final rawProducts = data['products'] is List
          ? data['products'] as List
          : const <dynamic>[];
      final products = rawProducts
          .whereType<Map>()
          .map((e) => ProductModel.fromJson(e.cast<String, dynamic>()).toEntity())
          .toList();
      return CollectionEntity(
        id: data['id'] as String? ?? '',
        slug: data['slug'] as String? ?? '',
        name: data['name'] as String? ?? '',
        description: data['description'] as String? ?? '',
        tag: data['tag'] as String? ?? '',
        image: data['image'] as String? ?? '',
        productCount: (data['productCount'] as num?)?.toInt() ?? products.length,
        products: products,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<GuideEntity>> getGuides() async {
    final response = await dioClient.dio.get('/content/guides');
    return _list(response.data, GuideEntity.fromJson);
  }

  @override
  Future<GuideEntity?> getGuideDetail(String slug) async {
    try {
      final response = await dioClient.dio.get('/content/guides/$slug');
      return GuideEntity.fromJson(_obj(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<SearchSuggestionsResult> getSuggestions(String query) async {
    final response = await dioClient.dio
        .get('/search/suggest', queryParameters: {'q': query});
    return SearchSuggestionsResult.fromJson(_obj(response.data));
  }

  @override
  Future<List<String>> getPopularSearches() async {
    final response = await dioClient.dio.get('/search/popular');
    final data = response.data;
    if (data is List) return data.cast<String>();
    return const [];
  }

  @override
  Future<void> trackEvent({
    required String eventType,
    String? productId,
    String? clientId,
    Map<String, dynamic> payload = const {},
  }) async {
    // Fire-and-forget sink: never block the UI on analytics.
    try {
      await dioClient.dio.post('/analytics/events', data: {
        'event_type': eventType,
        'product_id': productId,
        'client_id': clientId,
        'payload': payload,
      });
    } on DioException {
      // Silent drop — analytics must never interrupt shopping.
    }
  }

  @override
  Future<bool> submitContact({
    required String name,
    required String email,
    String? subject,
    required String message,
  }) async {
    try {
      await dioClient.dio.post('/contact', data: {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      });
      return true;
    } on DioException {
      return false;
    }
  }

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final raw = data is List ? data : const [];
    return raw
        .whereType<Map>()
        .map((e) => fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Map<String, dynamic> _obj(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.cast<String, dynamic>();
    throw const FormatException('Expected a JSON object');
  }
}