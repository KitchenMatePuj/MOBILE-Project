import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creación de Cuenta'),
      backgroundColor: const Color(0xFF129575),), 
      body: Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    color: Colors.white,
  ),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Ajuste del padding
  margin: EdgeInsets.all(0), // Sin margen adicional
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda los elementos
    children: [
      const Spacer(flex: 4),
      const Text(
        "Crear una Cuenta",
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 8), // Espaciado adicional para claridad
      const Text(
        "Permítanos ayudarle con la creación de su cuenta, no le llevará mucho tiempo.",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF121212),
        ),
      ),
      const Spacer(flex: 4),
      _buildUsersNameInput(),
      _buildEmailInput(),
      _buildPasswordInput(),
      _buildConfirmPasswordInput(),
      _buildLoginButton(context),
      const SizedBox(height: 30), // Espaciado adicional
      _buildSignUpWith(context),
      _buildRegisterPrompt(context),
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
      ),
    ],
  ),
),

    );
  }

  // Builds the user's full name input field
  Widget _buildUsersNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nombre Completo",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: "Excribe tu nombre completo",
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
        const SizedBox(height: 15), // Space
      ],
    );
  }

  // Builds the User's Email input field
  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Correo Electronico",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Escribe tu correo electronico",
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
        const SizedBox(height: 15), // Space
      ],
    );
  }

  // Builds the password input field
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
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Escribe tu contraseña",
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
        const SizedBox(height: 15), // Space 
      ],
    );
  }

  // Builds the password's confirmation input field
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
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Escribe nuevamente tu contraseña",
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
        const SizedBox(height: 30), // Space
      ],
    );
  }

  // Builds the login button
  Widget _buildLoginButton(BuildContext context) {
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
          Navigator.pushNamed(context, '/nutrition_form');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Continuar",
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

