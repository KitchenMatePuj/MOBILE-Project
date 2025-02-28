import '/models/ingredient_model.dart';
import '/models/recipe_ingredient_model.dart';

class IngredientController {
  final List<Ingredient> allIngredients = [
    Ingredient(ingredientId: "1", ingredientName: "Pasta", quantity: "200", unit: "g"),
    Ingredient(ingredientId: "2", ingredientName: "Carne molida", quantity: "300", unit: "g"),
    Ingredient(ingredientId: "3", ingredientName: "Queso", quantity: "100", unit: "g"),
    Ingredient(ingredientId: "4", ingredientName: "Pavo", quantity: "1", unit: "kg"),
    Ingredient(ingredientId: "5", ingredientName: "Sal", quantity: "10", unit: "g"),
    Ingredient(ingredientId: "6", ingredientName: "Banana", quantity: "3", unit: "u"),
    Ingredient(ingredientId: "7", ingredientName: "Helado", quantity: "200", unit: "g"),
    Ingredient(ingredientId: "8", ingredientName: "Papas", quantity: "500", unit: "g"),
    Ingredient(ingredientId: "9", ingredientName: "Aceite", quantity: "50", unit: "ml"),
    Ingredient(ingredientId: "10", ingredientName: "Harina", quantity: "200", unit: "g"),
    Ingredient(ingredientId: "11", ingredientName: "Huevos", quantity: "2", unit: "u"),
    Ingredient(ingredientId: "12", ingredientName: "Naranjas", quantity: "4", unit: "u"),
    Ingredient(ingredientId: "13", ingredientName: "Salchichas", quantity: "4", unit: "u"),
    Ingredient(ingredientId: "14", ingredientName: "Mariscos", quantity: "300", unit: "g"),
    Ingredient(ingredientId: "15", ingredientName: "Arroz", quantity: "200", unit: "g"),
  ];

  final List<RecipeIngredient> recipeIngredients = [
    RecipeIngredient(recipeId: "1", ingredientId: "1"),
    RecipeIngredient(recipeId: "1", ingredientId: "2"),
    RecipeIngredient(recipeId: "1", ingredientId: "3"),
    RecipeIngredient(recipeId: "2", ingredientId: "4"),
    RecipeIngredient(recipeId: "2", ingredientId: "5"),
    RecipeIngredient(recipeId: "3", ingredientId: "6"),
    RecipeIngredient(recipeId: "3", ingredientId: "7"),
    RecipeIngredient(recipeId: "4", ingredientId: "8"),
    RecipeIngredient(recipeId: "4", ingredientId: "9"),
    RecipeIngredient(recipeId: "5", ingredientId: "10"),
    RecipeIngredient(recipeId: "5", ingredientId: "5"),
    RecipeIngredient(recipeId: "6", ingredientId: "12"),
    RecipeIngredient(recipeId: "6", ingredientId: "9"),
    RecipeIngredient(recipeId: "7", ingredientId: "11"),
    RecipeIngredient(recipeId: "7", ingredientId: "10"),
    RecipeIngredient(recipeId: "8", ingredientId: "14"),
    RecipeIngredient(recipeId: "8", ingredientId: "15"),
    RecipeIngredient(recipeId: "9", ingredientId: "14"),
    RecipeIngredient(recipeId: "10", ingredientId: "13"),
    RecipeIngredient(recipeId: "11", ingredientId: "13"),
    RecipeIngredient(recipeId: "11", ingredientId: "8"),
    RecipeIngredient(recipeId: "12", ingredientId: "1"),
    RecipeIngredient(recipeId: "12", ingredientId: "9"),
  ];

  List<Ingredient> getIngredientsByRecipeId(String recipeId) {
    final ingredientIds = recipeIngredients
        .where((ri) => ri.recipeId == recipeId)
        .map((ri) => ri.ingredientId)
        .toList();

    return allIngredients
        .where((ingredient) => ingredientIds.contains(ingredient.ingredientId))
        .toList();
  }

  List<Ingredient> getFilteredIngredients(String query, int ingredientsToShow) {
    return allIngredients
        .where((ingredient) => ingredient.ingredientName.toLowerCase().contains(query.toLowerCase()))
        .take(ingredientsToShow)
        .toList();
  }
}