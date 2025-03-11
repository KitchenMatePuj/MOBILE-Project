import '/models/ingredient_model.dart';
import '/models/recipe_ingredient_model.dart';

class IngredientController {
  final List<Ingredient> allIngredients = [
    Ingredient(ingredientId: "1", ingredientName: "Pasta"),
    Ingredient(ingredientId: "2", ingredientName: "Carne molida"),
    Ingredient(ingredientId: "3", ingredientName: "Queso"),
    Ingredient(ingredientId: "4", ingredientName: "Pavo"),
    Ingredient(ingredientId: "5", ingredientName: "Sal"),
    Ingredient(ingredientId: "6", ingredientName: "Banana"),
    Ingredient(ingredientId: "7", ingredientName: "Helado"),
    Ingredient(ingredientId: "8", ingredientName: "Papas"),
    Ingredient(ingredientId: "9", ingredientName: "Aceite"),
    Ingredient(ingredientId: "10", ingredientName: "Harina"),
    Ingredient(ingredientId: "11", ingredientName: "Huevos"),
    Ingredient(ingredientId: "12", ingredientName: "Naranjas"),
    Ingredient(ingredientId: "13", ingredientName: "Salchichas"),
    Ingredient(ingredientId: "14", ingredientName: "Mariscos"),
    Ingredient(ingredientId: "15", ingredientName: "Arroz"),
    Ingredient(ingredientId: "16", ingredientName: "Leche"),
    Ingredient(ingredientId: "17", ingredientName: "Carne"),
    Ingredient(ingredientId: "18", ingredientName: "Galletas"),
  ];

  final List<RecipeIngredient> recipeIngredients = [
    RecipeIngredient(recipeId: "1", ingredientId: "1", quantity: "200", unit: "g"),
    RecipeIngredient(recipeId: "1", ingredientId: "2", quantity: "300", unit: "g"),
    RecipeIngredient(recipeId: "1", ingredientId: "3", quantity: "100", unit: "g"),
    RecipeIngredient(recipeId: "2", ingredientId: "4", quantity: "1", unit: "kg"),
    RecipeIngredient(recipeId: "2", ingredientId: "5", quantity: "10", unit: "g"),
    RecipeIngredient(recipeId: "3", ingredientId: "6", quantity: "3", unit: "u"),
    RecipeIngredient(recipeId: "3", ingredientId: "7", quantity: "200", unit: "g"),
    RecipeIngredient(recipeId: "4", ingredientId: "8", quantity: "500", unit: "g"),
    RecipeIngredient(recipeId: "4", ingredientId: "9", quantity: "50", unit: "ml"),
    RecipeIngredient(recipeId: "5", ingredientId: "10", quantity: "1000", unit: "g"),
    RecipeIngredient(recipeId: "5", ingredientId: "5", quantity: "10", unit: "g"),
    RecipeIngredient(recipeId: "6", ingredientId: "12", quantity: "4", unit: "u"),
    RecipeIngredient(recipeId: "6", ingredientId: "9", quantity: "50", unit: "ml"),
    RecipeIngredient(recipeId: "7", ingredientId: "11", quantity: "2", unit: "u"),
    RecipeIngredient(recipeId: "7", ingredientId: "10", quantity: "200", unit: "g"),
    RecipeIngredient(recipeId: "8", ingredientId: "14", quantity: "300", unit: "g"),
    RecipeIngredient(recipeId: "8", ingredientId: "15", quantity: "200", unit: "g"),
    RecipeIngredient(recipeId: "9", ingredientId: "14", quantity: "300", unit: "g"),
    RecipeIngredient(recipeId: "10", ingredientId: "13", quantity: "4", unit: "u"),
    RecipeIngredient(recipeId: "11", ingredientId: "13", quantity: "4", unit: "u"),
    RecipeIngredient(recipeId: "11", ingredientId: "8", quantity: "500", unit: "g"),
    RecipeIngredient(recipeId: "12", ingredientId: "1", quantity: "200", unit: "g"),
    RecipeIngredient(recipeId: "12", ingredientId: "9", quantity: "50", unit: "ml"),
    RecipeIngredient(recipeId: "13", ingredientId: "17", quantity: "300", unit: "g"),
    RecipeIngredient(recipeId: "13", ingredientId: "10", quantity: "200", unit: "g"),
  ];

  List<RecipeIngredient> getIngredientsByRecipeId(String recipeId) {
    return recipeIngredients
        .where((ri) => ri.recipeId == recipeId)
        .toList();
  }

  List<RecipeIngredient> getFilteredIngredients(String query, int ingredientsToShow) {
    return recipeIngredients
        .where((ri) => allIngredients.firstWhere((ingredient) => ingredient.ingredientId == ri.ingredientId).ingredientName.toLowerCase().contains(query.toLowerCase()))
        .take(ingredientsToShow)
        .toList();
  }
}