import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_kitchenmate/models/authentication/reset_password_request.dart';
import '../../models/authentication/register_request.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '../../models/authentication/login_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  AuthController({required this.baseUrl});

  Future<String> registerUser({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['keycloak_user_id'];
    } else {
      throw Exception('Fallo el registro en Keycloak: ${response.body}');
    }
  }

  Future<LoginResponse> loginUser(advanced.LoginRequest request) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<String> resetPassword(ResetPasswordRequest request) async {
    final url = Uri.parse('$baseUrl/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Reset password failed: ${response.body}');
    }
  }

  // Guardar el token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Leer el token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Eliminar el token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<void> checkToken() async {
    String? token = await getToken();
    if (token != null) {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);
      print("Usuario: ${decoded['sub']}");
      print("Expira en: ${JwtDecoder.getExpirationDate(token)}");
    } else {
      print("No hay token guardado");
    }
  }

  Future<String> getKeycloakUserId() async {
    String? token = await getToken();
    Map<String, dynamic> decoded = JwtDecoder.decode(token!);
    return decoded['sub'];
  }
}
