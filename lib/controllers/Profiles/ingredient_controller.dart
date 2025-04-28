import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/Profiles/ingredient_request.dart';
import '../../models/Profiles/ingredient_response.dart';

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

  /// GET: Obtener un ingrediente por ID
  Future<IngredientResponse> getIngredient(int ingredientId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$ingredientId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return IngredientResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch ingredient');
    }
  }

  /// GET: Listar todos los ingredientes de una lista de compras
  Future<List<IngredientResponse>> listIngredientsByShoppingList(
      int shoppingListId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/ingredients/shopping_list/$shoppingListId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => IngredientResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list ingredients');
    }
  }

  /// POST: Crear un nuevo ingrediente
  Future<void> createIngredient(IngredientRequest ingredient) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ingredients/'),
      headers: headers,
      body: json.encode(ingredient.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create ingredient');
    }
  }

  /// PUT: Actualizar un ingrediente
  Future<void> updateIngredient(
      int ingredientId, Map<String, dynamic> updates) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$ingredientId'),
      headers: headers,
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredient');
    }
  }

  /// DELETE: Eliminar un ingrediente
  Future<void> deleteIngredient(int ingredientId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$ingredientId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete ingredient');
    }
  }
}
