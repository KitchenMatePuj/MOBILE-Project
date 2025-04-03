class IngredientResponse {
  final int ingredientId;
  final int shoppingListId;
  final String ingredientName;
  final String measurementUnit;
  final String quantity;

  IngredientResponse({
    required this.ingredientId,
    required this.shoppingListId,
    required this.ingredientName,
    required this.measurementUnit,
    required this.quantity,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    return IngredientResponse(
      ingredientId: json['ingredient_id'],
      shoppingListId: json['shopping_list_id'],
      ingredientName: json['ingredient_name'],
      measurementUnit: json['measurement_unit'],
      quantity: json['quantity'],
    );
  }
}
