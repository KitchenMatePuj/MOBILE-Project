class CategoryResponse {
  final int categoryId;
  final String name;

  CategoryResponse({
    required this.categoryId,
    required this.name,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      categoryId: json['category_id'],
      name: json['name'],
    );
  }
}
