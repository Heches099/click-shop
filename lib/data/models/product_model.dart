import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    double? originalPrice,
    required List<String> images,
    required double rating,
    required int reviewCount,
    required String category,
    required int stock,
    required String brand,
    @Default({}) Map<String, String> specifications,
    @Default([]) List<String> colors,
    @Default([]) List<String> sizes,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromEntity(Product product) => ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        originalPrice: product.originalPrice,
        images: product.images,
        rating: product.rating,
        reviewCount: product.reviewCount,
        category: product.category,
        stock: product.stock,
        brand: product.brand,
        specifications: product.specifications,
        colors: product.colors,
        sizes: product.sizes,
      );
}

extension ProductModelX on ProductModel {
  Product toEntity() => Product(
        id: id,
        name: name,
        description: description,
        price: price,
        originalPrice: originalPrice,
        images: images,
        rating: rating,
        reviewCount: reviewCount,
        category: category,
        stock: stock,
        brand: brand,
        specifications: specifications,
        colors: colors,
        sizes: sizes,
      );
}
