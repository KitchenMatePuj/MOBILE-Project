import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../controllers/signup_controller.dart';
import '../../models/user_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aliasController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isEmailValid = true;
  bool _canContinue = false;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _emailError;

  late SignUpController _controller;

  @override
  void initState() {
    super.initState();
    final userModel = UserModel(fullName: '', email: '', alias: '', password: '');
    _controller = SignUpController(userModel: userModel);
  }

  void _validateForm() {
    final fullName = _fullNameController.text;
    final email = _emailController.text;
    final alias = _aliasController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _emailError = _controller.validateEmail(email);
      _isEmailValid = _emailError == null;

      _passwordError = _controller.validatePassword(password);
      _isPasswordValid = _passwordError == null;

      _confirmPasswordError = _controller.validateConfirmPassword(password, confirmPassword);
      _isConfirmPasswordValid = _confirmPasswordError == null;

      _canContinue = _controller.canContinue(fullName, email, alias, password, confirmPassword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creación de Cuenta'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Crear una Cuenta",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Permítanos ayudarle con la creación de su cuenta, no le llevará mucho tiempo.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 20),
                _buildUsersNameInput(),
                _buildEmailInput(),
                _buildUsersAliasNameInput(),
                _buildPasswordInput(),
                _buildConfirmPasswordInput(),
                _buildLoginButton(context),
                const SizedBox(height: 30),
                _buildSignUpWith(context),
                _buildRegisterPrompt(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nombre Completo (privado)",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            hintText: "Escribe tu nombre completo",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateForm(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Correo Electrónico",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Escribe tu correo electrónico",
            errorText: _emailError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateForm(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildUsersAliasNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nombre de Usuario (público)",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _aliasController,
          decoration: InputDecoration(
            hintText: "Escribe tu nombre de usuario",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateForm(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contraseña",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _passwordController,
          obscureText: true,
          onChanged: (value) => _validateForm(),
          decoration: InputDecoration(
            hintText: "Escribe tu contraseña",
            errorText: _passwordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildConfirmPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirma Contraseña",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          onChanged: (value) => _validateForm(),
          decoration: InputDecoration(
            hintText: "Escribe nuevamente tu contraseña",
            errorText: _confirmPasswordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: _canContinue
            ? () {
                Navigator.pushNamed(context, '/nutrition_form');
              }
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Continuar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 11),
            Icon(  // Uses an Icon instead of an asset
              Icons.arrow_forward,  // Forward arrow
              size: 20,  // Icon size
              color: Colors.white,  // Icon color (adjustable)
            ),
          ],
        ),
      ),
    );
  }

  // Builds the "Sign Up with" section
  Widget _buildSignUpWith(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Flexible(
                child: Divider(
                  color: Color(0xFFD9D9D9),
                  thickness: 1,
                  endIndent: 12,
                ),
              ),
              Text(
                "O crear cuenta mediante",
                style: TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Flexible(
                child: Divider(
                  color: Color(0xFFD9D9D9),
                  thickness: 1,
                  indent: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(  // Row to display icons together
            mainAxisSize: MainAxisSize.min,
            children: [
              // Google Icon with GestureDetector
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/nutrition_form');
                },
                child: Image.asset(
                  'assets/icons/googleIcon.png',
                  width: 55,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20),  // Space between the icons
              // Facebook Icon with GestureDetector
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/nutrition_form');
                },
                child: Image.asset(
                  'assets/icons/facebookIcon.png', 
                  width: 55,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15), // Space between email field and next widget
        ],
      ),
    );
  }

  // Builds the register prompt text
  Widget _buildRegisterPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "¿Ya estás registrado? ",
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: "Inicia Sesión aquí",
              style: const TextStyle(color: Color(0xFFFF9C00)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Redirects to the "create account" screen
                  Navigator.pushNamed(context, '/login');
                },
            ),
          ],
        ),
      ),
    );
  }
}