import '../models/product_model.dart';
import '../models/category_model.dart';
import '../../core/network/dio_client.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getBestSellers();
  Future<List<ProductModel>> getNewArrivals();
  Future<List<ProductModel>> getFlashSales();
  Future<List<ProductModel>> getRecommended();
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> getProductBySlug(String slug);
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String categorySlug);
  Future<List<ProductModel>> searchProducts({
    String q = '',
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
  });
  Future<RelatedProductsModels> getRelatedProducts(String productId);
}

typedef RelatedProductsModels = ({
  List<ProductModel> similar,
  List<ProductModel> cheaper,
  List<ProductModel> higherEnd,
  List<ProductModel> complementary,
});

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;
  ProductRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ProductModel>> getFeaturedProducts() =>
      _fetchProducts('/products/featured');

  @override
  Future<List<ProductModel>> getBestSellers() =>
      _fetchProducts('/products/best-sellers');

  @override
  Future<List<ProductModel>> getNewArrivals() =>
      _fetchProducts('/products/new-arrivals');

  @override
  Future<List<ProductModel>> getFlashSales() =>
      _fetchProducts('/products/flash-sales');

  @override
  Future<List<ProductModel>> getRecommended() =>
      _fetchProducts('/products/recommended');

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await dioClient.dio.get('/products/$id');
    return ProductModel.fromJson(_asObject(response.data));
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await dioClient.dio.get('/products/by-slug/$slug');
    return ProductModel.fromJson(_asObject(response.data));
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.dio.get('/categories');
    final items = _extractList(response.data);
    return items
        .map((json) => CategoryModel.fromJson(_asObject(json)))
        .toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categorySlug) async {
    final response = await dioClient.dio
        .get('/products', queryParameters: {'category': categorySlug});
    final items = _extractList(response.data);
    return items
        .map((json) => ProductModel.fromJson(_asObject(json)))
        .toList();
  }

  @override
  Future<List<ProductModel>> searchProducts({
    String q = '',
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? brands,
  }) async {
    final params = <String, dynamic>{
      if (q.trim().isNotEmpty) 'q': q.trim(),
      if (category != null && category.isNotEmpty && category != 'all')
        'category': category,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (brands != null && brands.isNotEmpty) 'brands': brands.join(','),
    };
    final response = await dioClient.dio.get('/products', queryParameters: params);
    final items = _extractList(response.data);
    return items
        .map((json) => ProductModel.fromJson(_asObject(json)))
        .toList();
  }

  @override
  Future<RelatedProductsModels> getRelatedProducts(String productId) async {
    final response = await dioClient.dio.get('/products/$productId/related');
    final data = _asObject(response.data);
    List<ProductModel> group(String key) {
      final raw = data[key];
      if (raw is! List) return const [];
      return raw
          .map((json) => ProductModel.fromJson(_asObject(json)))
          .toList();
    }

    return (
      similar: group('similar'),
      cheaper: group('cheaper'),
      higherEnd: group('higherEnd'),
      complementary: group('complementary'),
    );
  }

  Future<List<ProductModel>> _fetchProducts(String path) async {
    final response = await dioClient.dio.get(path);
    final items = _extractList(response.data);
    return items
        .map((json) => ProductModel.fromJson(_asObject(json)))
        .toList();
  }

  /// Accepts a bare JSON array or a wrapper object
  /// such as `{"data": [...]}`, `{"products": [...]}` or `{"items": [...]}`.
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const ['data', 'products', 'items', 'results']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asObject(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.cast<String, dynamic>();
    throw const FormatException('Expected a JSON object');
  }
}
