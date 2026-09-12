import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../core/constants/amazon_affiliate.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/widgets/amazon_disclosure.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../core/widgets/amazon_product_card.dart';
import '../../core/widgets/smart_image.dart';
import '../providers/amazon_provider.dart';

/// ---------------------------------------------------------------------------
/// AMAZON ASSOCIATES — "Shop on Amazon" affiliate section.
///
/// ACTIVE MODE (affiliate links): shows curated category destination cards
/// backed by the backend's `/amazon/categories`. Each card opens Amazon
/// directly with the tracking ID (clickshop03b-20) that the backend placed
/// in the URL. A "Deals from Amazon" row shows the curated real products
/// returned by the backend.
///
/// FUTURE MODE (Amazon Creators API): when the backend starts returning live
/// API products, the same row renders them — without any Flutter rewrite.
///
/// Resilience: while the backend loads, and on any error, a single friendly
/// fallback card is shown so the section is never a forever-spinner.
/// ---------------------------------------------------------------------------

class AmazonGamingSection extends ConsumerWidget {
  const AmazonGamingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(amazonAffiliateCategoriesProvider);
    final productsAsync = ref.watch(amazonGamingProductsProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildFallbackCard();
        }
        final views = categories.map(_CategoryView.from).toList();
        final products =
            productsAsync.asData?.value ?? const <AmazonProduct>[];
        return _buildAffiliateSection(context, views, products);
      },
      loading: () => _buildFallbackCard(),
      error: (_, __) => _buildFallbackCard(),
    );
  }

  /// Primary affiliate-link section: header + category cards + optional
  /// future product row + Amazon Associates disclosure.
  Widget _buildAffiliateSection(
    BuildContext context,
    List<_CategoryView> categories,
    List<AmazonProduct> products,
  ) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          if (products.isNotEmpty) ...[
            _buildProductsHeader(),
            _buildProductRow(products),
            const SizedBox(height: 16),
          ],
          _buildCategoryGrid(context, categories),
          const AmazonDisclosure(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9900),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Shop on Amazon',
                style: AppTypography.titleLarge.copyWith(fontSize: 18)),
          ],
        ),
        TextButton(
          onPressed: () => openExternalLink(kAmazonAffiliateFallbackUrl),
          child: const Text('View All',
              style: TextStyle(color: Color(0xFFFF9900))),
        ),
      ],
    );
  }

  Widget _buildProductsHeader() {
    return Row(
      children: [
        const Icon(Icons.local_offer_rounded,
            size: 16, color: Color(0xFFFF9900)),
        const SizedBox(width: 6),
        Text('Deals from Amazon',
            style: AppTypography.titleLarge.copyWith(fontSize: 15)),
      ],
    );
  }

  Widget _buildProductRow(List<AmazonProduct> products) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) => SizedBox(
          width: 160,
          child: AmazonProductCard(amazonProduct: products[index]),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<_CategoryView> views) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = screenWidth >= 900
        ? 4
        : screenWidth >= 600
            ? 3
            : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: views.length,
      itemBuilder: (context, index) => _CategoryCard(view: views[index]),
    );
  }

  /// Safe fallback used on load/error so the section never hangs.
  Widget _buildFallbackCard() {
    return FadeInUp(
      child: GestureDetector(
        onTap: () => openExternalLink(kAmazonAffiliateFallbackUrl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF232F3E), Color(0xFF37475A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9900).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9900),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.sports_esports_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amazon Gaming',
                        style: AppTypography.titleLarge.copyWith(
                            color: Colors.white, fontSize: 17)),
                    const SizedBox(height: 2),
                    Text('Shop gaming deals on Amazon',
                        style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9900),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Shop on Amazon',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight view-model for a category card, resolving a local asset image
/// (when available) or an icon fallback.
class _CategoryView {
  final String id;
  final String name;
  final String description;
  final String affiliateUrl;
  final String? assetPath;
  final IconData icon;

  _CategoryView({
    required this.id,
    required this.name,
    required this.description,
    required this.affiliateUrl,
    this.assetPath,
    required this.icon,
  });

  factory _CategoryView.from(AmazonAffiliateCategory category) {
    // Curated mapping, keyed exactly like the backend's imageKey values.
    const assets = kAmazonCategoryAssets;
    const icons = <String, IconData>{
      'gaming': Icons.sports_esports_rounded,
      'gaming_pc': Icons.computer_rounded,
      'laptop': Icons.laptop_windows_rounded,
      'monitor': Icons.monitor_rounded,
      'gpu': Icons.memory_rounded,
      'keyboard': Icons.keyboard_rounded,
      'mouse': Icons.mouse_rounded,
      'headset': Icons.headset_rounded,
    };
    return _CategoryView(
      id: category.id,
      name: category.name,
      description: category.description,
      affiliateUrl: category.affiliateUrl,
      assetPath: assets[category.imageKey],
      icon: icons[category.imageKey] ?? Icons.shopping_bag_rounded,
    );
  }
}

/// Curated affiliate category card.
class _CategoryCard extends StatelessWidget {
  final _CategoryView view;

  const _CategoryCard({required this.view});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openExternalLink(view.affiliateUrl),
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
              flex: 3,
              child: view.assetPath != null
                  ? SmartImage(imagePath: view.assetPath!, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFF5F5F5),
                      child: Center(
                        child: Icon(view.icon,
                            size: 40, color: const Color(0xFFFF9900)),
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        view.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_outward_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Shop on Amazon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}