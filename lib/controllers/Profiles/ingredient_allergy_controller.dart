import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/ingredientAllery_request.dart';
import '../../models/Profiles/ingredientAllery_response.dart';

class IngredientAllergyController {
  final String baseUrl;

  IngredientAllergyController({required this.baseUrl});

  /// GET: Obtener una alergia por ID
  Future<IngredientAllergyResponse> getAllergy(int allergyId) async {
    final response = await http.get(Uri.parse('$baseUrl/$allergyId'));

    if (response.statusCode == 200) {
      return IngredientAllergyResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch allergy');
    }
  }

  /// GET: Listar todas las alergias de un perfil
  Future<List<IngredientAllergyResponse>> listAllergiesByProfile(int profileId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$profileId'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => IngredientAllergyResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to list allergies');
    }
  }

  /// POST: Crear una nueva alergia
  Future<void> createAllergy(IngredientAllergyRequest allergy) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(allergy.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create allergy');
    }
  }

  /// PUT: Actualizar una alergia
  Future<void> updateAllergy(int allergyId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$allergyId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update allergy');
    }
  }

  /// DELETE: Eliminar una alergia
  Future<void> deleteAllergy(int allergyId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$allergyId'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete allergy');
    }
  }
}
