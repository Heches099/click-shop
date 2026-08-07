import 'package:flutter/material.dart';
import '../../../config/design_tokens.dart';

class ProductFilters {
  final RangeValues priceRange;
  final String sort;
  final List<String> brands;

  const ProductFilters({
    this.priceRange = const RangeValues(0, 2000),
    this.sort = 'Popularity',
    this.brands = const [],
  });

  bool get isActive =>
      sort != 'Popularity' ||
      priceRange.start != 0 ||
      priceRange.end != 2000 ||
      brands.isNotEmpty;
}

class FilterBottomSheet extends StatefulWidget {
  final ProductFilters initialFilters;
  final List<String> brands;

  const FilterBottomSheet({
    super.key,
    this.initialFilters = const ProductFilters(),
    this.brands = const [],
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  static const double _maxPrice = 2000;
  late RangeValues _priceRange = widget.initialFilters.priceRange;
  late String _selectedSort = widget.initialFilters.sort;
  late final List<String> _selectedBrands = List.of(widget.initialFilters.brands);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters', style: AppTypography.h2),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, _maxPrice);
                      _selectedSort = 'Popularity';
                      _selectedBrands.clear();
                    });
                  },
                  child: Text(
                      'Reset',
                      style: TextStyle(
                          color: AppColors.error.withValues(alpha: 0.8))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Price Range', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: _maxPrice,
              divisions: 20,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            const SizedBox(height: 24),
            const Text('Brands', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            _buildBrandChips(),
            const SizedBox(height: 24),
            const Text('Sort By', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            _buildSortOptions(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                ProductFilters(
                  priceRange: _priceRange,
                  sort: _selectedSort,
                  brands: List.of(_selectedBrands),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChips() {
    final brands = widget.brands.isEmpty
        ? const ['Nike', 'Adidas', 'Puma', 'Reebok', 'New Balance', 'Asics']
        : widget.brands;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);
        return FilterChip(
          label: Text(brand),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBrands.add(brand);
              } else {
                _selectedBrands.remove(brand);
              }
            });
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.1),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortOptions() {
    const options = [
      'Popularity',
      'Newest',
      'Price: Low to High',
      'Price: High to Low'
    ];
    return RadioGroup<String>(
      groupValue: _selectedSort,
      onChanged: (value) => setState(() => _selectedSort = value!),
      child: Column(
        children: options.map((option) => RadioListTile<String>(
              title: Text(option, style: AppTypography.bodyMedium),
              value: option,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            )).toList(),
      ),
    );
  }
}
