import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../home/widgets/product_card.dart';
import '../providers/discover_provider.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final String slug;
  const CollectionDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(collectionDetailProvider(slug));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Collection', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
            child: Text('Could not load this collection.',
                style: AppTypography.bodyMedium)),
        data: (collection) {
          if (collection == null) {
            return const Center(
                child: Text('Collection not found.',
                    style: AppTypography.bodyMedium));
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              if (collection.image.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    collection.image,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 170,
                      color: AppColors.surface,
                      child: const Icon(Icons.collections_outlined,
                          color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Text(collection.name, style: AppTypography.titleMedium),
              if (collection.tag.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    collection.tag,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                collection.description,
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.l),
              Text('${collection.products.length} products',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              ...collection.products.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PremiumProductCard(product: p),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}