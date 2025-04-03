class RecipeRequest {
  final int categoryId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cookingTime;
  final String foodType;
  final int totalPortions;
  final String keycloakUserId;
  final double ratingAvg;

  RecipeRequest({
    required this.categoryId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.cookingTime,
    required this.foodType,
    required this.totalPortions,
    required this.keycloakUserId,
    this.ratingAvg = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cooking_time': cookingTime,
      'food_type': foodType,
      'total_portions': totalPortions,
      'keycloak_user_id': keycloakUserId,
      'rating_avg': ratingAvg,
    };
  }
}
