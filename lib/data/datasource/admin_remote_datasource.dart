import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/admin_analytics.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/contact_message.dart';
import '../../domain/entities/guide.dart';

/// Owner-only data (backend `/admin/*`). The client never decides the owner
/// role — the backend 403s these calls for non-owner JWTs.
abstract class AdminRemoteDataSource {
  Future<AdminStats> getStats();
  Future<AdminAnalytics> getAnalyticsSummary({int days});
  Future<List<ContactMessageEntity>> getContactMessages();
  Future<ContactMessageEntity?> markContactRead(String id);
  Future<List<AuditEntry>> getAuditLog({int limit});
  Future<List<CollectionEntity>> getCollections();
  Future<List<GuideEntity>> getGuides();
  Future<List<OrderModel>> getOrders();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient dioClient;
  AdminRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AdminStats> getStats() async {
    final response = await dioClient.dio.get('/admin/stats');
    return AdminStats.fromJson(_obj(response.data));
  }

  @override
  Future<AdminAnalytics> getAnalyticsSummary({int days = 30}) async {
    final response = await dioClient.dio
        .get('/admin/analytics/summary', queryParameters: {'days': days});
    return AdminAnalytics.fromJson(_obj(response.data));
  }

  @override
  Future<List<ContactMessageEntity>> getContactMessages() async {
    final response = await dioClient.dio.get('/admin/contact-messages');
    return _list(response.data, ContactMessageEntity.fromJson);
  }

  @override
  Future<ContactMessageEntity?> markContactRead(String id) async {
    try {
      final response = await dioClient.dio.patch('/admin/contact-messages/$id/read');
      return ContactMessageEntity.fromJson(_obj(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<AuditEntry>> getAuditLog({int limit = 100}) async {
    final response = await dioClient.dio
        .get('/admin/audit-log', queryParameters: {'limit': limit});
    return _list(response.data, AuditEntry.fromJson);
  }

  @override
  Future<List<CollectionEntity>> getCollections() async {
    final response = await dioClient.dio.get('/admin/collections');
    return _list(response.data, CollectionEntity.fromJson);
  }

  @override
  Future<List<GuideEntity>> getGuides() async {
    final response = await dioClient.dio.get('/admin/guides');
    return _list(response.data, GuideEntity.fromJson);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await dioClient.dio.get('/admin/orders');
    return _list(response.data, OrderModel.fromJson);
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