import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Recommendations/recommendation_request.dart';
import '../../models/Recommendations/recommendation_response.dart';

class RecommendationsController {
  final String baseUrl;

  RecommendationsController({required this.baseUrl});

  Future<List<RecommendationResponse>> fetchRecommendations(RecommendationRequest request) async {
    final url = Uri.parse('$baseUrl/recommendations/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RecommendationResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error while fetching recommendations: $e');
    }
  }
}