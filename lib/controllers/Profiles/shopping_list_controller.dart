import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/Profiles/shopping_list_request.dart';
import '../../models/Profiles/shopping_list_response.dart';

class ShoppingListController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ShoppingListController({required this.baseUrl});

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

  /// GET: Obtener una lista de compras por ID
  Future<ShoppingListResponse> getShoppingList(int shoppingListId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$shoppingListId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ShoppingListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch shopping list');
    }
  }

  /// GET: Listar todas las listas de compras de un perfil
  Future<List<ShoppingListResponse>> listShoppingListsByProfile(
      int profileId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/shopping_lists/profile/$profileId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => ShoppingListResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list shopping lists');
    }
  }

  /// POST: Crear una nueva lista de compras
  Future<ShoppingListResponse> createShoppingList(
      ShoppingListRequest request) async {
    final headers = await _getHeaders(); // ← ¡Aquí!
    final response = await http.post(
      Uri.parse('$baseUrl/shopping_lists/'),
      headers: headers, // ← ¡Aquí!
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ShoppingListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create shopping list: ${response.body}');
    }
  }

  /// PUT: Actualizar una lista de compras
  Future<void> updateShoppingList(
      int listId, Map<String, dynamic> updates) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$listId'),
      headers: headers,
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update shopping list');
    }
  }

  /// DELETE: Eliminar una lista de compras
  Future<void> deleteShoppingList(int listId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$listId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete shopping list');
    }
  }
}
