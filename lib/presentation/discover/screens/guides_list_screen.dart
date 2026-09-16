import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../providers/discover_provider.dart';
import 'guide_detail_screen.dart';

/// Buying guides: long-form, human-written editorial that helps someone decide.
/// No "best" rankings, no urgency, no fabricated winners.
class GuidesListScreen extends ConsumerWidget {
  const GuidesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guides = ref.watch(guidesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Buying Guides', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: guides.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
            child: Text('Could not load guides.',
                style: AppTypography.bodyMedium)),
        data: (items) => items.isEmpty
            ? const Center(
                child:
                    Text('No guides published yet', style: AppTypography.bodyMedium))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final g = items[i];
                  return Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuideDetailScreen(slug: g.slug),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (g.image.isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  g.image,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 120,
                                    color: AppColors.background,
                                    child: const Icon(Icons.menu_book_outlined,
                                        color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text(g.title, style: AppTypography.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              g.summary,
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            if (g.publishedAt != null)
                              Text(
                                _date(g.publishedAt!),
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _date(DateTime d) => '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];
}