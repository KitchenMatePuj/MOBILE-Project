import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ForgotPasswordScreen.dart';  // Ruta para la pantalla de olvido de contraseña
import 'screens/SignUpScreen.dart';          // Ruta para la pantalla de crear cuenta
import 'screens/NutritionFormScreen.dart';   // Ruta para la pantalla de registro de nutrición
import 'screens/DashboardScreen.dart';        // Ruta para la pantalla principal después de iniciar sesión
import 'screens/RecipeSearchScreen.dart';    // Ruta para la pantalla de búsqueda de receta específica

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(), // Olvido de contraseña
        '/sign_up': (context) => const SignUpScreen(),                 // Crear cuenta
        '/nutrition_form': (context) => const NutritionFormScreen(),   // Registro de nutrición
        '/dashboard': (context) => const DashboardScreen(),             // Pantalla principal del cliente
        '/recipe_search': (context) => const RecipeSearchScreen(),      // Búsqueda de receta específica
      },
    );
  }
}
