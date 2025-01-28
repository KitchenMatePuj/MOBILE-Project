import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurar Contraseña'), backgroundColor: const Color(0xFF129575)),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(30, 14, 13, 8),
        margin: EdgeInsets.all(0),
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
            const Spacer(flex: 1),
            const Text(
              "Restablecela rápidamente\nsin preocupaciones",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF121212),
              ),
            ),
            const Spacer(flex: 2),
            _buildNewPasswordInput(),
            _buildConfirmNewPasswordInput(),
            _buildConfirmButton(context),
            // Adds space between the button and the message
            const SizedBox(height: 30), 
            const Spacer(flex: 20),
            Center(
              child: Container(
                width: 135,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Builds the email input field
  Widget _buildNewPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Escriba una nueva contraseña",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Ingrese nueva Contraseña",
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

  // Builds the password input field
  Widget _buildConfirmNewPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vuelve a escribir la Constraseña",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Vuelva a Ingresar Nueva Contraseña",
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
        const SizedBox(height: 26), // Space between password field and next widget
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
          Navigator.pushNamed(context, '/dashboard');
        },
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

