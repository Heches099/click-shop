import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../discover/providers/discover_provider.dart';
import 'section_header.dart';

/// Horizontal rail of curated collections on the home page.
class CollectionsStrip extends ConsumerWidget {
  const CollectionsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Curated collections',
          onSeeAll: () => context.push('/collections'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: collections.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (items) => items.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final c = items[i];
                      return GestureDetector(
                        onTap: () => context.push('/collections/${c.slug}'),
                        child: Container(
                          width: 240,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (c.image.isNotEmpty)
                                Image.network(
                                  c.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.collections_outlined,
                                        color: AppColors.textMuted),
                                  ),
                                )
                              else
                                Container(
                                  color: AppColors.surface,
                                  child: const Icon(Icons.collections_outlined,
                                      color: AppColors.textMuted),
                                ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black87,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${c.productCount} products',
                                        style: AppTypography.caption.copyWith(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}