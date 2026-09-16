import '../../core/network/network_info.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/admin_analytics.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/contact_message.dart';
import '../../domain/entities/guide.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasource/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<AdminStats> getStats() => remoteDataSource.getStats();

  @override
  Future<AdminAnalytics> getAnalyticsSummary({int days = 30}) =>
      remoteDataSource.getAnalyticsSummary(days: days);

  @override
  Future<List<ContactMessageEntity>> getContactMessages() =>
      remoteDataSource.getContactMessages();

  @override
  Future<ContactMessageEntity?> markContactRead(String id) =>
      remoteDataSource.markContactRead(id);

  @override
  Future<List<AuditEntry>> getAuditLog({int limit = 100}) =>
      remoteDataSource.getAuditLog(limit: limit);

  @override
  Future<List<CollectionEntity>> getCollections() =>
      remoteDataSource.getCollections();

  @override
  Future<List<GuideEntity>> getGuides() => remoteDataSource.getGuides();

  @override
  Future<List<OrderEntity>> getOrders() async {
    final models = await remoteDataSource.getOrders();
    return models.map((m) => m.toEntity()).toList();
  }
}