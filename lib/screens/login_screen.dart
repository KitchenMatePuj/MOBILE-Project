import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: const Color(0xFF129575),
      ),
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
            const Spacer(flex: 4),
            const Text(
              "Hola,",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              "¡Bienvenido de nuevo!",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF121212),
              ),
            ),
            const Spacer(flex: 4),
            _buildEmailInput(),
            _buildPasswordInput(),
            _buildForgotPassword(context),
            _buildLoginButton(context),
            // Agregamos espacio entre el botón y el mensaje
            const SizedBox(height: 30), 
            _buildLoginWith(),
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
            )
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
          "Correo Electrónico",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: "Ingrese Correo Electrónico",
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
        const SizedBox(height: 20), // Espacio entre el campo de correo y el siguiente widget
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
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Ingrese Password",
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
        const SizedBox(height: 3), // Espacio entre el campo de contraseña y el siguiente widget
      ],
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: TextButton(
          onPressed: () {
            // Redirige a la pantalla de olvidé la contraseña
            Navigator.pushNamed(context, '/forgot_password');
          },
          child: const Text(
            "¿Olvidaste tu contraseña?",
            style: TextStyle(
              color: Color(0xFFFF9C00),
            ),
          ),
        ),
      ),
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
          backgroundColor: const Color(0xFF129575), // Color personalizado
        ),
        onPressed: () {
          // Redirige a la pantalla principal (Dashboard)
          Navigator.pushNamed(context, '/dashboard');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Iniciar Sesión",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 11),
            Icon(  // Usamos un Icono en lugar de un asset
              Icons.arrow_forward,  // Flecha hacia adelante
              size: 20,  // Tamaño del icono
              color: Colors.white,  // Color del icono (puedes ajustarlo)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginWith() {
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
                "O inicia sesión mediante",
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
          Row(  // Fila para mostrar los iconos juntos
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de Google
              Image.asset(
                'assets/icons/googleIcon.png',
                width: 55,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 20),  // Espacio entre los iconos
              // Icono de Facebook
              Image.asset(
                'icons/facebookIcon.png',  // Nombre del archivo de Facebook
                width: 55,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 15), // Espacio entre el campo de correo y el siguiente widget
        ],
      ),
    );
  }

  Widget _buildRegisterPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "¿No tienes cuenta? ",
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: "Créala aquí",
              style: const TextStyle(color: Color(0xFFFF9C00)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Redirige a la pantalla de crear cuenta
                  Navigator.pushNamed(context, '/sign_up');
                },
            ),
          ],
        ),
      ),
    );
  }
}
