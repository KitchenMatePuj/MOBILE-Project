// models/Recipes/full_recipe_response.dart
import 'package:mobile_kitchenmate/models/Profiles/ingredient_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/comments_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipe_steps_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_response.dart';

// models/Recipes/full_recipe_response.dart
class FullRecipeResponse {
  final RecipeResponse recipe;
  final List<RecipeStepResponse> steps;
  final List<IngredientResponse> ingredients;
  final List<CommentResponse> comments;

  FullRecipeResponse({
    required this.recipe,
    required this.steps,
    required this.ingredients,
    required this.comments,
  });

  factory FullRecipeResponse.fromJson(Map<String, dynamic> j) {
    return FullRecipeResponse(
      recipe: RecipeResponse.fromJson(j['recipe']), // <<–––– cambia aquí
      steps: (j['steps'] as List)
          .map((e) => RecipeStepResponse.fromJson(e))
          .toList(),
      ingredients: (j['ingredients'] as List)
          .map((e) => IngredientResponse.fromJson(e))
          .toList(),
      comments: (j['comments'] as List)
          .map((e) => CommentResponse.fromJson(e))
          .toList(),
    );
  }
}
