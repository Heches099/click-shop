import '../../core/widgets/premium_button.dart';
import '../../core/widgets/smart_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/ads/ad_config.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/google_ad_banner.dart';
import '../../../domain/entities/product.dart';
import '../../cart/providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildImageHeader(product),
              _buildProductInfo(product),
              _buildSelectionSections(product),
              _buildSpecifications(product),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: GoogleAdBanner(slotId: AdConfig.productSlot),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildBottomAction(product),
          _buildTopBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    return Positioned(
      top: topPadding + 10,
      left: AppResponsive.scale(context, 20),
      right: AppResponsive.scale(context, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInLeft(
            child: _buildCircleButton(
                Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
          ),
          FadeInRight(
            child: _buildCircleButton(Icons.favorite_border_rounded, () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildImageHeader(Product product) {
    final imageHeight = AppResponsive.detailImageHeight(context);
    return SliverToBoxAdapter(
      child: Container(
        height: imageHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Hero(
              tag: 'product_image_${product.id}',
              child: CarouselSlider.builder(
                itemCount: product.images.length,
                options: CarouselOptions(
                  height: imageHeight,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return SmartImage(
                    imagePath: product.images[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 30,
              child: Row(
                children: List.generate(
                  product.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _selectedImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _selectedImageIndex == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return SliverPadding(
      padding: EdgeInsets.all(AppResponsive.scale(context, 24)),
      sliver: SliverToBoxAdapter(
        child: FadeInUp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.brand,
                      style: AppTypography.labelMedium.copyWith(fontSize: 16)),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.secondary, size: 20),
                      Text(
                          ' ${product.rating} (${product.reviewCount} reviews)',
                          style: AppTypography.labelMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(product.name, style: AppTypography.h1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('\$${product.price}',
                      style:
                          AppTypography.h1.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 12),
                  if (product.hasDiscount)
                    Text(
                      '\$${product.originalPrice}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Description', style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              Text(product.description,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSections(Product product) {
    return SliverPadding(
      padding:
          EdgeInsets.symmetric(horizontal: AppResponsive.scale(context, 24)),
      sliver: SliverToBoxAdapter(
        child: FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSelectionHeader('Select Color'),
              const SizedBox(height: 12),
              _buildColorList(product.colors),
              const SizedBox(height: 24),
              _buildSelectionHeader('Select Size'),
              const SizedBox(height: 12),
              _buildSizeList(product.sizes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleLarge),
        Text('Size Guide',
            style: AppTypography.labelMedium.copyWith(color: AppColors.accent)),
      ],
    );
  }

  Widget _buildColorList(List<String> colors) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color =
              Color(int.parse(colors[index].replaceFirst('#', '0xFF')));
          final isSelected = _selectedColor == colors[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colors[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2),
              ),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSizeList(List<String> sizes) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sizes.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedSize == sizes[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedSize = sizes[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border),
                boxShadow: isSelected ? null : AppShadows.soft,
              ),
              child: Text(
                sizes[index],
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecifications(Product product) {
    return SliverPadding(
      padding: EdgeInsets.all(AppResponsive.scale(context, 24)),
      sliver: SliverToBoxAdapter(
        child: FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Specifications', style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              ...product.specifications.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text('${e.key}: ',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                        Text(e.value,
                            style: AppTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(Product product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeInUp(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppResponsive.scale(context, 24),
            20,
            AppResponsive.scale(context, 24),
            MediaQuery.viewInsetsOf(context).bottom +
                AppResponsive.scale(context, 24),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: AppShadows.medium,
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Price', style: AppTypography.labelMedium),
                  Text('\$${product.price}',
                      style: AppTypography.titleLarge
                          .copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumPressableButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(
                          product,
                          color: _selectedColor,
                          size: _selectedSize,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to bag'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  text: 'Add to Bag',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
