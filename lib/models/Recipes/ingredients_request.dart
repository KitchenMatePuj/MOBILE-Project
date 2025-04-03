class IngredientRequest {
  final String name;
  final String measurementUnit;
  final int recipeId;

  IngredientRequest({
    required this.name,
    required this.measurementUnit,
    required this.recipeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'measurement_unit': measurementUnit,
      'recipe_id': recipeId,
    };
  }
}
