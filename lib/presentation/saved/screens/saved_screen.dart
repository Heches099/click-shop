import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/constants/amazon_affiliate.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../core/widgets/smart_image.dart';
import '../../home/providers/home_provider.dart';
import '../providers/saved_provider.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedProvider);
    final saved = savedAsync.asData?.value ?? const <AmazonProduct>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Saved for later', style: AppTypography.h2),
        actions: [
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined,
                    color: AppColors.error),
                onPressed: () => _showClearDialog(context, ref),
              ),
            ),
        ],
      ),
      body: savedAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
              ? _buildEmptyState(context, ref)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: saved.length,
                  itemBuilder: (context, index) => FadeInRight(
                    delay: Duration(milliseconds: 80 * index),
                    child: _buildSavedItem(context, ref, saved[index]),
                  ),
                ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear saved items?'),
        content: const Text('Are you sure you want to remove all saved items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppShadows.soft,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 80, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 32),
          const FadeInUp(
            child: Text('Nothing saved yet', style: AppTypography.h2),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
                'Tap the bookmark on any Amazon product\nto save it here for later.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(mainTabIndexProvider.notifier).state = 1,
                    child: const Text('Browse products'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () =>
                        openExternalLink(kAmazonAffiliateFallbackUrl),
                    child: const Text('Amazon'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItem(
      BuildContext context, WidgetRef ref, AmazonProduct product) {
    final thumb = AppResponsive.thumbnailSize(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.push('/product/${product.toProduct().id}',
                  extra: product.toProduct()),
              child: product.images.isNotEmpty
                  ? SmartImage(
                      imagePath: product.images.first,
                      width: thumb,
                      height: thumb,
                      borderRadius: BorderRadius.circular(18),
                    )
                  : Container(
                      width: thumb,
                      height: thumb,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppColors.border),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelMedium
                                .copyWith(fontSize: 11)),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(savedProvider.notifier).toggle(product),
                        child: const Icon(Icons.bookmark_rounded,
                            size: 22, color: Color(0xFFFF9900)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/product/${product.toProduct().id}',
                            extra: product.toProduct()),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (product.rating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFF9900), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => openExternalLink(product.amazonUrl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Buy on Amazon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}