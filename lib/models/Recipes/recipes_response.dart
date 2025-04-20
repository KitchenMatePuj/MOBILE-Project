class RecipeResponse {
  final int recipeId;
  final int categoryId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cookingTime;
  final String foodType;
  final int totalPortions;
  final String keycloakUserId;
  final double ratingAvg;
  final String? imageUrl;

  RecipeResponse({
    required this.recipeId,
    required this.categoryId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.cookingTime,
    required this.foodType,
    required this.totalPortions,
    required this.keycloakUserId,
    required this.ratingAvg,
    this.imageUrl,
  });

  factory RecipeResponse.fromJson(Map<String, dynamic> json) {
    return RecipeResponse(
      recipeId: json['recipe_id'],
      categoryId: json['category_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cookingTime: json['cooking_time'],
      foodType: json['food_type'],
      totalPortions: json['total_portions'],
      keycloakUserId: json['keycloak_user_id'],
      ratingAvg: json['rating_avg'].toDouble(),
      imageUrl: json['image_url'],
    );
  }
}
