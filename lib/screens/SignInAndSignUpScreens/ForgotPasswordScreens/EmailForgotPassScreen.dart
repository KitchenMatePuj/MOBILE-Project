import 'package:flutter/material.dart';

class EmailForgotPassScreen extends StatelessWidget {
  const EmailForgotPassScreen({super.key});

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
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Ajuste del padding
        margin: EdgeInsets.all(0), // Sin margen adicional
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
            const SizedBox(height: 8), // Espaciado adicional para claridad
            const Text(
              "Restablecela rápidamente\nsin preocupaciones",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF121212),
              ),
            ),
            const Spacer(flex: 2),
            _buildCodeInput(),
            _buildConfirmButton(context),
            const SizedBox(height: 30), // Espaciado adicional
            const Spacer(flex: 50),
          ],
        ),
      ),
    );
  }

  // Builds the code input field
  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Escriba su Correo Electrónico para enviarle un código de recuperación",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: "Ingrese su correo electrónico por favor",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 19, horizontal: 20),
          ),
        ),
        const SizedBox(height: 20), // Space between email field and next widget
      ],
    );
  }

  // Builds the login button
  Widget _buildConfirmButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575), // Custom color
        ),
        onPressed: () {
          // Redirects to the main screen (Dashboard)
          Navigator.pushNamed(context, '/forgot_password');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enviar Código",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 11),
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
}