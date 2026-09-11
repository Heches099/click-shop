import '../providers/home_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/ads/ad_config.dart';
import '../../../core/widgets/affiliate_disclosure.dart';
import '../../../core/widgets/google_ad_banner.dart';
import '../widgets/banner_slider.dart';
import '../widgets/affiliate_promo_card.dart';
import '../widgets/amazon_gaming_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // AMAZON_ASSOCIATES: Amazon Gaming products section
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
}