import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/events/event_tracker.dart';
import '../../../domain/entities/product.dart';
import '../data/compare_store.dart';
import '../providers/compare_provider.dart';

/// Fact-only comparison. Rows that are identical across every product are
/// dimmed with a "same on all" hint; what differs gets the accent colour.
/// No rankings, no "this one wins".
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compare = ref.watch(compareProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Compare', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (compare.asData?.value.isNotEmpty == true)
            TextButton(
              onPressed: () {
                ref.read(compareProvider.notifier).clear();
                for (final p in compare.asData!.value) {
                  EventTracker().track('remove_from_compare', productId: p.id);
                }
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: switch (compare) {
        AsyncData(:final value) when value.isEmpty => const _EmptyState(),
        AsyncData(:final value) => _CompareGrid(products: value),
        AsyncError() => const _EmptyState(),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.compare_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.m),
            const Text('Nothing to compare yet',
                style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Open any product and tap "Compare" to line up your shortlist. '
              'You can compare up to 4 products at a time.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareGrid extends StatelessWidget {
  final List<Product> products;
  const _CompareGrid({required this.products});

  List<MapEntry<String, List<String?>>> get _rows {
    final rows = <String, List<String?>>{};
    for (final p in products) {
      final core = <String, String?>{
        'Price': p.price > 0 ? '\$${p.price.toStringAsFixed(2)}' : '—',
        'Compare at': p.originalPrice != null && p.originalPrice! > p.price
            ? '\$${p.originalPrice!.toStringAsFixed(2)}'
            : '—',
        'Rating': p.rating > 0
            ? '${p.rating.toStringAsFixed(1)} / 5 '
                '(${p.reviewCount} reviews)'
            : '—',
        'In stock': p.stock > 0 ? p.stock > 20 ? 'Yes' : 'Low (${p.stock})' : 'No',
        'Brand': p.brand.isNotEmpty ? p.brand : '—',
        'Category': p.category.isEmpty ? '—' : p.category,
        'Colors': p.colors.isEmpty ? '—' : p.colors.join(', '),
      };
      for (final entry in core.entries) {
        rows.putIfAbsent(entry.key, () => <String?>[])
            .add(entry.value);
      }
      // Union of specs so custom rows surface too.
      for (final s in p.specifications.entries) {
        final key = s.key;
        rows.putIfAbsent(key, () => <String?>[]).add(s.value);
      }
    }
    // Ensure every row has a value slot per product (missing -> filled below).
    for (final row in rows.values) {
      while (row.length < products.length) {
        row.add(null);
      }
    }
    final flat = rows.entries.toList();
    flat.sort((a, b) {
      final order = _coreOrder(a.key) - _coreOrder(b.key);
      return order != 0
          ? order
          : a.key.toLowerCase().compareTo(b.key.toLowerCase());
    });
    return flat;
  }

  int _coreOrder(String key) {
    const order = ['Price', 'Compare at', 'In stock', 'Rating', 'Brand', 'Category', 'Colors'];
    final i = order.indexOf(key);
    return i >= 0 ? i : 100;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _Table(products: products, rows: rows),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              '${products.length} of ${CompareStore.maxItems} slots used',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  final List<Product> products;
  final List<MapEntry<String, List<String?>>> rows;
  const _Table({required this.products, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cellWidth = 96.0;
    final nameWidth = 130.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: product cards (name + image thumb + tap to open).
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: nameWidth),
              for (final p in products)
                _ProductHeader(product: p, width: cellWidth),
            ],
          ),
        ),
        for (final row in rows)
          _Row(
            label: row.key,
            values: row.value,
            width: cellWidth,
            nameWidth: nameWidth,
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final List<String?> values;
  final double width;
  final double nameWidth;
  const _Row({
    required this.label,
    required this.values,
    required this.width,
    required this.nameWidth,
  });

  @override
  Widget build(BuildContext context) {
    final nonNull = values.whereType<String>().toList();
    final comesFromHeaders = label.startsWith('\$') || label == 'Compare at';
    final allSame = !comesFromHeaders &&
        nonNull.isNotEmpty &&
        nonNull.every((v) => v == nonNull.first);
    final cellColor = allSame ? AppColors.textMuted : AppColors.textPrimary;
    final rowBg = allSame
        ? AppColors.surface
        : AppColors.background;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        color: rowBg,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: nameWidth,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: allSame ? AppColors.textMuted : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final v in values)
            SizedBox(
              width: width,
              child: Text(
                v ?? '—',
                style: AppTypography.bodySmall.copyWith(color: cellColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductHeader extends ConsumerWidget {
  final Product product;
  final double width;
  const _ProductHeader({required this.product, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumb = product.images.isEmpty
        ? null
        : Image.network(product.images.first,
            width: width - 32,
            height: (width - 32) * 0.8,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
                width: width - 32,
                height: (width - 32) * 0.8,
                color: AppColors.surface,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textMuted)));
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            if (thumb != null) thumb else const SizedBox(height: 12),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              product.price > 0
                  ? '\$${product.price.toStringAsFixed(2)}'
                  : '',
              style: AppTypography.bodySmall.copyWith(color: AppColors.accent),
            ),
            IconButton(
              onPressed: () {
                ref.read(compareProvider.notifier).remove(product.id);
                EventTracker().track('remove_from_compare', productId: product.id);
              },
              icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
              tooltip: 'Remove from compare',
            ),
          ],
        ),
      ),
    );
  }
}