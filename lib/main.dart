import 'package:flutter/material.dart';
import 'views/SignInAndSignUpScreens/HomeScreen.dart';
import 'views/SignInAndSignUpScreens/LoginScreen.dart';
import 'views/SignInAndSignUpScreens/ForgotPasswordScreens/ForgotPasswordScreen.dart';  // Route for the Forgot Password screen
import 'views/SignInAndSignUpScreens/SignUpScreen.dart';          // Route for the Sign Up screen
import 'views/SignInAndSignUpScreens/NutritionFormScreen.dart';   // Route for the Nutrition Registration screen
import 'views/ClientScreens/DashboardScreen.dart';        // Route for the main screen after logging in
import 'views/ClientScreens/RecipeScreens/RecipeSearchScreen.dart';    // Route for the specific recipe search screen
import 'views/ClientScreens/ProfileScreens/ProfileScreen.dart';         // Added the Profile screen route
import 'views/SignInAndSignUpScreens/ForgotPasswordScreens/EmailForgotPassScreen.dart'; // Route for the Email Forgot Password screen
import 'views/ClientScreens/ShoppingListScreen.dart';         // Route for the Shopping List screen
import 'views/ClientScreens/RecipeScreens/CreateRecipeScreen.dart';         // Route for the Create Recipe screen
import 'views/ClientScreens/RecipeScreens/RecipeScreen.dart';        // Route for the Recipe screen
import 'views/ClientScreens/ProfileScreens/EditProfileScreen.dart'; // Route for the Edit Profile screen
import 'views/ClientScreens/ProfileScreens/ReportScreen.dart';    // Route for the Reports screen


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
        '/recipe': (context) => const RecipeScreen(), // Recipe screen route
        '/edit_profile': (context) => const Editprofile(), // Edit Profile screen route
        '/reports': (context) => const Reports(), // Reports screen route
      },
    );
  }
}
