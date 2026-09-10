class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String category;
  final int stock;
  final String brand;
  final Map<String, String> specifications;
  final List<String> colors;
  final List<String> sizes;

  // AMAZON ASSOCIATES: Optional fields for Amazon product integration.
  // When set, the product detail screen shows a "Buy on Amazon" button
  // that opens the affiliate URL with tracking ID: clickshop03b-20.
  final String? asin;
  final String? amazonUrl;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.stock,
    required this.brand,
    this.specifications = const {},
    this.colors = const [],
    this.sizes = const [],
    this.asin,
    this.amazonUrl,
  });

  String get firstImage => images.isNotEmpty ? images.first : '';
  
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }
}
