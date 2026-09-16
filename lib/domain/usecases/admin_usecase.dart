import '../entities/admin_analytics.dart';
import '../entities/audit_entry.dart';
import '../entities/collection.dart';
import '../entities/contact_message.dart';
import '../entities/guide.dart';
import '../entities/order.dart';
import '../repositories/admin_repository.dart';

class AdminUseCase {
  final AdminRepository repository;
  AdminUseCase(this.repository);

  Future<AdminStats> getStats() => repository.getStats();
  Future<AdminAnalytics> getAnalytics({int days = 30}) =>
      repository.getAnalyticsSummary(days: days);
  Future<List<ContactMessageEntity>> getContactMessages() =>
      repository.getContactMessages();
  Future<ContactMessageEntity?> markContactRead(String id) =>
      repository.markContactRead(id);
  Future<List<AuditEntry>> getAuditLog({int limit = 100}) =>
      repository.getAuditLog(limit: limit);
  Future<List<CollectionEntity>> getCollections() => repository.getCollections();
  Future<List<GuideEntity>> getGuides() => repository.getGuides();
  Future<List<OrderEntity>> getOrders() => repository.getOrders();
}