import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/seo/seo_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/product.dart';
import '../../home/providers/home_provider.dart';
import '../../home/widgets/product_card.dart';

/// SEO-friendly, deep-linkable category page served at `/category/:slug`.
///
/// The [slug] mirrors the category id (or name) and is used to filter the
/// product catalog. Because it uses clean declarative routing the page can be
/// refreshed, shared and indexed directly by search crawlers.
class CategoryDetailScreen extends ConsumerWidget {
  final String slug;

  const CategoryDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productsAsync.when(
        data: (products) {
          final filtered = _filterProducts(products);
          _syncSeoMeta(context, ref, filtered);
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, filtered),
              _buildProductGrid(context, filtered),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
        loading: () => _buildScaffold(
          context,
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
        error: (error, _) => _buildScaffold(
          context,
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  const Text('Unable to load products',
                      style: AppTypography.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(allProductsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/'),
        ),
        title: Text(_titleCase(slug), style: AppTypography.h2),
      ),
      body: CustomScrollView(slivers: [body]),
    );
  }

  Widget _buildAppBar(BuildContext context, List<Product> products) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppColors.background.withValues(alpha: 0.9),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titleCase(slug), style: AppTypography.h2),
            const SizedBox(height: 2),
            Text(
              '${products.length} products',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return SliverPadding(
      padding: EdgeInsets.all(AppResponsive.scale(context, 20)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppResponsive.gridColumns(context, minItemWidth: 150),
          mainAxisSpacing: AppResponsive.scale(context, 20),
          crossAxisSpacing: AppResponsive.scale(context, 20),
          childAspectRatio: AppResponsive.productCardRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => PremiumProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> all) {
    final normalizedSlug = slug.toLowerCase().replaceAll('-', ' ');
    return all.where((p) {
      if (normalizedSlug == 'all') return true;
      return p.category.toLowerCase() == normalizedSlug ||
          p.category.toLowerCase().replaceAll('-', ' ') == normalizedSlug;
    }).toList();
  }

  void _syncSeoMeta(BuildContext context, WidgetRef ref, List<Product> products) {
    SeoService.instance.setPageMeta(
      title: '${_titleCase(slug)} — ClickShop',
      description:
          'Shop the best ${_titleCase(slug)} at ClickShop. '
          '${products.length} hand-picked items with fast delivery and great prices.',
      canonicalPath: '/category/$slug',
    );
    if (products.isNotEmpty) {
      SeoService.instance.injectCollectionPage(
          products, canonicalPath: '/category/$slug');
    }
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'[-_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
