import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/seo/seo_service.dart';

/// Real 404 page rendered for unmatched routes. Emits `noindex, follow` so
/// soft-404s never get indexed.
class NotFoundScreen extends ConsumerWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SeoService.instance.setPageMeta(
      title: 'Page Not Found | ClickShop',
      description: 'The page you are looking for does not exist or has moved. Browse the latest products on ClickShop.',
      canonicalPath: '/404',
      robots: 'noindex, follow',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 72, color: AppColors.border),
              const SizedBox(height: 20),
              Text('404', style: AppTypography.h1),
              const SizedBox(height: 8),
              const Text('Page not found', style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              Text(
                'This page may have moved or never existed.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}