import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../models/Profiles/ingredientAllery_request.dart';
import '../../models/Profiles/ingredientAllery_response.dart';

class IngredientAllergyController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  IngredientAllergyController({required this.baseUrl});

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

  /// GET: Obtener una alergia por ID
  Future<IngredientAllergyResponse> getAllergy(int allergyId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$allergyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return IngredientAllergyResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch allergy');
    }
  }

  /// GET: Listar todas las alergias de un perfil
  Future<List<IngredientAllergyResponse>> listAllergiesByProfile(
      int profileId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/ingredient_allergies/profile/$profileId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => IngredientAllergyResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list allergies');
    }
  }

  /// POST: Crear una nueva alergia
  Future<void> createAllergy(IngredientAllergyRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/ingredient_allergies/'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Fallo al guardar alergia: ${response.body}');
    }
  }

  /// PUT: Actualizar una alergia
  Future<void> updateAllergy(
      int allergyId, Map<String, dynamic> updates) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$allergyId'),
      headers: headers,
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update allergy');
    }
  }

  /// DELETE: Eliminar una alergia
  Future<void> deleteAllergy(int allergyId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$allergyId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete allergy');
    }
  }
}
