import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/follow_request.dart';
import '../../models/Profiles/follow_response.dart';

class FollowController {
  final String baseUrl;

  FollowController({required this.baseUrl});

  /// GET: Obtener lista de seguidores de un perfil
  Future<List<FollowResponse>> listFollowers(int profileId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/follows/followers/$profileId'), // ✅ usa "/follows/"
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
    final response = await http.get(
      Uri.parse('$baseUrl/follows/followed/$profileId'), // ✅ usa "/follows/"
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
    final response =
        await http.get(Uri.parse('$baseUrl/followed-keycloak-ids/$profileId'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to fetch followed keycloak user ids');
    }
  }

  /// POST: Crear relación de seguimiento
  Future<void> createFollow(FollowRequest follow) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(follow.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to follow profile');
    }
  }

  /// DELETE: Eliminar relación de seguimiento
  Future<void> deleteFollow(int followerId, int followedId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl?follower_id=$followerId&followed_id=$followedId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to unfollow profile');
    }
  }
}
