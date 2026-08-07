import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../config/design_tokens.dart';
import '../../../core/constants/app_constants.dart';

/// Compact "Earn with ClickShop" promo that funnels users into the
/// affiliate program. Displays the configured commission rate.
class AffiliatePromoCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AffiliatePromoCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = (AppConstants.affiliateCommissionRate * 100).round();
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.18),
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
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.black, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Earn $percent% commission',
                        style: AppTypography.titleLarge.copyWith(
                            color: Colors.white, fontSize: 17)),
                    const SizedBox(height: 2),
                    Text('Share ClickShop, get paid on every sale.',
                        style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.secondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
