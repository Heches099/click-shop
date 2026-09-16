import '../providers/home_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/business_info.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/ads/ad_config.dart';
import '../../../core/widgets/affiliate_disclosure.dart';
import '../../../core/widgets/google_ad_banner.dart';
import '../widgets/collections_strip.dart';
import '../widgets/banner_slider.dart';
import '../widgets/affiliate_promo_card.dart';
import '../widgets/amazon_gaming_card.dart';
import '../widgets/guides_strip.dart';
import '../widgets/recently_viewed_strip.dart';
import '../widgets/help_me_choose_card.dart';
import '../widgets/footer_block.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BusinessInfo.tagline,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real products. Real prices. No tricks.',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: PremiumBannerSlider(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: HelpMeChooseCard(),
            ),
          ),
SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: AffiliatePromoCard(
                onTap: () => context.push('/affiliate'),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CollectionsStrip(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: GuidesStrip(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: RecentlyViewedStrip(),
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
          const SliverToBoxAdapter(child: FooterBlock()),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
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
              child: Image.asset(
                'assets/icons/logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            _buildIconButton(
              Icons.compare_arrows_rounded,
              color: Colors.amberAccent,
              onTap: () => context.push('/compare'),
            ),
            const SizedBox(width: 8),
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