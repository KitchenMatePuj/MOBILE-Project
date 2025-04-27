import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/Profiles/follow_request.dart';
import '../../models/Profiles/follow_response.dart';

class FollowController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  FollowController({required this.baseUrl});

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

  /// GET: Obtener lista de seguidores de un perfil
  Future<List<FollowResponse>> listFollowers(int profileId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/follows/followers/$profileId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => FollowResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch followers');
    }
  }

  /// GET: Obtener lista de seguidos por un perfil
  Future<List<FollowResponse>> listFollowed(int profileId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/follows/followed/$profileId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => FollowResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch followed profiles');
    }
  }

  /// GET: Obtener keycloak_user_ids de los perfiles que sigue un usuario
  Future<List<String>> getFollowedKeycloakUserIds(int profileId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/follows/followed-keycloak-ids/$profileId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to fetch followed keycloak user ids');
    }
  }

  /// POST: Crear relación de seguimiento
  Future<void> createFollow(FollowRequest follow) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/follows/'),
      headers: headers,
      body: json.encode(follow.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = response.body;
      throw Exception('Failed to follow profile: $errorBody');
    }
  }

  /// DELETE: Eliminar relación de seguimiento
  Future<void> deleteFollow(int followerId, int followedId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/follows/?follower_id=$followerId&followed_id=$followedId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to unfollow profile');
    }
  }
}
