import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/shopping_list_request.dart';
import '../../models/Profiles/shopping_list_response.dart';

class ShoppingListController {
  final String baseUrl;

  ShoppingListController({required this.baseUrl});

  /// GET: Obtener una lista de compras por ID
  Future<ShoppingListResponse> getShoppingList(int shoppingListId) async {
    final response = await http.get(Uri.parse('$baseUrl/$shoppingListId'));

    if (response.statusCode == 200) {
      return ShoppingListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch shopping list');
    }
  }

  /// GET: Listar todas las listas de compras de un perfil
  Future<List<ShoppingListResponse>> listShoppingListsByProfile(int profileId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$profileId'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => ShoppingListResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list shopping lists');
    }
  }

  /// POST: Crear una nueva lista de compras
  Future<void> createShoppingList(ShoppingListRequest list) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(list.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create shopping list');
    }
  }

  /// PUT: Actualizar una lista de compras
  Future<void> updateShoppingList(int listId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$listId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update shopping list');
    }
  }

  /// DELETE: Eliminar una lista de compras
  Future<void> deleteShoppingList(int listId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$listId'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete shopping list');
    }
  }
}
