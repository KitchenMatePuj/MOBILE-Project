import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Profiles/summary_response.dart';

class SumaryController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SumaryController({required this.baseUrl});

  Future<ProfileSummaryResponse> getProfileSummary(
      String keycloakUserId) async {
    // Leer el token guardado después del login
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No JWT token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profiles/summary/$keycloakUserId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ProfileSummaryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile summary');
    }
  }
}
