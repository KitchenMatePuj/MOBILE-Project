import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/profile_request.dart';
import '../../models/Profiles/profile_response.dart';

class ProfileController {
  final String baseUrl;

  ProfileController({required this.baseUrl});

  /// GET: Obtener perfil por keycloak_user_id
  Future<ProfileResponse> getProfile(String keycloakUserId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/profiles/$keycloakUserId'));

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// GET: Obtener perfil por profile_id
  Future<ProfileResponse> getProfilebyid(String profile_id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/profiles/id/$profile_id'));

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// GET: Listar todos los perfiles
  Future<List<ProfileResponse>> listProfiles() async {
    final response = await http.get(Uri.parse('$baseUrl/profiles/'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => ProfileResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list profiles');
    }
  }

  /// POST: Crear perfil
  Future<ProfileResponse> createProfile(ProfileRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profiles/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear perfil: ${response.body}');
    }
  }

  /// PUT: Actualizar perfil
  Future<void> updateProfile(
      String keycloakUserId, ProfileRequest updatedProfile) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profiles/$keycloakUserId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedProfile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  /// DELETE: Eliminar perfil
  Future<void> deleteProfile(String keycloakUserId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/profiles/$keycloakUserId'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete profile');
    }
  }
}
