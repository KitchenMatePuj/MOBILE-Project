import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ForgotPasswordScreen.dart';  // Route for the Forgot Password screen
import 'screens/SignUpScreen.dart';          // Route for the Sign Up screen
import 'screens/NutritionFormScreen.dart';   // Route for the Nutrition Registration screen
import 'screens/DashboardScreen.dart';        // Route for the main screen after logging in
import 'screens/RecipeSearchScreen.dart';    // Route for the specific recipe search screen
import 'screens/ProfileScreen.dart';         // Added the Profile screen route
import 'screens/EmailForgotPassScreen.dart'; // Route for the Email Forgot Password screen
import 'screens/ShoppingList.dart';         // Route for the Shopping List screen
import 'screens/CreateRecipe.dart';         // Route for the Create Recipe screen

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
      initialRoute: '/', // Initial route
      routes: {
        '/': (context) => const HomeScreen(),  // Home screen route
        '/login': (context) => const LoginScreen(),  // Login screen route
        '/forgot_password': (context) => const ForgotPasswordScreen(), // Forgot Password screen route
        '/sign_up': (context) => const SignUpScreen(),  // Sign Up screen route
        '/nutrition_form': (context) => const NutritionFormScreen(),  // Nutrition Registration screen route
        '/dashboard': (context) => const DashboardScreen(),  // Main screen after logging in
        '/recipe_search': (context) => const RecipeSearchScreen(),  // Specific recipe search screen route
        '/profile': (context) => const ProfileScreen(),  // Added Profile screen route
        '/email_forgot_pass': (context) => const EmailForgotPassScreen(), // Email Forgot Password screen route
        '/shopping_list': (context) => const ShoppingList(), // Shopping List screen route
        '/create': (context) => const CreateRecipe(), // Create Recipe screen route
      },
    );
  }
}
