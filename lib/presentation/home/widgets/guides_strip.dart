import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../discover/providers/discover_provider.dart';
import 'section_header.dart';

/// Home rail advertising buying guides — honest, stay-and-read editorial.
class GuidesStrip extends ConsumerWidget {
  const GuidesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guides = ref.watch(guidesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Buying guides',
          onSeeAll: () => _openGuides(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: guides.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
            data: (items) => items.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final g = items[i];
                      return GestureDetector(
                        onTap: () => _openGuide(context, g.slug),
                        child: Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (g.image.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    g.image,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 52,
                                      height: 52,
                                      color: AppColors.background,
                                      child: const Icon(
                                          Icons.menu_book_outlined,
                                          color: AppColors.textMuted),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.menu_book_outlined,
                                      color: AppColors.textMuted),
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      g.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      g.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
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

  void _openGuides(BuildContext context) {
    context.push('/guides');
  }

  void _openGuide(BuildContext context, String slug) {
    context.push('/guides/$slug');
  }
}