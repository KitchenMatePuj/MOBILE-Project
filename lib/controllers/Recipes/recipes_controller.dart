import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_kitchenmate/models/Recipes/full_recipe_response.dart';
import '../../models/Recipes/recipes_request.dart';
import '../../models/Recipes/recipes_response.dart';

class RecipeController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<RecipeResponse> allRecipes = [];

  RecipeController({required this.baseUrl});

  /* ──────────────────────────────────────────────────────────── */
  /*  Helpers                                                    */
  /* ──────────────────────────────────────────────────────────── */

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No JWT token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  /* ──────────────────────────────────────────────────────────── */
  /*  CRUD                                                       */
  /* ──────────────────────────────────────────────────────────── */

  Future<RecipeResponse> createRecipe(RecipeRequest request) async {
    final jsonBody = jsonEncode(request.toJson());

    // 🔎 print de entrada
    debugPrint('📤 CREATE[REQ]  title="${request.title}" '
        'codeUnits=${request.title.codeUnits}');
    debugPrint('📤 CREATE[REQ]  raw = $jsonBody');

    final response = await http.post(
      Uri.parse('$baseUrl/recipes/'),
      headers: await _getHeaders(),
      body: jsonBody,
    );
    debugPrint('📥 CREATE ← status ${response.statusCode}');
    debugPrint('📥 CREATE ← body        = ${response.body}'); // 🎯 1B

    debugPrint('📥 CREATE[RES]  status=${response.statusCode}');
    debugPrint('📥 CREATE[RES]  body  = ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final parsed = RecipeResponse.fromJson(jsonDecode(response.body));
      debugPrint('📥 CREATE[RES]  title="${parsed.title}" '
          'codeUnits=${parsed.title.codeUnits}');
      return parsed;
    }
    throw Exception('Failed to create recipe '
        '${response.statusCode} ${response.body}');
  }

  Future<RecipeResponse> getRecipeById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return RecipeResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Recipe not found');
  }

  Future<List<RecipeResponse>> fetchRecipes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<List<RecipeResponse>> searchRecipes(
      {String? title, int? cookingTime, String? ingredient}) async {
    final queryParams = {
      if (title != null) 'title': title,
      if (cookingTime != null) 'cooking_time': cookingTime.toString(),
      if (ingredient != null) 'ingredient': ingredient,
    };

    final uri = Uri.parse('$baseUrl/recipes/search')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to search recipes');
  }

  Future<RecipeResponse> updateRecipe(int id, RecipeRequest request) async {
    final jsonBody = jsonEncode(request.toJson());
    debugPrint('📤 [Flutter→API] body = $jsonBody');
    final response = await http.put(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: await _getHeaders(),
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      return RecipeResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update recipe');
  }

  Future<void> deleteRecipe(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: await _getHeaders(),
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete recipe');
    }
  }

  /* ──────────────────────────────────────────────────────────── */
  /*  Queries / Stats                                            */
  /* ──────────────────────────────────────────────────────────── */

  Future<List<RecipeResponse>> getRecipesByUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/user/$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to get recipes by user');
  }

  Future<List<RecipeResponse>> filterRecipesByRating(
      double minRating, double maxRating) async {
    final uri = Uri.parse(
        '$baseUrl/recipes/ratings/filter?min_rating=$minRating&max_rating=$maxRating');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeResponse.fromJson(e)).toList();
    }
    throw Exception('Failed to filter recipes by rating');
  }

  Future<List<Map<String, dynamic>>> getCookingTimeStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/statistics/cooking-time'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to get cooking time statistics');
  }

  Future<int> getTotalRecipeCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/statistics/total'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return json['total_recipes'];
    }
    throw Exception('Failed to get total recipe count');
  }

  /* ──────────────────────────────────────────────────────────── */
  /*  Partial updates (image / video)                            */
  /* ──────────────────────────────────────────────────────────── */

  Future<void> updateRecipeVideo(int recipeId, String videoUrl) async {
    final actual = await getRecipeById(recipeId);
    debugPrint('👁️ VIDEO  pre-title  = ${actual.title}');

    final body = {
      'category_id': actual.categoryId,
      'title': actual.title,
      'created_at': actual.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'cooking_time': actual.cookingTime,
      'food_type': actual.foodType,
      'total_portions': actual.totalPortions,
      'keycloak_user_id': actual.keycloakUserId,
      'rating_avg': actual.ratingAvg,
      'image_url': actual.imageUrl,
      'video_url': videoUrl, // NEW
    };

    final resp = await http.put(
      Uri.parse('$baseUrl/recipes/$recipeId'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    debugPrint('📥 VIDEO ← status ${resp.statusCode}');

    if (resp.statusCode != 200) {
      throw Exception('PUT failed: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<void> updateRecipeImage(int recipeId, String imageUrl) async {
    final actual = await getRecipeById(recipeId);

    debugPrint('👁️ IMAGE pre-title  = ${actual.title}');

    final body = {
      'category_id': actual.categoryId,
      'title': actual.title,
      'created_at': actual.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'cooking_time': actual.cookingTime,
      'food_type': actual.foodType,
      'total_portions': actual.totalPortions,
      'keycloak_user_id': actual.keycloakUserId,
      'rating_avg': actual.ratingAvg,
      'image_url': imageUrl,
      'video_url': actual.videoUrl, // NEW: preserve video
    };

    debugPrint('📤 IMAGE → body  = ${jsonEncode(body)}');

    final resp = await http.put(
      Uri.parse('$baseUrl/recipes/$recipeId'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    debugPrint('📥 IMAGE ← status ${resp.statusCode}');

    if (resp.statusCode != 200) {
      throw Exception('PUT failed: ${resp.statusCode} ${resp.body}');
    }
  }

  /* ──────────────────────────────────────────────────────────── */
  /*  Full recipe helper                                         */
  /* ──────────────────────────────────────────────────────────── */

  Future<FullRecipeResponse> getFullRecipe(int id) async {
    final res = await http
        .get(Uri.parse('$baseUrl/recipes/$id/full'))
        .timeout(const Duration(seconds: 6));

    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al obtener receta completa');
    }
    return compute(_parseFullRecipe, res.body); // isolate
  }

  static FullRecipeResponse _parseFullRecipe(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    return FullRecipeResponse.fromJson(json);
  }
}
