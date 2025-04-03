import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kitchenmate/models/Recipes/comments_request.dart';
import 'package:kitchenmate/models/Recipes/comments_response.dart';

class CommentController {
  final String baseUrl= dotenv.env['RECIPES_URL'];

  CommentController({required this.baseUrl});

  /// Agregar un comentario a una receta (POST /recipes/{recipeId}/comments)
  Future<CommentResponse> addComment(int recipeId, CommentRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recipes/$recipeId/comments'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await http.get(Uri.parse('$baseUrl/recipes/$recipeId/comments'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => CommentResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  /// Eliminar un comentario por ID (DELETE /recipes/{recipeId}/comments/{commentId})
  Future<void> deleteComment(int recipeId, int commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/recipes/$recipeId/comments/$commentId'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }
}
