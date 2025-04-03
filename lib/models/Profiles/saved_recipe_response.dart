class SavedRecipeResponse {
  final int savedRecipeId;
  final int profileId;
  final int recipeId;

  SavedRecipeResponse({
    required this.savedRecipeId,
    required this.profileId,
    required this.recipeId,
  });

  factory SavedRecipeResponse.fromJson(Map<String, dynamic> json) {
    return SavedRecipeResponse(
      savedRecipeId: json['saved_recipe_id'],
      profileId: json['profile_id'],
      recipeId: json['recipe_id'],
    );
  }
}
