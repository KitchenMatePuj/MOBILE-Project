import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Recipes/recipes_request.dart';
import '../../models/Recipes/recipes_response.dart';

class RecipeController {
  final String baseUrl;

  RecipeController({required this.baseUrl});

  /// Crear una receta (POST /recipes)
  Future<RecipeResponse> createRecipe(RecipeRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RecipeResponse.fromJson(jsonDecode(response.body));
    } else {
      // ¡IMPORTANTE! Lanza excepción si falla:
      throw Exception(
          'Failed to create recipe: ${response.statusCode}, ${response.body}');
    }
  }

  /// Obtener una receta por ID (GET /recipes/{id})
  Future<RecipeResponse> getRecipeById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));

    if (response.statusCode == 200) {
      return RecipeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Recipe not found');
    }
  }

  /// Listar todas las recetas (GET /recipes)
  Future<List<RecipeResponse>> fetchRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  /// Buscar recetas (GET /recipes/search?title=&cooking_time=&ingredient=)
  Future<List<RecipeResponse>> searchRecipes(
      {String? title, int? cookingTime, String? ingredient}) async {
    final queryParams = {
      if (title != null) 'title': title,
      if (cookingTime != null) 'cooking_time': cookingTime.toString(),
      if (ingredient != null) 'ingredient': ingredient,
    };

    final uri = Uri.parse('$baseUrl/recipes/search')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }

  /// Actualizar receta (PUT /recipes/{id})
  Future<RecipeResponse> updateRecipe(int id, RecipeRequest request) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return RecipeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update recipe');
    }
  }

  /// Eliminar receta (DELETE /recipes/{id})
  Future<void> deleteRecipe(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/recipes/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete recipe');
    }
  }

  /// Obtener recetas por usuario (GET /recipes/user/{userId})
  Future<List<RecipeResponse>> getRecipesByUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to get recipes by user');
    }
  }

  /// Filtrar recetas por rating (GET /recipes/ratings/filter?min_rating=x&max_rating=y)
  Future<List<RecipeResponse>> filterRecipesByRating(
      double minRating, double maxRating) async {
    final uri = Uri.parse(
        '$baseUrl/recipes/ratings/filter?min_rating=$minRating&max_rating=$maxRating');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to filter recipes by rating');
    }
  }

  /// Obtener estadísticas por tiempo de cocción (GET /recipes/statistics/cooking-time)
  Future<List<Map<String, dynamic>>> getCookingTimeStats() async {
    final response =
        await http.get(Uri.parse('$baseUrl/recipes/statistics/cooking-time'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get cooking time statistics');
    }
  }

  /// Obtener número total de recetas (GET /recipes/statistics/total)
  Future<int> getTotalRecipeCount() async {
    final response =
        await http.get(Uri.parse('$baseUrl/recipes/statistics/total'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return json['total_recipes'];
    } else {
      throw Exception('Failed to get total recipe count');
    }
  }
}
