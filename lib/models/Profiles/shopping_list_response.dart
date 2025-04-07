class ShoppingListResponse {
  final int shoppingListId;
  final int profileId;
  final String recipeName;
  final String recipePhoto;

  ShoppingListResponse({
    required this.shoppingListId,
    required this.profileId,
    required this.recipeName,
    required this.recipePhoto,
  });

  factory ShoppingListResponse.fromJson(Map<String, dynamic> json) {
    return ShoppingListResponse(
      shoppingListId: json['shopping_list_id'],
      profileId: json['profile_id'],
      recipeName: json['recipe_name'],
      recipePhoto: json['recipe_photo'],
    );
  }
}