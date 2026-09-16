import 'package:flutter/material.dart';
import '../../../config/business_info.dart';
import '../../../config/design_tokens.dart';

/// Renders one of the trust/info pages (About, Returns, Shipping, Privacy,
/// Terms) from [BusinessInfo]. Factual copy only — no invented claims.
class InfoPageScreen extends StatelessWidget {
  final String slug;
  const InfoPageScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final entry = BusinessInfo.infoPages[slug];
    final title = entry?.$1 ?? 'ClickShop';
    final body = entry?.$2 ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(title, style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: _Body(text: body),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body({required this.text});

  @override
  Widget build(BuildContext context) {
    final blocks = text
        .split(RegExp(r'\n{2,}'))
        .where((b) => b.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) ...[
          if (block.trimLeft().startsWith('- '))
            ...(block.split('\n').map((line) => _bulletItem(line)))
          else
            Text(
              block.trim(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          const SizedBox(height: AppSpacing.m),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _bulletItem(String line) {
    final text = line.trimLeft().replaceFirst(RegExp(r'^-+\s*'), '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}