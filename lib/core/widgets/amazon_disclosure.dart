import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// Amazon Associates Program disclosure.
///
/// Required-language variant of the affiliate disclosure for the Amazon
/// shopping section. Placed directly under the Amazon affiliate cards.
class AmazonDisclosure extends StatelessWidget {
  const AmazonDisclosure({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Click Shop is a participant in the Amazon Services LLC '
              'Associates Program, an affiliate advertising program designed '
              'to provide a means for sites to earn advertising fees by '
              'advertising and linking to Amazon.com. As an Amazon '
              'Associate, we earn from qualifying purchases.',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}