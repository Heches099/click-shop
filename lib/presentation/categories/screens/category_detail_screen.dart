import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/seo/seo_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../../domain/entities/product.dart';
import '../../home/providers/amazon_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../home/widgets/product_card.dart';

/// SEO-friendly, deep-linkable category page served at `/category/:slug`.
///
/// The [slug] mirrors the category id (or name) and is used to filter the
/// product catalog (database products plus the curated Amazon catalog, which
/// share the same slug convention). Because it uses clean declarative routing
/// the page can be refreshed, shared and indexed directly by search crawlers.
class CategoryDetailScreen extends ConsumerWidget {
  final String slug;

  const CategoryDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(allProductsProvider);
    final amazonAsync = ref.watch(amazonAllProductsProvider);
    final dbProducts = dbAsync.value ?? const <Product>[];
    final amazonProducts = amazonAsync.value ?? const <AmazonProduct>[];
    final all = [
      ...dbProducts,
      ...amazonProducts.map((a) => a.toProduct()),
    ];
    final loading = dbAsync.isLoading && amazonAsync.isLoading;
    final failed = dbAsync.hasError &&
        amazonAsync.hasError &&
        dbProducts.isEmpty &&
        amazonProducts.isEmpty;

    if (failed) {
      return _buildScaffold(
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
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(allProductsProvider);
                    ref.invalidate(amazonAllProductsProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = _filterProducts(all);
    _syncSeoMeta(context, filtered);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, filtered),
                _buildProductGrid(context, filtered),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxl)),
              ],
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

  void _syncSeoMeta(BuildContext context, List<Product> products) {
    final title = _titleCase(slug);
    final sampleNames = products
        .take(4)
        .map((p) => p.name)
        .where((n) => n.isNotEmpty)
        .join(', ');
    final description = products.isEmpty
        ? 'Explore $title at ClickShop — curated picks with the best prices.'
        : 'Shop top $title picks at ClickShop: $sampleNames.';
    final canonicalPath = '/category/$slug';
    SeoService.instance.setPageMeta(
      title: '$title — ClickShop',
      description: description.length > 220
          ? description.substring(0, 220)
          : description,
      canonicalPath: canonicalPath,
      robots: 'index, follow',
      ogImage: products.isNotEmpty ? products.first.firstImage : null,
      ogType: 'website',
    );
    if (products.isNotEmpty) {
      SeoService.instance.injectCollectionPage(
          products, canonicalPath: canonicalPath);
    }
    SeoService.instance.injectBreadcrumbSchema([
      (name: 'Home', path: '/'),
      (name: title, path: canonicalPath),
    ]);
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'[-_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
