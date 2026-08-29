import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// Small, always-visible affiliate disclosure line (E-E-A-T / YMYL best
/// practice for monetized content). Placed under ads and product grids.
class AffiliateDisclosure extends StatelessWidget {
  const AffiliateDisclosure({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'As an affiliate, ClickShop may earn a commission from partner '
              'links — you never pay extra. Ad placements are clearly marked '
              'and reserved in fixed-size boxes.',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
