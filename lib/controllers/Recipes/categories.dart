import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Recipes/categories_request.dart';
import '../../models/Recipes/categories_response.dart';

class CategoryController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  CategoryController({required this.baseUrl});

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

  /// Obtener todas las categorías (GET /categories)
  Future<List<CategoryResponse>> fetchCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => CategoryResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Obtener una categoría por ID (GET /categories/{id})
  Future<CategoryResponse> getCategoryById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Category not found');
    }
  }

  /// Crear una nueva categoría (POST /categories)
  Future<CategoryResponse> createCategory(CategoryRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  /// Actualizar una categoría existente (PUT /categories/{id})
  Future<CategoryResponse> updateCategory(
      int id, CategoryRequest request) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update category');
    }
  }

  /// Eliminar una categoría (DELETE /categories/{id})
  Future<void> deleteCategory(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}
