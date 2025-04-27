import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Recipes/recipe_steps_request.dart';
import '../../models/Recipes/recipe_steps_response.dart';

class RecipeStepController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RecipeStepController({required this.baseUrl});

  /// Función privada para agregar Headers con Authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No JWT token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Crear un nuevo paso de receta (POST /recipes/{recipeId}/steps)
  Future<RecipeStepResponse> createStep(
      int recipeId, RecipeStepRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/recipes/$recipeId/steps/'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RecipeStepResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create recipe step');
    }
  }

  /// Obtener todos los pasos de una receta (GET /recipes/{recipeId}/steps)
  Future<List<RecipeStepResponse>> fetchSteps(int recipeId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/$recipeId/steps/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => RecipeStepResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load steps');
    }
  }

  /// Obtener un paso específico de una receta (GET /recipes/{recipeId}/steps/{stepId})
  Future<RecipeStepResponse> getStepById(int recipeId, int stepId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/$recipeId/steps/$stepId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return RecipeStepResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Step not found');
    }
  }

  /// Actualizar un paso de receta (PUT /recipes/{recipeId}/steps/{stepId})
  Future<RecipeStepResponse> updateStep(
      int recipeId, int stepId, RecipeStepRequest request) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/recipes/$recipeId/steps/$stepId'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return RecipeStepResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update step');
    }
  }

  /// Eliminar un paso de receta (DELETE /recipes/{recipeId}/steps/{stepId})
  Future<void> deleteStep(int recipeId, int stepId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/recipes/$recipeId/steps/$stepId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete step');
    }
  }
}
