import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/profile_request.dart';
import '../../models/Profiles/profile_response.dart';

class ProfileController {
  static const String _baseUrl = 'http://localhost:8001/profiles'; 

  /// GET: Obtener perfil por keycloak_user_id
  Future<ProfileResponse> getProfile(String keycloakUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$keycloakUserId'));

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// GET: Obtener perfil por profile_id
  Future<ProfileResponse> getProfilebyid(String profile_id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$profile_id'));

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// GET: Listar todos los perfiles
  Future<List<ProfileResponse>> listProfiles() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => ProfileResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list profiles');
    }
  }

  /// POST: Crear perfil
  Future<void> createProfile(ProfileRequest profile) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profile.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create profile');
    }
  }

  /// PUT: Actualizar perfil
  Future<void> updateProfile(String keycloakUserId, ProfileRequest updatedProfile) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$keycloakUserId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedProfile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  /// DELETE: Eliminar perfil
  Future<void> deleteProfile(String keycloakUserId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$keycloakUserId'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete profile');
    }
  }
}