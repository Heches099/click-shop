import '../providers/home_provider.dart';
import '../../core/widgets/smart_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/ads/ad_config.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/affiliate_disclosure.dart';
import '../../../core/widgets/google_ad_banner.dart';
import '../../../domain/entities/product.dart';
import '../widgets/banner_slider.dart';
import '../widgets/product_card.dart';
import '../widgets/affiliate_promo_card.dart';
import '../widgets/amazon_gaming_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(ref),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: PremiumBannerSlider(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: AffiliatePromoCard(
                onTap: () => context.push('/affiliate'),
              ),
            ),
          ),
          // AMAZON ASSOCIATES TEST: Amazon Gaming products section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: AmazonGamingSection(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GoogleAdBanner(slotId: AdConfig.homeTopSlot),
            ),
          ),
          const SliverToBoxAdapter(child: AffiliateDisclosure()),
          _buildCategoryHeader('Shop by Category'),
          _buildCategoryList(ref),
          _buildCategoryHeader('Featured Products'),
          _buildProductGrid(context, ref, productsAsync, selectedCategory),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildAppBar(WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 70,
      backgroundColor: AppColors.background.withValues(alpha: 0.8),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Row(
          children: [
            // Text(
            //   'ClickShop',
            //   style: AppTypography.titleLarge.copyWith(
            //     color: const Color.fromARGB(255, 28, 186, 200),
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // TweenAnimationBuilder<double>(
            //   tween: Tween<double>(begin: -5.0, end: 5.0),
            //   duration: const Duration(seconds: 2),
            //   builder: (context, value, child) {
            //     return Transform.translate(
            //       offset: Offset(value, 0),
            //       child: child,
            //     );
            //   },
            //   child: Text(
            //     'ClickShop',
            //     style: AppTypography.titleLarge.copyWith(
            //       color: const Color.fromARGB(255, 14, 23, 188),
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Pulse(
              infinite: true,
              duration: const Duration(milliseconds: 1200),
              child: Text(
                'Click Shop',
                style: AppTypography.titleLarge.copyWith(
                  color: const Color.fromARGB(255, 3, 112, 74),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            const Spacer(),
            _buildIconButton(
              Icons.search_rounded,
              color: Colors.amberAccent,
              onTap: () => ref.read(mainTabIndexProvider.notifier).state = 1,
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              Icons.shopping_bag_outlined,
              color: Colors.blueAccent,
              onTap: () => ref.read(mainTabIndexProvider.notifier).state = 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon,
      {required MaterialAccentColor color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.h2),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style:
                    AppTypography.labelMedium.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        child: categoriesAsync.when(
          data: (categories) => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected =
                  selectedCategory.toLowerCase() == category.id.toLowerCase();

              return GestureDetector(
                onTap: () => context.push('/category/${category.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: SmartImage(
                          imagePath: category.image ?? '',
                          width: 65,
                          height: 65,
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, WidgetRef ref,
      AsyncValue<List<Product>> productsAsync, String selectedCategory) {
    return productsAsync.when(
      data: (products) {
        final filtered = selectedCategory.toLowerCase() == 'all'
            ? products
            : products
                .where((p) =>
                    p.category.toLowerCase() == selectedCategory.toLowerCase())
                .toList();
        return SliverPadding(
          padding: EdgeInsets.all(AppResponsive.scale(context, 20)),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  AppResponsive.gridColumns(context, minItemWidth: 150),
              mainAxisSpacing: AppResponsive.scale(context, 20),
              crossAxisSpacing: AppResponsive.scale(context, 20),
              childAspectRatio: AppResponsive.productCardRatio(context),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => PremiumProductCard(product: filtered[index]),
              childCount: filtered.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
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
    );
  }
}