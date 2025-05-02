class IngredientRequest {
  final int shoppingListId;
  final String ingredientName;
  final String measurementUnit;

  IngredientRequest(
      {required this.shoppingListId,
      required this.ingredientName,
      required this.measurementUnit});

  Map<String, dynamic> toJson() => {
        'shopping_list_id': shoppingListId,
        'ingredient_name': ingredientName,
        'measurement_unit': measurementUnit
      };
}
