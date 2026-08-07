class CategoryEntity {
  final String id;
  final String name;
  final String? parentId;
  final String? image;
  final List<CategoryEntity> subcategories; // for tree

  CategoryEntity({
    required this.id,
    required this.name,
    this.parentId,
    this.image,
    required this.subcategories,
  });
}
