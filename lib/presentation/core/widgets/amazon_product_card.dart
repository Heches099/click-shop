import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/utils/open_link.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../saved/providers/saved_provider.dart';
import 'smart_image.dart';

class AmazonProductCard extends ConsumerWidget {
  final AmazonProduct amazonProduct;

  const AmazonProductCard({super.key, required this.amazonProduct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved =
        ref.watch(savedProvider).asData?.value ?? const <AmazonProduct>[];
    final isSaved = saved.any((p) => p.asin == amazonProduct.asin);
    final product = amazonProduct.toProduct();

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  amazonProduct.images.isNotEmpty
                      ? SmartImage(imagePath: amazonProduct.images.first)
                      : Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(Icons.shopping_bag_outlined,
                                size: 40, color: AppColors.border),
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _BookmarkButton(
                      isSaved: isSaved,
                      onPressed: () => ref
                          .read(savedProvider.notifier)
                          .toggle(amazonProduct),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    amazonProduct.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amazonProduct.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (amazonProduct.rating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFF9900), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${amazonProduct.rating}',
                          style: AppTypography.labelMedium.copyWith(
                              fontSize: 11),
                        ),
                        if (amazonProduct.reviewCount > 0) ...[
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '(${amazonProduct.reviewCount} reviews)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMedium.copyWith(
                                  fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => openExternalLink(amazonProduct.amazonUrl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Buy on Amazon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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

class _BookmarkButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onPressed;

  const _BookmarkButton({required this.isSaved, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 20,
          color: isSaved ? const Color(0xFFFF9900) : AppColors.textSecondary,
        ),
      ),
    );
  }
}