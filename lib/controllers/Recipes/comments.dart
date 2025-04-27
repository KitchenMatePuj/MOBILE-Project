import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Recipes/comments_request.dart';
import '../../models/Recipes/comments_response.dart';

class CommentController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  CommentController({required this.baseUrl});

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

  /// Agregar un comentario a una receta (POST /recipes/{recipeId}/comments)
  Future<CommentResponse> addComment(
      int recipeId, CommentRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/recipes/$recipeId/comments'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }

  /// Obtener todos los comentarios de una receta (GET /recipes/{recipeId}/comments)
  Future<List<CommentResponse>> fetchComments(int recipeId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/recipes/$recipeId/comments'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => CommentResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  /// Eliminar un comentario por ID (DELETE /recipes/{recipeId}/comments/{commentId})
  Future<void> deleteComment(int recipeId, int commentId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/recipes/$recipeId/comments/$commentId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }
}
