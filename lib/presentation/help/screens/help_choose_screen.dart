import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/services/events/event_tracker.dart';
import '../../../core/utils/open_link.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/widgets/product_card.dart';
import '../../search/providers/catalog_search_provider.dart';

/// "Help me choose" — an honest guided search. It asks what you want and what
/// you want to spend, then shows real catalog matches. No "winners", no fake
/// urgency. If the catalog has nothing, it says so and offers to continue the
/// hunt on Amazon.
class HelpMeChooseScreen extends ConsumerStatefulWidget {
  const HelpMeChooseScreen({super.key});

  @override
  ConsumerState<HelpMeChooseScreen> createState() => _HelpMeChooseScreenState();
}

class _HelpMeChooseScreenState extends ConsumerState<HelpMeChooseScreen> {
  final TextEditingController _query = TextEditingController();
  String? _budget;

  static const _budgets = [
    ('Any budget', null, null),
    ('Under \$50', null, 50.0),
    ('\$50 – \$150', 50.0, 150.0),
    ('\$150 – \$400', 150.0, 400.0),
    ('Over \$400', 400.0, null),
  ];

  String? _lastQuery;
  double? _lastMin;
  double? _lastMax;
  int _searched = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _startSearch() {
    final q = _query.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tell us what you are shopping for'),
          behavior: SnackBarBehavior.floating));
      return;
    }
    final selection = _budgets.firstWhere(
        (b) => b.$1 == _budget,
        orElse: () => _budgets.first);
    setState(() {
      _lastQuery = q;
      _lastMin = selection.$2;
      _lastMax = selection.$3;
      _searched++;
    });
    ref.invalidate(catalogSearchProvider);
    EventTracker().track('help_choose_start',
        payload: {'query': q, 'budget': _budget ?? ''});
    if (_searched == 1) {
      EventTracker().track('help_choose_result',
          payload: {'query': q, 'budget': _budget ?? ''});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.helpTitle,
            style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.helpSubtitle,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.helpWhatBuying,
                style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _query,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _startSearch(),
              decoration: InputDecoration(
                hintText: 'e.g. wireless earbuds for travel',
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.helpBudget,
                style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _budgets.map((b) {
                final selected = _budget == b.$1;
                return ChoiceChip(
                  label: Text(b.$1),
                  selected: selected,
                  onSelected: (_) => setState(() => _budget = b.$1),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _startSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.helpFinish,
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            if (_lastQuery != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final l10n = AppLocalizations.of(context)!;
    final provider = catalogSearchProvider((
      query: _lastQuery!,
      minPrice: _lastMin,
      maxPrice: _lastMax,
      sort: 'Popularity',
      brands: const [],
    ));
    final results = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.helpResults,
              style: AppTypography.titleMedium,
            ),
            TextButton(
              onPressed: () => context.push('/search?q=${Uri.encodeQueryComponent(_lastQuery!)}'),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        results.when(
          loading: () =>
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (e, _) => Text(l10n.errorGeneric,
              style: AppTypography.bodyMedium),
          data: (products) {
            if (products.isEmpty) {
              return _EmptyResults(
                query: _lastQuery!,
                minPrice: _lastMin,
                maxPrice: _lastMax,
              );
            }
            return Column(
              children: [
                for (final p in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PremiumProductCard(product: p),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EmptyResults extends ConsumerWidget {
  final String query;
  final double? minPrice;
  final double? maxPrice;
  const _EmptyResults(
      {required this.query, this.minPrice, this.maxPrice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final price = minPrice != null && maxPrice != null
        ? ' between \$${minPrice!.toStringAsFixed(0)} and '
            '\$${maxPrice!.toStringAsFixed(0)}'
        : minPrice != null && maxPrice == null
            ? ' over \$${minPrice!.toStringAsFixed(0)}'
            : minPrice == null && maxPrice != null
                ? ' under \$${maxPrice!.toStringAsFixed(0)}'
                : '';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            l10n.helpNoResults,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => openExternalLink(
                'https://www.amazon.com/s?k=${Uri.encodeQueryComponent(query)}'),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Hunt for it on Amazon'),
          ),
          const SizedBox(height: 6),
          Text(
            'Products you finalise there can be saved here for easy tracking.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          const Text(
            'Affiliate disclosure: ClickShop may earn a commission on Amazon links.',
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}