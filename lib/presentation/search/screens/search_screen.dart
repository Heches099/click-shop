import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/design_tokens.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/amazon_disclosure.dart';
import '../../../domain/entities/amazon_product.dart';
import '../../core/widgets/amazon_product_card.dart';
import '../../home/providers/amazon_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _history = [
    "Levi's 501",
    'AirPods Pro',
    'Instant Pot',
    'CeraVe',
  ];
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _showResults =>
      _query.trim().isNotEmpty || _selectedCategory != null;

  List<AmazonProduct> _filterResults(List<AmazonProduct> all) {
    final q = _query.trim().toLowerCase();
    final selected = _selectedCategory?.toLowerCase();
    return all.where((p) {
      final matchesCategory =
          selected == null || selected == 'all' || p.category.toLowerCase() == selected;
      final tokens = q
          .split(RegExp(r'\s+'))
          .where((t) => t.length >= 3)
          .toList();
      final haystack = '${p.name} ${p.brand} ${p.category}'.toLowerCase();
      final matchesQuery =
          tokens.isEmpty || tokens.every((t) => haystack.contains(t));
      return matchesCategory && matchesQuery;
    }).toList();
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

  void _clearFilters() {
    setState(() {
      _query = '';
      _selectedCategory = null;
    });
  }

  void _selectCategory(String? category) {
    final normalized = category?.toLowerCase();
    setState(() {
      _selectedCategory =
          (normalized == null || normalized == 'all' || normalized.isEmpty)
              ? null
              : category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(amazonAllProductsProvider);
    final categoriesAsync = ref.watch(amazonAffiliateCategoriesProvider);
    final all = productsAsync.value ?? const <AmazonProduct>[];
    final results = _filterResults(all);
    final categories = categoriesAsync.value ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _buildSearchBar(),
            ),
            if (categories.isNotEmpty)
              _buildCategoryChips(categories),
            Expanded(
              child: productsAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productsAsync.hasError && all.isEmpty
                      ? _buildLoadError()
                      : _showResults
                          ? _buildResults(results)
                          : _buildIdleContent(categories),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          const Text('Unable to load products',
              style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Check your connection and try again.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(amazonAllProductsProvider);
              ref.invalidate(amazonAffiliateCategoriesProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                  hintText: 'Search Amazon products...',
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
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<AmazonAffiliateCategory> categories) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip('All', _selectedCategory == null),
          ...categories
              .map((c) => _buildChip(c.name, _selectedCategory == c.name)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _selectCategory(isSelected ? null : label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: isSelected ? null : AppShadows.soft,
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdleContent(List<AmazonAffiliateCategory> categories) {
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
          child: _buildSectionHeader('Shop by Category'),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: _buildCategoryGrid(categories),
        ),
        const SizedBox(height: 24),
        const AmazonDisclosure(),
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

  Widget _buildCategoryGrid(List<AmazonAffiliateCategory> categories) {
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
        final category = categories[index];
        return GestureDetector(
          onTap: () => _selectCategory(category.name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                Icon(_categoryIcon(category.imageKey),
                    color: const Color(0xFFFF9900)),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(category.name,
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

  Widget _buildResults(List<AmazonProduct> results) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${results.length} products',
                style: AppTypography.titleLarge),
            if (_selectedCategory != null || _query.trim().isNotEmpty)
              TextButton(
                onPressed: _clearFilters,
                child: Text('Clear',
                    style: TextStyle(
                        color: AppColors.error.withValues(alpha: 0.8))),
              ),
          ],
        ),
        if (_selectedCategory != null) ...[
          const SizedBox(height: 8),
          _buildActiveCategoryChip(),
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
              childAspectRatio: 0.58,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) =>
                AmazonProductCard(amazonProduct: results[index]),
          ),
        const SizedBox(height: 16),
        const AmazonDisclosure(),
      ],
    );
  }

  Widget _buildActiveCategoryChip() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InputChip(
          label: Text(_selectedCategory!),
          onDeleted: _clearFilters,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('No products found', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text('Try a different search term or category.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => openExternalLink(
                'https://www.amazon.com/s?k=${Uri.encodeQueryComponent(_query)}'),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Search on Amazon'),
          ),
        ],
      ),
    );
  }
}