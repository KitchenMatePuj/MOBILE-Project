class RecipeIngredient {
  final String recipeId;
  final String ingredientId;
  final String quantity;
  final String unit;

  RecipeIngredient({
    required this.recipeId,
    required this.ingredientId,
    required this.quantity,
    required this.unit,
  });
}