import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Recipes/ingredients_request.dart';
import '../../models/Recipes/ingredients_response.dart';

class IngredientController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  IngredientController({required this.baseUrl});

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

  /// Crear un nuevo ingrediente (POST /ingredients)
  Future<IngredientResponse> createIngredient(IngredientRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ingredients/'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return IngredientResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create ingredient');
    }
  }

  /// Obtener un ingrediente por ID (GET /ingredients/{id})
  Future<IngredientResponse> getIngredientById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/ingredients/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return IngredientResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ingredient not found');
    }
  }

  /// GET: Fetch ingredients without Authorization
  Future<List<IngredientResponse>> fetchPublicIngredients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ingredients/'),
      headers: {'Content-Type': 'application/json'}, // sin Authorization
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => IngredientResponse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch public ingredients');
    }
  }

  /// Obtener todos los ingredientes (GET /ingredients)
  Future<List<IngredientResponse>> fetchIngredients() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/ingredients/');
    final response = await http.get(url, headers: headers);

    print('URL: $url');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((ingredientJson) => IngredientResponse.fromJson(ingredientJson))
          .toList();
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  /// Actualizar un ingrediente existente (PUT /ingredients/{id})
  Future<IngredientResponse> updateIngredient(
      int id, IngredientRequest request) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/ingredients/$id'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return IngredientResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update ingredient');
    }
  }

  /// Eliminar un ingrediente por ID (DELETE /ingredients/{id})
  Future<void> deleteIngredient(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/ingredients/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete ingredient');
    }
  }

  /// ← NUEVO: devuelve **solo** los ingredientes de una receta
  Future<List<IngredientResponse>> getIngredientsByRecipe(int recipeId) async {
    final url = Uri.parse('$baseUrl/ingredients/by-recipe/$recipeId');
    final res = await http
        .get(url)
        .timeout(const Duration(seconds: 6)); // -- timeout breve

    if (res.statusCode != 200) {
      throw Exception(
          'Error ${res.statusCode} al obtener ingredientes de la receta');
    }

    // 👉 parse en hilo aislado (compute)
    return compute(_parseIngredients, res.body);
  }

  // ---------- helpers ----------
  static List<IngredientResponse> _parseIngredients(String body) {
    final list = jsonDecode(body) as List;
    return list
        .map((j) => IngredientResponse.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
