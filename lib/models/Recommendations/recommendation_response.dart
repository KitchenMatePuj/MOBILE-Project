class RecommendationResponse {
  final int recipeId;
  final String title;
  final String keycloakUserId;
  final int cookingTime;
  final double ratingAvg;
  final List<String> categories;
  final List<String> ingredients;

  RecommendationResponse({
    required this.recipeId,
    required this.title,
    required this.keycloakUserId,
    required this.cookingTime,
    required this.ratingAvg,
    required this.categories,
    required this.ingredients,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      recipeId: json['recipe_id'],
      title: json['title'],
      keycloakUserId: json['keycloak_user_id'],
      cookingTime: json['cooking_time'],
      ratingAvg: (json['rating_avg'] as num).toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }
}
