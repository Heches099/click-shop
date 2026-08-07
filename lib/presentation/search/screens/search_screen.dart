import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/product.dart';
import '../../home/providers/home_provider.dart';
import '../../home/widgets/product_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const double _maxPrice = 2000;

  final TextEditingController _searchController = TextEditingController();
  List<String> _history = ['Nike Air Max', 'Smart Watch', 'Casual T-shirt'];
  String _query = '';
  ProductFilters _filters = const ProductFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _showResults => _query.trim().isNotEmpty || _filters.isActive;

  List<Product> get _results {
    final all = ref.watch(allProductsProvider);
    final q = _query.trim().toLowerCase();
    final list = all.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final inRange = p.price >= _filters.priceRange.start &&
          p.price <= _filters.priceRange.end;
      final inBrands = _filters.brands.isEmpty ||
          _filters.brands.any(
              (b) => b.trim().toLowerCase() == p.brand.trim().toLowerCase());
      return matchesQuery && inRange && inBrands;
    }).toList();
    switch (_filters.sort) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
      default:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }
    return list;
  }

  List<String> get _brands {
    final all = ref.watch(allProductsProvider);
    final set = all
        .map((p) => p.brand.trim())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    set.sort();
    return set;
  }

  List<MapEntry<String, int>> get _popularCategories {
    final all = ref.watch(allProductsProvider);
    final counts = <String, int>{};
    for (final p in all) {
      final c = p.category.trim();
      if (c.isEmpty) continue;
      counts[c] = (counts[c] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(4).toList();
  }

  void _applyQuery(String value) {
    final trimmed = value.trim();
    setState(() {
      _query = trimmed;
      if (trimmed.isNotEmpty && !_history.contains(trimmed)) {
        _history = [trimmed, ..._history].take(8).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<ProductFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: _filters,
        brands: _brands,
      ),
    );
    if (result != null) {
      setState(() => _filters = result);
    }
  }

  void _clearFilters() {
    setState(() => _filters = const ProductFilters());
  }

  void _updateFilters(ProductFilters next) {
    setState(() => _filters = next);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: _showResults
                  ? _buildResults(results)
                  : _buildIdleContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.soft,
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
                onSubmitted: _applyQuery,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openFilters,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 24),
                ),
                if (_filters.isActive)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: _buildSectionHeader('Recent Searches'),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: _buildHistoryList(),
        ),
        const SizedBox(height: 32),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: _buildSectionHeader('Popular Categories'),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: _buildCategoryGrid(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.titleLarge),
        if (title == 'Recent Searches' && _history.isNotEmpty)
          TextButton(
            onPressed: () => setState(() => _history.clear()),
            child: Text('Clear All',
                style:
                    TextStyle(color: AppColors.error.withValues(alpha: 0.8))),
          ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Text('No recent searches',
          style:
              AppTypography.labelMedium.copyWith(fontStyle: FontStyle.italic));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _history
          .map((item) => ActionChip(
                label: Text(item, style: AppTypography.labelMedium),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onPressed: () {
                  _searchController.text = item;
                  _applyQuery(item);
                },
              ))
          .toList(),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _popularCategories;
    final columns = AppResponsive.gridColumns(context, minItemWidth: 170)
        .clamp(2, 3)
        .toInt();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index].key;
        return GestureDetector(
          onTap: () => _applyQuery(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                Icon(_categoryIcon(category), color: AppColors.primary),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('shoe') || c.contains('sneaker')) {
      return Icons.directions_run_rounded;
    }
    if (c.contains('watch')) return Icons.watch_rounded;
    if (c.contains('cloth') ||
        c.contains('shirt') ||
        c.contains('apparel')) {
      return Icons.checkroom_rounded;
    }
    if (c.contains('electronic')) return Icons.devices_rounded;
    if (c.contains('accessor')) return Icons.shopping_bag_rounded;
    return Icons.category_rounded;
  }

  Widget _buildResults(List<Product> results) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${results.length} results', style: AppTypography.titleLarge),
            if (_filters.isActive)
              TextButton(
                onPressed: _clearFilters,
                child: Text('Clear Filters',
                    style: TextStyle(
                        color: AppColors.error.withValues(alpha: 0.8))),
              ),
          ],
        ),
        if (_filters.isActive) ...[
          const SizedBox(height: 8),
          _buildActiveFilterChips(),
        ],
        const SizedBox(height: 16),
        if (results.isEmpty)
          _buildEmptyState()
        else
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
              childAspectRatio: AppResponsive.productCardRatio(context),
            ),
            itemCount: results.length,
            itemBuilder: (context, index) =>
                PremiumProductCard(product: results[index]),
          ),
      ],
    );
  }

  Widget _buildActiveFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_filters.sort != 'Popularity')
          InputChip(
            label: Text(_filters.sort),
            onDeleted: () => _updateFilters(ProductFilters(
              priceRange: _filters.priceRange,
              sort: 'Popularity',
              brands: _filters.brands,
            )),
          ),
        ..._filters.brands.map((b) => InputChip(
              label: Text(b),
              onDeleted: () => _updateFilters(ProductFilters(
                priceRange: _filters.priceRange,
                sort: _filters.sort,
                brands: _filters.brands.where((x) => x != b).toList(),
              )),
            )),
        if (_filters.priceRange.start != 0 ||
            _filters.priceRange.end != _maxPrice)
          InputChip(
            label: Text(
                '\$${_filters.priceRange.start.round()}-\$${_filters.priceRange.end.round()}'),
            onDeleted: () => _updateFilters(ProductFilters(
              priceRange: const RangeValues(0, _maxPrice),
              sort: _filters.sort,
              brands: _filters.brands,
            )),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('No products found', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text('Try a different search term or adjust your filters.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
