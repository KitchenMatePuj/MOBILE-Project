class ShoppingListRequest {
  final int profileId;
  final String recipeName;
  final String? recipePhoto;

  ShoppingListRequest({
    required this.profileId,
    required this.recipeName,
    this.recipePhoto,
  });

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'recipe_name': recipeName,
        'recipe_photo': recipePhoto,
      };
}
