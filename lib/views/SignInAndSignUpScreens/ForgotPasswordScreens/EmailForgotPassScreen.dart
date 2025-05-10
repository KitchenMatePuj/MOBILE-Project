import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/reset_password_request.dart';
import 'dart:developer';

class EmailForgotPassScreen extends StatefulWidget {
  const EmailForgotPassScreen({super.key});

  @override
  _EmailForgotPassScreenState createState() => _EmailForgotPassScreenState();
}

class _EmailForgotPassScreenState extends State<EmailForgotPassScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _canSendEmail = false;
  bool _isLoading = false;
  final authBaseUrl = dotenv.env['AUTH_URL'] ?? '';
  final Stopwatch _stopwatch = Stopwatch();
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(baseUrl: authBaseUrl);

    _stopwatch.start();
  }

  void _validateEmail() {
    final email = _emailController.text;

    setState(() {
      _emailError = _isValidEmail(email)
          ? null
          : 'Por favor ingrese un correo electrónico válido';
      _canSendEmail = _emailError == null;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendResetPasswordEmail() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final request = ResetPasswordRequest(email: email);

    try {
      final message = await _authController.resetPassword(request);
      setState(() {
        _isLoading = false;
      });

      // Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Se ha enviado su correo correctamente: $message"),
          backgroundColor: Colors.green,
        ),
      );

      // Redirigir al login después de un breve retraso
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamed(context, '/login');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Mostrar SnackBar de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se ha podido enviar su correo. Asegúrese de escribir el correo con el que se registró, por favor.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        print('⏱ EmailForgotPassScreen: ${_stopwatch.elapsedMilliseconds} ms');
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurar Contraseña'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            const Text(
              "¿Olvidaste tu\nContraseña?,",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Restablecela rápidamente\nsin preocupaciones",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF121212),
              ),
            ),
            const Spacer(flex: 2),
            _buildEmailInput(),
            if (_emailError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _emailError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            _buildConfirmButton(context),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 30),
            const Spacer(flex: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Escriba su Correo Electrónico para enviarle un correo de recuperación",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Ingrese su correo electrónico por favor",
            errorText: _emailError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateEmail(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: _canSendEmail ? _sendResetPasswordEmail : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        const Text(
          "Enviar Correo",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 11),
        const Icon(
          Icons.arrow_forward,
          size: 20,
          color: Colors.white,
        ),
          ],
        ),
      ),
        );
  }
}
