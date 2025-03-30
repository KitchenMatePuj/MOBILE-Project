import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceRecommendation {
  static const String _baseUrl = 'http://localhost:8007/recommendations/';

  Future<bool> listRecommendations(String keycloakUserId, List<String> favoriteCategories, List<String> allergies, int cookingTime) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'keycloak_user_id': keycloakUserId,
        'favorite_categories': favoriteCategories,
        'allergies': allergies,
        'cooking_time': cookingTime,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to list recommendations: ${response.body}');
      return false;
    }
  }
}