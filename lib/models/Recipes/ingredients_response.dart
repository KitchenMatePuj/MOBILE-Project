class IngredientResponse {
  final int ingredientId;
  final int recipeId;
  final String name;
  final String measurementUnit;

  IngredientResponse({
    required this.ingredientId,
    required this.recipeId,
    required this.name,
    required this.measurementUnit,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    return IngredientResponse(
      recipeId: json['recipe_id'],
      ingredientId: json['ingredient_id'],
      name: json['name'],
      measurementUnit: json['measurement_unit'],
    );
  }
}
