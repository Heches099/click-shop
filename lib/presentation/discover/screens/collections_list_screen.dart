import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../providers/discover_provider.dart';
import 'collection_detail_screen.dart';

/// Honest, curated groupings of real products. Titles say what the shopper
/// actually gets — never "salesy" urgency.
class CollectionsListScreen extends ConsumerWidget {
  const CollectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Collections', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const _Error(),
        data: (items) => items.isEmpty
            ? const _Empty()
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final c = items[i];
                  return Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CollectionDetailScreen(slug: c.slug),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.image.isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  c.image,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    color: AppColors.background,
                                    child: const Icon(
                                        Icons.collections_outlined,
                                        color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Text(c.name,
                                      style: AppTypography.titleMedium),
                                ),
                                if (c.tag.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      c.tag,
                                      style: AppTypography.caption.copyWith(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textMuted),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.description,
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${c.productCount} products',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.accent),
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
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Center(
        child: Text('No collections yet', style: AppTypography.bodyMedium),
      );
}

class _Error extends StatelessWidget {
  const _Error();
  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Could not load collections.',
            style: AppTypography.bodyMedium),
      );
}