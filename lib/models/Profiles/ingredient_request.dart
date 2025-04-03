class IngredientRequest {
  final int shoppingListId;
  final String ingredientName;
  final String measurementUnit;
  final String quantity;

  IngredientRequest({
    required this.shoppingListId,
    required this.ingredientName,
    required this.measurementUnit,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'shopping_list_id': shoppingListId,
        'ingredient_name': ingredientName,
        'measurement_unit': measurementUnit,
        'quantity': quantity,
      };
}
