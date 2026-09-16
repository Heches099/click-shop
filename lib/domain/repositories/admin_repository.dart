import '../entities/admin_analytics.dart';
import '../entities/audit_entry.dart';
import '../entities/collection.dart';
import '../entities/contact_message.dart';
import '../entities/guide.dart';
import '../entities/order.dart';

abstract class AdminRepository {
  Future<AdminStats> getStats();
  Future<AdminAnalytics> getAnalyticsSummary({int days});
  Future<List<ContactMessageEntity>> getContactMessages();
  Future<ContactMessageEntity?> markContactRead(String id);
  Future<List<AuditEntry>> getAuditLog({int limit});
  Future<List<CollectionEntity>> getCollections();
  Future<List<GuideEntity>> getGuides();
  Future<List<OrderEntity>> getOrders();
}