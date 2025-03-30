import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceRecipe {
  static const String _baseUrl = 'http://localhost:8004';

  // Comments
  Future<bool> addComment(int recipeId, String text, int authorUserId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recipes/$recipeId/comments/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'author_user_id': String,
        'rating': double,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to add comment: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listComments(int recipeId) async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes/$recipeId/comments/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list comments: ${response.body}');
      return [];
    }
  }

  Future<bool> deleteComment(int recipeId, int commentId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/recipes/$recipeId/comments/$commentId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete comment: ${response.body}');
      return false;
    }
  }

  // Ingredients
  Future<bool> createIngredient(String name, String measurementUnit) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ingredients/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'measurement_unit': measurementUnit,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create ingredient: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listIngredients() async {
    final response = await http.get(Uri.parse('$_baseUrl/ingredients/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list ingredients: ${response.body}');
      return [];
    }
  }

  Future<bool> updateIngredient(int ingredientId, String name, String measurementUnit) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/ingredients/$ingredientId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'measurement_unit': measurementUnit,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update ingredient: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteIngredient(int ingredientId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/ingredients/$ingredientId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete ingredient: ${response.body}');
      return false;
    }
  }

  // Categories
  Future<bool> createCategory(String name) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/categories/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create category: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list categories: ${response.body}');
      return [];
    }
  }

  Future<bool> updateCategory(int categoryId, String name) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/categories/$categoryId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update category: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/categories/$categoryId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete category: ${response.body}');
      return false;
    }
  }

  // Recipes
  Future<bool> createRecipe(String title, String foodType, int cookingTime, int totalPortions, String keycloakUserId, int categoryId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recipes/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'food_type': foodType,
        'cooking_time': cookingTime,
        'total_portions': totalPortions,
        'keycloak_user_id': keycloakUserId,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create recipe: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listRecipes() async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list recipes: ${response.body}');
      return [];
    }
  }

  Future<bool> updateRecipe(int recipeId, String title, String foodType, int cookingTime, int totalPortions, int categoryId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/recipes/$recipeId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'food_type': foodType,
        'cooking_time': cookingTime,
        'total_portions': totalPortions,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update recipe: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteRecipe(int recipeId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/recipes/$recipeId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete recipe: ${response.body}');
      return false;
    }
  }

  // Recipe Steps
  Future<bool> createRecipeStep(int recipeId, int stepNumber, String title, String description) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recipes/$recipeId/steps/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'step_number': stepNumber,
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create recipe step: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listRecipeSteps(int recipeId) async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes/$recipeId/steps/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list recipe steps: ${response.body}');
      return [];
    }
  }

  Future<bool> updateRecipeStep(int recipeId, int stepId, int stepNumber, String title, String description) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/recipes/$recipeId/steps/$stepId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'step_number': stepNumber,
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update recipe step: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteRecipeStep(int recipeId, int stepId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/recipes/$recipeId/steps/$stepId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete recipe step: ${response.body}');
      return false;
    }
  }
}