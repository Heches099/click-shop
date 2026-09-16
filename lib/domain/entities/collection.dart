import 'product.dart';

/// A curated collection (e.g. "Everyday Sneakers", "Student Setup").
/// Collections are editorial — honest groupings, never fake sale events.
class CollectionEntity {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String tag;
  final String image;
  final int productCount;

  /// Populated only by the detail endpoint.
  final List<Product> products;

  const CollectionEntity({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    this.tag = '',
    this.image = '',
    this.productCount = 0,
    this.products = const [],
  });

  factory CollectionEntity.fromJson(Map<String, dynamic> json) {
    return CollectionEntity(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      image: json['image'] as String? ?? '',
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );
  }
}