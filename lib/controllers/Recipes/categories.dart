import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Recipes/categories_request.dart';
import '../../models/Recipes/categories_response.dart';

class CategoryController {
  final String baseUrl;

  CategoryController({required this.baseUrl});

  /// Obtener todas las categorías (GET /categories)
  Future<List<CategoryResponse>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => CategoryResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Obtener una categoría por ID (GET /categories/{id})
  Future<CategoryResponse> getCategoryById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/categories/$id'));

    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Category not found');
    }
  }

  /// Crear una nueva categoría (POST /categories)
  Future<CategoryResponse> createCategory(CategoryRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  /// Actualizar una categoría existente (PUT /categories/{id})
  Future<CategoryResponse> updateCategory(int id, CategoryRequest request) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categories/$id'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}
