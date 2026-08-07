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
  Future<List<CategoryModel>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;
  ProductRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    // Mocking API call
    return _mockProducts();
  }

  @override
  Future<List<ProductModel>> getBestSellers() async {
    return _mockProducts();
  }

  @override
  Future<List<ProductModel>> getNewArrivals() async {
    return _mockProducts();
  }

  @override
  Future<List<ProductModel>> getFlashSales() async {
    return _mockProducts();
  }

  @override
  Future<List<ProductModel>> getRecommended() async {
    return _mockProducts();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    return _mockProducts().firstWhere((p) => p.id == id);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return [
      const CategoryModel(
          id: 'all',
          name: 'All',
          image:
              'https://i.pinimg.com/736x/8e/31/00/8e3100561579730598808298f244199c.jpg'),
      const CategoryModel(
          id: 'shoes',
          name: 'Shoes',
          image:
              'https://i.pinimg.com/736x/1b/13/2c/1b132cc8333076b38b57265daa978d9c.jpg'),
      const CategoryModel(
          id: 'apparel',
          name: 'Apparel',
          image:
              'https://i.pinimg.com/736x/44/c7/a7/44c7a75a1248dce2d3745380f00e0ab1.jpg'),
      const CategoryModel(
          id: 'electronics',
          name: 'Tech',
          image:
              'https://i.pinimg.com/736x/0c/f2/fc/0cf2fc9c914c7e77588d12f6186d85bf.jpg'),
      const CategoryModel(
          id: 'accessories',
          name: 'Watch',
          image:
              'https://i.pinimg.com/1200x/5e/49/e3/5e49e3398a136f76a5e7711fa9b6cfbb.jpg'),
      const CategoryModel(
          id: 'home',
          name: 'Home',
          image:
              'https://i.pinimg.com/736x/40/7b/79/407b79545115aab75405987ad2c5f73f.jpg'),
    ];
  }

  List<ProductModel> _mockProducts() {
    final categories = ['shoes', 'apparel', 'electronics', 'accessories', 'home'];
    return List.generate(
      20,
      (index) {
        final categoryId = categories[index % categories.length];
        return ProductModel(
          id: index.toString(),
          name: index == 0 ? 'Nike Air Max 270' : 'Product $index',
          brand: index == 0 ? 'Nike' : 'Premium Brand',
          description: 'Premium quality product description for item $index.',
          price: 99.99 + index,
          originalPrice: index % 2 == 0 ? 150.0 + index : null,
          images: [
            'https://picsum.photos/id/${index + 50}/600/600',
            'https://picsum.photos/id/${index + 51}/600/600',
          ],
          rating: 4.5,
          reviewCount: 100 + index,
          category: categoryId,
          stock: 50,
          specifications: {'Material': 'Premium', 'Origin': 'Imported'},
          colors: ['#000000', '#FFFFFF', '#FF0000'],
          sizes: ['7', '8', '9', '10'],
        );
      },
    );
  }
}
