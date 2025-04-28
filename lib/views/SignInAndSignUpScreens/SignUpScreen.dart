// ===========================
// SignUpScreen.dart (flujo corregido sin nutritionController)
// ===========================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/ingredient_allergy_controller.dart';
import 'package:mobile_kitchenmate/controllers/authentication/auth_controller.dart';
import 'package:mobile_kitchenmate/models/Profiles/ingredientAllery_request.dart';
import 'package:mobile_kitchenmate/models/authentication/register_request.dart';
import '../../controllers/profiles/profile_controller.dart';
import '../../models/Profiles/profile_request.dart';
import '../../models/Profiles/profile_response.dart';
import '../../controllers/Recipes/ingredients.dart';
import '../../models/Recipes/ingredients_response.dart';
import '../../models/Profiles/ingredientAllery_response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cookingTimeController = TextEditingController();

  bool _isFirstNameValid = true;
  bool _isLastNameValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isEmailValid = true;
  bool _isRegistering = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _emailError;

  late AuthController _authController;
  late ProfileController _profileController;
  late IngredientController _ingredientController;
  late IngredientAllergyController _ingredientAllergyController;

  List<String> _selectedIngredients = [];
  List<String> _allIngredients = [];

  bool _canContinue = false;

  final authBaseUrl = dotenv.env['AUTH_URL'] ?? '';
  final profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final recipesBaseUrl = dotenv.env['RECIPE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _authController = AuthController(baseUrl: authBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _ingredientController = IngredientController(baseUrl: recipesBaseUrl);
    _ingredientAllergyController =
        IngredientAllergyController(baseUrl: profileBaseUrl);
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    try {
      List<IngredientResponse> ingredients =
          await _ingredientController.fetchPublicIngredients();
      setState(() {
        _allIngredients =
            ingredients.map((ingredient) => ingredient.name).toSet().toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al cargar ingredientes: ${e.toString()}')),
      );
    }
  }

  Future<void> _createAccount() async {
    if (_isRegistering) return;
    _isRegistering = true;

    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final phone = _phoneController.text;
      final cookingTime = int.tryParse(_cookingTimeController.text) ?? 30;

      // 1. Primero registramos el usuario en Keycloak
      final jwt = await _authController.registerUser(
        email: email,
        username: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // 2. Decodificamos el token para extraer el keycloakUserId
      final decodedToken = JwtDecoder.decode(jwt);
      final keycloakUserId = decodedToken['sub'];

      // 3. Preparamos el request para el perfil
      final profileRequest = ProfileRequest(
        keycloakUserId: keycloakUserId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        accountStatus: 'active',
        cookingTime: cookingTime,
      );

      // 4. Crear perfil usando PUBLIC create (sin autenticación)
      final profileResponse =
          await _profileController.createProfile(profileRequest);

      // 5. Crear las alergias seleccionadas (requiere ID del perfil)
      for (final ingredientName in _selectedIngredients) {
        final allergyRequest = IngredientAllergyRequest(
          profileId: profileResponse.profileId,
          allergyName: ingredientName,
        );
        await _ingredientAllergyController.createAllergy(allergyRequest);
      }

      // 6. Ir al login después de éxito
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear cuenta: $e')),
      );
    } finally {
      _isRegistering = false;
    }
  }

  void _validateForm() {
    final fullName = _firstNameController.text.trim();
    final alias = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final phone = _phoneController.text.trim();
    final cookingTimeText = _cookingTimeController.text.trim();
    final cookingTime = int.tryParse(cookingTimeText);

    setState(() {
      _firstNameError = fullName.isEmpty ? 'Nombre es requerido' : null;
      _isFirstNameValid = _firstNameError == null;

      _lastNameError = alias.isEmpty ? 'Apellido es requerido' : null;
      _isLastNameValid = _lastNameError == null;

      _emailError = email.isEmpty ? 'Correo es requerido' : null;
      _isEmailValid = _emailError == null;

      _passwordError = password.isEmpty ? 'Contraseña es requerida' : null;
      _isPasswordValid = _passwordError == null;

      _confirmPasswordError = confirmPassword != password
          ? 'Las contraseñas deben coincidir'
          : null;
      _isConfirmPasswordValid = _confirmPasswordError == null;

      // Nueva lógica para habilitar el botón
      _canContinue = _isFirstNameValid &&
          _isLastNameValid &&
          _isEmailValid &&
          _isPasswordValid &&
          _isConfirmPasswordValid &&
          phone.isNotEmpty &&
          cookingTime != null &&
          cookingTime > 0;
    });
  }

  void _onIngredientSelected(String ingredient, bool selected) {
    setState(() {
      if (selected) {
        _selectedIngredients.add(ingredient);
      } else {
        _selectedIngredients.remove(ingredient);
      }
      _validateForm();
    });
  }

  Widget _buildIngredientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _allIngredients.map((ingredient) {
        return CheckboxListTile(
          title: Text(ingredient),
          value: _selectedIngredients.contains(ingredient),
          onChanged: (selected) {
            _onIngredientSelected(ingredient, selected ?? false);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creación de Cuenta'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListView(
          children: [
            const Text(
              "Crear una Cuenta",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "Permítanos ayudarle con la creación de su cuenta, no le llevará mucho tiempo.",
              style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
            ),
            const SizedBox(height: 20),
            _buildTextInput(_firstNameController, 'Nombres Completos'),
            _buildTextInput(_lastNameController, 'Apellidos Completos'),
            _buildTextInput(_emailController, 'Correo Electrónico'),
            _buildTextInput(_phoneController, 'Teléfono'),
            _buildTextInput(_cookingTimeController, 'Tiempo de cocina (min)',
                keyboardType: TextInputType.number),
            _buildTextInput(_passwordController, 'Contraseña', obscure: true),
            _buildTextInput(_confirmPasswordController, 'Confirmar Contraseña',
                obscure: true),
            const SizedBox(height: 20),
            const Text('Selecciona ingredientes a los que eres alérgico:'),
            Wrap(
              spacing: 8.0,
              children: _allIngredients.map((ingredient) {
                final isSelected = _selectedIngredients.contains(ingredient);
                return FilterChip(
                  label: Text(ingredient),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    _onIngredientSelected(ingredient, selected);
                  },
                  selectedColor: const Color(0xFF129575),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _canContinue ? _createAccount : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF129575),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("Crear Cuenta",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(width: 11),
                  Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF121212))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD9D9D9), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
