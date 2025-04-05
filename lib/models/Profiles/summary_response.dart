import 'dart:convert';

ProfileSummaryResponse profileSummaryResponseFromJson(String str) =>
    ProfileSummaryResponse.fromJson(json.decode(str));

class ProfileSummaryResponse {
  final String keycloakUserId;
  final List<int> savedRecipes;
  final int cookingTime;
  final List<String> ingredientAllergies;

  ProfileSummaryResponse({
    required this.keycloakUserId,
    required this.savedRecipes,
    required this.cookingTime,
    required this.ingredientAllergies,
  });

  factory ProfileSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ProfileSummaryResponse(
      keycloakUserId: json['keycloak_user_id'],
      savedRecipes: List<int>.from(json['saved_recipes']),
      cookingTime: json['cooking_time'],
      ingredientAllergies: List<String>.from(json['ingredient_allergies']),
    );
  }
}
