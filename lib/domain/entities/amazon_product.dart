import 'product.dart';

/// ---------------------------------------------------------------------------
/// AMAZON ASSOCIATES INTEGRATION
/// Domain entities for the Amazon affiliate flow.
///
/// * [AmazonAffiliateCategory] — the active affiliate-link mode: curated
///   category destination pages on Amazon.
/// * [AmazonProduct] — normalized real-product data returned by the backend
///   when the Amazon Creators API becomes available. Converts to [Product]
///   for the existing ClickShop UI (PremiumProductCard).
///
/// Tracking ID: clickshop03b-20
/// The backend owns URL generation. The browser only ever receives public
/// product/category info and public affiliate destination URLs.
/// ---------------------------------------------------------------------------

/// A curated affiliate destination category (link mode — active now).
class AmazonAffiliateCategory {
  final String id;
  final String name;
  final String description;
  final String keyword;
  final String imageKey;
  final String affiliateUrl;

  const AmazonAffiliateCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.keyword,
    required this.imageKey,
    required this.affiliateUrl,
  });

  factory AmazonAffiliateCategory.fromJson(Map<String, dynamic> json) {
    return AmazonAffiliateCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      imageKey: json['imageKey'] as String? ?? '',
      affiliateUrl: json['affiliateUrl'] as String? ?? '',
    );
  }
}

class AmazonProduct {
  final String id;
  final String asin;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String category;
  final String brand;
  final String amazonUrl;

  const AmazonProduct({
    required this.id,
    required this.asin,
    required this.name,
    this.description = '',
    required this.price,
    this.originalPrice,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.category = '',
    this.brand = '',
    this.amazonUrl = '',
  });

  /// Convert to the existing [Product] entity so we can reuse
  /// [PremiumProductCard] and [ProductDetailScreen] without modification.
  Product toProduct() => Product(
        id: id,
        name: name,
        description: description.isNotEmpty ? name : description,
        price: price,
        originalPrice: originalPrice,
        images: images,
        rating: rating,
        reviewCount: reviewCount,
        category: category,
        stock: 1,
        brand: brand,
        asin: asin,
        amazonUrl: amazonUrl,
      );

  factory AmazonProduct.fromJson(Map<String, dynamic> json) {
    return AmazonProduct(
      id: json['id'] as String? ?? '',
      asin: json['asin'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      amazonUrl: json['amazonUrl'] as String? ?? '',
    );
  }
}
