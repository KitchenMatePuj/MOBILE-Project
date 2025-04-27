import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Recommendations/recommendation_request.dart';
import '../../models/Recommendations/recommendation_response.dart';

class RecommendationsController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RecommendationsController({required this.baseUrl});

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

  Future<List<RecommendationResponse>> fetchRecommendations(
      RecommendationRequest request) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/recommendations/');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => RecommendationResponse.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error while fetching recommendations: $e');
    }
  }
}
