class RecommendationRequest {
  final String keycloakUserId;
  final List<String> favoriteCategories;
  final List<String> allergies;
  final int cookingTime;

  RecommendationRequest({
    required this.keycloakUserId,
    required this.favoriteCategories,
    required this.allergies,
    required this.cookingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'keycloak_user_id': keycloakUserId,
      'favorite_categories': favoriteCategories,
      'allergies': allergies,
      'cooking_time': cookingTime,
    };
  }
}
