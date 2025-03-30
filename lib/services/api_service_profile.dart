import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8001/profiles/';

  Future<bool> createProfile(String firstName, String lastName, String email) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'keycloak_user_id': '12', // Placeholder value
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': '21312', // Default to empty string
        'account_status': 'active', // Default to 'active'
        'profile_photo': 'dawdadwa', // Default to empty string
        'cooking_time': 0, // Default to zero
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create profile: ${response.body}');
      return false;
    }
  }
}