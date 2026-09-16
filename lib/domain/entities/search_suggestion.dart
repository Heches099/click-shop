/// A single autocomplete suggestion returned by `/search/suggest`.
class SearchSuggestion {
  final String productId;
  final String slug;
  final String name;
  final String brand;
  final double price;
  final String? image;

  const SearchSuggestion({
    required this.productId,
    required this.slug,
    required this.name,
    this.brand = '',
    this.price = 0.0,
    this.image,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      productId: json['product_id'] as String? ?? json['productId'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String?,
    );
  }
}

class SearchSuggestionsResult {
  final List<SearchSuggestion> products;
  final List<({String slug, String name})> categories;
  final List<String> popular;

  const SearchSuggestionsResult({
    this.products = const [],
    this.categories = const [],
    this.popular = const [],
  });

  factory SearchSuggestionsResult.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final rawCategories = json['categories'];
    final rawPopular = json['popular'];
    return SearchSuggestionsResult(
      products: rawProducts is List
          ? rawProducts
              .whereType<Map>()
              .map((e) => SearchSuggestion.fromJson(e.cast<String, dynamic>()))
              .toList()
          : const [],
      categories: rawCategories is List
          ? rawCategories
              .whereType<Map>()
              .map((e) {
                final map = e.cast<String, dynamic>();
                return (slug: map['slug'] as String? ?? '', name: map['name'] as String? ?? '');
              })
              .toList()
          : const [],
      popular: rawPopular is List ? rawPopular.cast<String>().toList() : const [],
    );
  }
}