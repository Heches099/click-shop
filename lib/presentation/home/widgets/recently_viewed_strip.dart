import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../recent/providers/recent_views_provider.dart';
import 'product_card.dart';
import 'section_header.dart';

/// "Continue browsing" — items the shopper actually viewed (no fabrication).
class RecentlyViewedStrip extends ConsumerWidget {
  const RecentlyViewedStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentViewsProvider).asData?.value ?? const [];
    if (recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recently viewed'),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(
              width: 150,
              child: PremiumProductCard(product: recent[i]),
            ),
          ),
        ),
      ],
    );
  }
}