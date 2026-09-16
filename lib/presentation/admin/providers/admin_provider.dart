import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/admin_analytics.dart';
import '../../../domain/entities/audit_entry.dart';
import '../../../domain/entities/contact_message.dart';
import '../../../domain/usecases/admin_usecase.dart';

final adminUseCaseProvider = Provider<AdminUseCase>((ref) {
  return sl<AdminUseCase>();
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return ref.watch(adminUseCaseProvider).getStats();
});

final adminAnalyticsProvider = FutureProvider<AdminAnalytics>((ref) async {
  return ref.watch(adminUseCaseProvider).getAnalytics(days: 30);
});

final adminAuditProvider = FutureProvider<List<AuditEntry>>((ref) async {
  return ref.watch(adminUseCaseProvider).getAuditLog(limit: 50);
});

final adminMessagesProvider =
    AsyncNotifierProvider<AdminMessagesNotifier, List<ContactMessageEntity>>(
        AdminMessagesNotifier.new);

class AdminMessagesNotifier extends AsyncNotifier<List<ContactMessageEntity>> {
  @override
  Future<List<ContactMessageEntity>> build() {
    return sl<AdminUseCase>().getContactMessages();
  }

  Future<void> markRead(String id) async {
    final current = state.asData?.value ?? const <ContactMessageEntity>[];
    // Optimistic local update — flip read state immediately.
    state = AsyncData([
      for (final m in current)
        if (m.id == id)
          ContactMessageEntity(
            id: m.id,
            name: m.name,
            email: m.email,
            subject: m.subject,
            message: m.message,
            isRead: true,
            createdAt: m.createdAt,
          )
        else
          m,
    ]);
    try {
      await sl<AdminUseCase>().markContactRead(id);
    } catch (_) {
      // Revert only if the server disagreed.
      if (state.asData?.value != null) {
        state = AsyncData([
          for (final m in current)
            if (m.id == id)
              ContactMessageEntity(
                id: m.id,
                name: m.name,
                email: m.email,
                subject: m.subject,
                message: m.message,
                isRead: m.isRead,
                createdAt: m.createdAt,
              )
            else
              m,
        ]);
      }
    }
  }
}