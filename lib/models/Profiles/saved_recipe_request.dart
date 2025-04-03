class SavedRecipeRequest {
  final int profileId;
  final int recipeId;

  SavedRecipeRequest({
    required this.profileId,
    required this.recipeId,
  });

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'recipe_id': recipeId,
      };
}
