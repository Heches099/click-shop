import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../domain/entities/admin_analytics.dart';
import '../../../domain/entities/audit_entry.dart';
import '../../../domain/entities/contact_message.dart';
import '../providers/admin_provider.dart';

/// Owner-only dashboard. Every number comes straight from the backend
/// `/admin/*` endpoints — the client never invents analytics. Non-owners are
/// rejected by the API itself (403), so this screen simply shows errors.
class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final analytics = ref.watch(adminAnalyticsProvider);
    final messages = ref.watch(adminMessagesProvider);
    final audit = ref.watch(adminAuditProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Owner dashboard', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _statsSection(stats),
          const SizedBox(height: 16),
          _analyticsSection(context, analytics),
          const SizedBox(height: 16),
          _messagesSection(context, ref, messages),
          const SizedBox(height: 16),
          _auditSection(audit),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statsSection(AsyncValue<AdminStats> stats) =>
      _asyncOr<AdminStats>(stats, 'Store stats unavailable',
          (data) => _StatCards(stats: data), dense: false);

  Widget _analyticsSection(
      BuildContext context, AsyncValue<AdminAnalytics> analytics) {
    return _asyncOr<AdminAnalytics>(
      analytics,
      'Analytics unavailable',
      (data) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shopper behaviour (30 days)',
                  style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              const Text(
                'Anonymous counts of genuine product interest. '
                'Reviews & popularity are never fabricated.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 12),
              _funnelRow(data.funnel),
              if (data.topSearches.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Top searches', style: AppTypography.titleLarge),
                const SizedBox(height: 6),
                for (final s in data.topSearches)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('${s.query} — ${s.count}',
                        style: AppTypography.bodyMedium),
                  ),
              ],
              if (data.topProductViews.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Most viewed products (aggregate)',
                    style: AppTypography.titleLarge),
                const SizedBox(height: 6),
                for (final v in data.topProductViews)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          onPressed: () {
                            context.push('/product/${v.productId}');
                          },
                        ),
                        Expanded(
                          child: Text('${v.name} — ${v.views}',
                              style: AppTypography.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _funnelRow(AdminFunnel funnel) {
    Widget cell(String label, int value) => Expanded(
          child: Column(
            children: [
              Text('$value',
                  style: AppTypography.h2.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.caption),
            ],
          ),
        );
    return Row(
      children: [
        cell('Views', funnel.viewProduct),
        cell('Carts', funnel.addToCart),
        cell('Checkouts', funnel.beginCheckout),
        cell('Purchases', funnel.purchase),
      ],
    );
  }

  Widget _messagesSection(
      BuildContext context, WidgetRef ref, AsyncValue<List<ContactMessageEntity>> messages) {
    return _asyncOr<List<ContactMessageEntity>>(
      messages,
      'Inbox unavailable.',
      (items) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Contact inbox', style: AppTypography.titleMedium),
                  const SizedBox(width: 8),
                  if (items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${items.where((m) => !m.isRead).length} unread',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('No messages yet.', style: AppTypography.bodyMedium)
              else
                for (final m in items.take(5))
                  InkWell(
                    onTap: () async {
                      if (!m.isRead) {
                        await ref
                            .read(adminMessagesProvider.notifier)
                            .markRead(m.id);
                      }
                      if (!context.mounted) return;
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(m.subject ?? m.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From: ${m.name} <${m.email}>',
                                  style: AppTypography.caption),
                              const SizedBox(height: 8),
                              Text(m.message, style: AppTypography.bodyMedium),
                              const SizedBox(height: 8),
                              Text('Received ${m.createdAt?.toLocal()}',
                                  style: AppTypography.caption),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.subject ?? '(no subject)',
                                    style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600)),
                                Text('${m.name} · ${m.email}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption),
                              ],
                            ),
                          ),
                          if (!m.isRead)
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _auditSection(AsyncValue<List<AuditEntry>> audit) {
    return _asyncOr<List<AuditEntry>>(
      audit,
      'Audit log unavailable.',
      (entries) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Audit trail', style: AppTypography.titleMedium),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Text('No audit entries yet.', style: AppTypography.bodyMedium)
              else
                for (final e in entries.take(8))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_auditIcon(e.action), size: 15, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${e.createdAt?.toLocal()} · ${e.adminEmail} '
                            '${e.action} ${e.targetType}',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _asyncOr<T>(
    AsyncValue<T> state,
    String errorMessage,
    Widget Function(T data) builder, {
    bool dense = true,
  }) {
    return state.when(
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(errorMessage,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ),
      data: builder,
    );
  }

  IconData _auditIcon(String action) {
    switch (action) {
      case 'created':
        return Icons.add_circle_outline_rounded;
      case 'updated':
        return Icons.edit_outlined;
      case 'deleted':
        return Icons.delete_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }
}

class _StatCards extends StatelessWidget {
  final AdminStats stats;
  const _StatCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = <(String, String)>[
      ('Revenue', '\$${stats.revenue.toStringAsFixed(2)}'),
      ('Orders', '${stats.orderCount}'),
      ('Products', '${stats.productCount}'),
      ('Users', '${stats.userCount}'),
      ('Low stock', '${stats.lowStockCount}'),
      ('Sales today', '${stats.salesToday}'),
    ];
    return Column(
      children: [
        Row(
          children: [
            for (final c in cards.take(3)) _card(c.$1, c.$2),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final c in cards.skip(3)) _card(c.$1, c.$2),
          ],
        ),
      ],
    );
  }

  Widget _card(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTypography.h2.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}