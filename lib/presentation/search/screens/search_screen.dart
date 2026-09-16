import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../core/constants/amazon_affiliate.dart';
import '../../../core/services/events/event_tracker.dart';
import '../../../core/services/seo/seo_service.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/amazon_disclosure.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../core/widgets/amazon_product_card.dart';
import '../../core/widgets/smart_image.dart';
import '../../home/providers/amazon_provider.dart';
import '../../home/widgets/product_card.dart';
import '../../recent/providers/recent_views_provider.dart';
import '../providers/catalog_search_provider.dart';
import '../../discover/providers/discover_provider.dart';

/// The Search tab. Honest, server-driven:
///  - idle  → recent searches (local) + popular searches (server) + Amazon browse
///  - typing → server autocomplete suggestions
///  - submit → real catalog results (backend `GET /products`), plus a clearly
///             separated "From Amazon" column, with an external Amazon fallback
///             when the catalog has no matches.
class SearchScreen extends ConsumerStatefulWidget {
  /// Optional query pre-filled from a `/search?q=...` deep link.
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _typed = '';
  String? _submitted;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim();
    if (initial != null && initial.isNotEmpty) {
      _typed = initial;
      _controller.text = initial;
      _submitted = initial;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final showResults = _submitted?.trim().isNotEmpty == true;
    SeoService.instance.setPageMeta(robots: showResults ? 'noindex, follow' : '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _typing => _typed.trim().isNotEmpty && _submitted != _typed.trim();

  bool get _results => _typed.trim().isNotEmpty && _submitted == _typed.trim();

  void _onTyped(String value) {
    setState(() => _typed = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
    SeoService.instance.setPageMeta(
        robots: value.trim().isNotEmpty ? 'noindex, follow' : '');
  }

  void _submit(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;
    setState(() {
      _submitted = q;
      _typed = q;
      _controller.text = q;
    });
    ref.read(searchHistoryProvider.notifier).add(q);
    EventTracker().track('search', payload: {'query': q});
    SeoService.instance.setPageMeta(robots: 'noindex, follow');
  }

  void _clear() {
    setState(() {
      _typed = '';
      _submitted = null;
      _controller.clear();
    });
    SeoService.instance.setPageMeta(robots: '');
  }

  void _clearFilters() => setState(() {
        _submitted = null;
        _typed = '';
        _controller.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: _buildSearchBar(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    List<String>? inlineSuggestions;
    if (_typing && _typed.trim().length >= 2) {
      inlineSuggestions =
          ref.watch(searchSuggestionsProvider(_typed.trim())).value?.products.map((p) => p.name).toList();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.soft,
                  ),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onChanged: _onTyped,
                    onSubmitted: _submit,
                    decoration: InputDecoration(
                      hintText: 'Search the catalog...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary),
                      suffixIcon: _typed.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: _clear,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (inlineSuggestions != null && inlineSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: [
                  for (final s in inlineSuggestions)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.north_west_rounded,
                          size: 16, color: AppColors.textMuted),
                      title: Text(s,
                          style: AppTypography.bodyMedium.copyWith(fontSize: 14)),
                      onTap: () => _submit(s),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_results) return _buildResults(_typed.trim());
    return _buildIdle();
  }

  Widget _buildIdle() {
    final history = ref.watch(searchHistoryProvider);
    final popular = ref.watch(popularSearchesProvider);
    final categories =
        ref.watch(amazonAffiliateCategoriesProvider).value ?? const [];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        FadeInUp(
          delay: const Duration(milliseconds: 150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent searches', style: AppTypography.titleLarge),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      ref.read(searchHistoryProvider.notifier).clear(),
                  child: Text('Clear All',
                      style: TextStyle(
                          color: AppColors.error.withValues(alpha: 0.8))),
                ),
            ],
          ),
        ),
        if (history.isEmpty)
          Text('Search once and we remember it here.',
              style: AppTypography.labelMedium.copyWith(fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: history
                .map((item) => InputChip(
                      label: Text(item, style: AppTypography.labelMedium),
                      backgroundColor: AppColors.surface,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      deleteIcon: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.textMuted),
                      onPressed: () {
                        _controller.text = item;
                        _submit(item);
                      },
                      onDeleted: () =>
                          ref.read(searchHistoryProvider.notifier).remove(item),
                    ))
                .toList(),
          ),
        const SizedBox(height: 28),
        Row(
          children: [
            Text('People are searching', style: AppTypography.titleLarge),
            const SizedBox(width: 8),
            const Icon(Icons.trending_up_rounded,
                size: 18, color: AppColors.textMuted),
          ],
        ),
        const SizedBox(height: 10),
        if (popular.value?.isNotEmpty != true)
          Text('Popular searches will show up here as people use search.',
              style:
                  AppTypography.labelMedium.copyWith(fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (popular.value ?? const [])
                .map((item) => ActionChip(
                      label: Text(item, style: AppTypography.labelMedium),
                      backgroundColor: AppColors.surface,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onPressed: () {
                        _controller.text = item;
                        _submit(item);
                      },
                    ))
                .toList(),
          ),
        const SizedBox(height: 28),
        FadeInUp(
          delay: const Duration(milliseconds: 250),
          child: _buildSectionHeader('Browse Amazon categories'),
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const SizedBox()
        else
          _buildCategoryGrid(categories),
        const SizedBox(height: 24),
        const AmazonDisclosure(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title, style: AppTypography.titleLarge)],
    );
  }

  Widget _buildResults(String query) {
    final params = (query: query, minPrice: null, maxPrice: null);
    final catalog = ref.watch(catalogSearchProvider(params));
    final amazon = ref.watch(amazonAllProductsProvider);
    final amazonMatches = _filterAmazon(amazon.value ?? const [], query);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Catalog matches for "$query"',
                style: AppTypography.titleLarge),
            TextButton(
              onPressed: _clearFilters,
              child: Text('Clear',
                  style:
                      TextStyle(color: AppColors.error.withValues(alpha: 0.8))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        catalog.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Search is unavailable right now.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          data: (products) {
            if (products.isEmpty && amazonMatches.isEmpty) {
              return _buildEmpty(query);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (products.isEmpty)
                  Text('No catalog matches — but here is the Amazon hunt.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary))
                else ...[
                  Text('${products.length} in our catalog',
                      style:
                          AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  for (final p in products) ...[
                    PremiumProductCard(product: p),
                    const SizedBox(height: 14),
                  ],
                ],
                if (amazonMatches.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('From Amazon', style: AppTypography.titleLarge),
                      const SizedBox(width: 8),
                      const Icon(Icons.shopping_bag_outlined,
                          size: 18, color: Color(0xFFFF9900)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real affiliate links — ClickShop may earn a commission.', 
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          AppResponsive.gridColumns(context, minItemWidth: 170)
                              .clamp(2, 3)
                              .toInt(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: amazonMatches.length,
                    itemBuilder: (context, i) =>
                        AmazonProductCard(amazonProduct: amazonMatches[i]),
                  ),
                ],
                const SizedBox(height: 16),
                const AmazonDisclosure(),
              ],
            );
          },
        ),
      ],
    );
  }

  List<AmazonProduct> _filterAmazon(List<AmazonProduct> all, String q) {
    final tokens = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 3)
        .toList();
    if (tokens.isEmpty) return const [];
    return all.where((p) {
      final haystack = '${p.name} ${p.brand} ${p.category}'.toLowerCase();
      return tokens.every((t) => haystack.contains(t));
    }).toList();
  }

  Widget _buildEmpty(String query) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('No products found', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Our catalog has no match for "$query" right now. '
            'Continue the hunt on Amazon with the same search.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => openExternalLink(
                'https://www.amazon.com/s?k=${Uri.encodeQueryComponent(query)}'),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Search on Amazon'),
          ),
          const SizedBox(height: 8),
          const AmazonDisclosure(),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
      List<AmazonAffiliateCategory> categories) {
    final cols = AppResponsive.gridColumns(context, minItemWidth: 170)
        .clamp(2, 3)
        .toInt();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final assetPath = kAmazonCategoryAssets[category.imageKey];
        return GestureDetector(
          onTap: () => _submit(category.name),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.soft,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (assetPath != null)
                  SmartImage(imagePath: assetPath, fit: BoxFit.cover)
                else
                  Container(
                    color: const Color(0xFFF5F5F5),
                    alignment: Alignment.center,
                    child: Icon(_categoryIcon(category.imageKey),
                        size: 44, color: const Color(0xFFFF9900)),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String imageKey) {
    switch (imageKey) {
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'gaming_pc':
        return Icons.computer_rounded;
      case 'laptop':
        return Icons.laptop_windows_rounded;
      case 'monitor':
        return Icons.monitor_rounded;
      case 'gpu':
        return Icons.memory_rounded;
      case 'keyboard':
        return Icons.keyboard_rounded;
      case 'mouse':
        return Icons.mouse_rounded;
      case 'headset':
        return Icons.headset_rounded;
      case 'mens-fashion':
      case 'womens-fashion':
        return Icons.checkroom_rounded;
      case 'mens-shoes':
      case 'womens-shoes':
        return Icons.directions_run_rounded;
      case 'beauty':
        return Icons.brush_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'home-kitchen':
        return Icons.kitchen_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}