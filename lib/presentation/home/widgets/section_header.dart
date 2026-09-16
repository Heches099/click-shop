import 'package:flutter/material.dart';
import '../../../config/design_tokens.dart';

/// Standard section title with an optional trailing "See all" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleLarge),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text('See all',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}