/// A buying guide — long-form editorial that helps a shopper decide.
/// Written by humans for humans; contains no fabricated "winners".
class GuideEntity {
  final String id;
  final String slug;
  final String title;
  final String summary;

  /// Backend category slug (e.g. "electronics") used for grouping.
  final String categorySlug;
  final String image;
  final DateTime? publishedAt;

  /// Markdown body — populated only by the detail endpoint.
  final String body;

  const GuideEntity({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    this.categorySlug = '',
    this.image = '',
    this.publishedAt,
    this.body = '',
  });

  factory GuideEntity.fromJson(Map<String, dynamic> json) {
    final published = json['publishedAt'] as String?;
    return GuideEntity(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      categorySlug: json['categorySlug'] as String? ?? '',
      image: json['image'] as String? ?? '',
      publishedAt: published != null ? DateTime.tryParse(published) : null,
      body: json['body'] as String? ?? '',
    );
  }
}