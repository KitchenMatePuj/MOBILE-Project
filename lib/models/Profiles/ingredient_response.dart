class IngredientResponse {
  final int recipeId;
  final int ingredientId;
  final int shoppingListId;
  final String ingredientName;
  final String measurementUnit;

  IngredientResponse({
    required this.recipeId, // ← agregado
    required this.ingredientId,
    required this.shoppingListId,
    required this.ingredientName,
    required this.measurementUnit,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    return IngredientResponse(
      recipeId: json['recipe_id'], // ← agregado
      ingredientId: json['ingredient_id'],
      shoppingListId: json['shopping_list_id'],
      ingredientName: json['ingredient_name'],
      measurementUnit: json['measurement_unit'],
    );
  }
}
