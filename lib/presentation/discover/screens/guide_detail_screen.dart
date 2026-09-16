import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../providers/discover_provider.dart';
import '../widgets/markdown_body.dart';

class GuideDetailScreen extends ConsumerWidget {
  final String slug;
  const GuideDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guide = ref.watch(guideDetailProvider(slug));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Buying Guide', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: guide.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
            child: Text('Could not load this guide.',
                style: AppTypography.bodyMedium)),
        data: (g) {
          if (g == null) {
            return const Center(
                child: Text('Guide not found.', style: AppTypography.bodyMedium));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (g.image.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      g.image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: AppColors.surface,
                        child: const Icon(Icons.menu_book_outlined,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(g.title, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(
                  g.summary,
                  style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 20),
                if (g.body.isNotEmpty)
                  MarkdownBody(markdown: g.body)
                else
                  const Text('Guide body coming soon.',
                      style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}