import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/saved_recipe_request.dart';
import '../../models/Profiles/saved_recipe_response.dart';

class SavedRecipeController {
  final String baseUrl;

  SavedRecipeController({required this.baseUrl});

  /// GET: Obtener una receta guardada por ID
  Future<SavedRecipeResponse> getSavedRecipe(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return SavedRecipeResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch saved recipe');
    }
  }

  /// GET: Listar todas las recetas guardadas
  Future<List<SavedRecipeResponse>> listSavedRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/saved_recipes/'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => SavedRecipeResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list saved recipes');
    }
  }

  /// POST: Crear una receta guardada
  Future<void> createSavedRecipe(SavedRecipeRequest recipe) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saved_recipes/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create saved recipe');
    }
  }

  /// PUT: Actualizar una receta guardada
  Future<void> updateSavedRecipe(int id, SavedRecipeRequest recipe) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update saved recipe');
    }
  }

  /// DELETE: Eliminar una receta guardada
  Future<void> deleteSavedRecipe(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/saved_recipes/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete saved recipe');
    }
  }

  /// GET: Obtener las recetas más guardadas
  Future<List<Map<String, dynamic>>> getMostSavedRecipes(
      {int limit = 10}) async {
    final response =
        await http.get(Uri.parse('$baseUrl/most_saved?limit=$limit'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch most saved recipes');
    }
  }

  Future<List<SavedRecipeResponse>> getSavedRecipesByKeycloak(
      String keycloakUserId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/saved_recipes/saved-recipes/keycloak/$keycloakUserId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => SavedRecipeResponse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load saved recipes');
    }
  }
}
