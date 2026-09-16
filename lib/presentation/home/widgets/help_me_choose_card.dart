import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';

/// Bulleted, no-pressure link into the Help-Me-Choose flow.
class HelpMeChooseCard extends StatelessWidget {
  const HelpMeChooseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF6E5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/help-me-choose'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.assistant_outlined,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stuck choosing?',
                        style: AppTypography.titleMedium),
                    SizedBox(height: 4),
                    Text(
                      'Tell us what you want and your budget — we line up '
                      'real options.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}