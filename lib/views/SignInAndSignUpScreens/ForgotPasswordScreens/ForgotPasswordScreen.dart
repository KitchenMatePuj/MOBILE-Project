import 'package:flutter/material.dart';
import '/controllers/password_reset_controller.dart';
import '/models/password_reset_model.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;
  bool _canResetPassword = false;

  late PasswordResetController _controller;

  @override
  void initState() {
    super.initState();
    final model = PasswordResetModel();
    _controller = PasswordResetController(model: model);
  }

  void _validateForm() {
    final code = _codeController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = _controller.validatePassword(newPassword);
      _confirmPasswordError = _controller.validateConfirmPassword(newPassword, confirmPassword);
      _canResetPassword = _controller.canResetPassword(code, newPassword, confirmPassword);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 10),
                const Text(
                  "¿Olvidaste tu\nContraseña?",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Restablécela rápidamente\nsin preocupaciones",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCodeInput(),
                _buildNewPasswordInput(),
                _buildConfirmNewPasswordInput(),
                _buildConfirmButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return _buildInputField("Escriba el código enviado a su correo", "Ingrese el código por favor", false);
  }

  Widget _buildNewPasswordInput() {
    return _buildInputField("Escriba una nueva contraseña", "Ingrese nueva Contraseña", true);
  }

  Widget _buildConfirmNewPasswordInput() {
    return _buildInputField("Vuelve a escribir la Contraseña", "Vuelva a Ingresar Nueva Contraseña", true);
  }

  Widget _buildInputField(String label, String hint, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: isPassword ? (label.contains("Vuelve") ? _confirmPasswordController : _newPasswordController) : _codeController,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            errorText: isPassword ? (label.contains("Vuelve") ? _confirmPasswordError : _passwordError) : null,
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
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: _canResetPassword
            ? () {
                _showSuccessDialog(context);
              }
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Confirmar",
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Contraseña actualizada",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Su contraseña ha sido actualizada correctamente.",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF129575),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}