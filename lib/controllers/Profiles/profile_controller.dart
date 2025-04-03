import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/Profiles/profile_request.dart';
import '../../models/Profiles/profile_response.dart';

class ProfileController {
  final String baseUrl = dotenv.env['PROFILE_URL'];

  ProfileController({required this.baseUrl});

  /// GET: Obtener perfil por keycloak_user_id
  Future<ProfileResponse> getProfile(String keycloakUserId) async {
    final response = await http.get(Uri.parse('$baseUrl/$keycloakUserId'));

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// GET: Listar todos los perfiles
  Future<List<ProfileResponse>> listProfiles() async {
    final response = await http.get(Uri.parse(baseUrl));

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
      Uri.parse(baseUrl),
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
      Uri.parse('$baseUrl/$keycloakUserId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedProfile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  /// DELETE: Eliminar perfil
  Future<void> deleteProfile(String keycloakUserId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$keycloakUserId'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete profile');
    }
  }
}

