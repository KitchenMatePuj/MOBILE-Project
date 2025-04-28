class IngredientResponse {
  final int ingredientId;
  final int shoppingListId;
  final String ingredientName;
  final String measurementUnit;

  IngredientResponse({
    required this.ingredientId,
    required this.shoppingListId,
    required this.ingredientName,
    required this.measurementUnit,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    return IngredientResponse(
      ingredientId: json['ingredient_id'] ?? 0,
      shoppingListId: json['shopping_list_id'] ?? 0,
      ingredientName: json['ingredient_name'] ?? '',
      measurementUnit: json['measurement_unit'] ?? '',
    );
  }
}