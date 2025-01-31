import 'package:flutter/material.dart';
import 'screens/SignInAndSignUpScreens/ForgotPasswordScreens/HomeScreen.dart';
import 'screens/SignInAndSignUpScreens/ForgotPasswordScreens/LoginScreen.dart';
import 'screens/SignInAndSignUpScreens/ForgotPasswordScreens/ForgotPasswordScreen.dart';  // Route for the Forgot Password screen
import 'screens/SignInAndSignUpScreens/ForgotPasswordScreens/SignUpScreen.dart';          // Route for the Sign Up screen
import 'screens/SignInAndSignUpScreens/ForgotPasswordScreens/NutritionFormScreen.dart';   // Route for the Nutrition Registration screen
import 'screens/ClientScreens/HomeScreens/DashboardScreen.dart';        // Route for the main screen after logging in
import 'screens/ClientScreens/HomeScreens/RecipeSearchScreen.dart';    // Route for the specific recipe search screen
import 'screens/ClientScreens/HomeScreens/ProfileScreens/ProfileScreen.dart';         // Added the Profile screen route
import 'screens/SignInAndSignUpScreens/ForgotPasswordScreens/EmailForgotPassScreen.dart'; // Route for the Email Forgot Password screen
import 'screens/ClientScreens/HomeScreens/ShoppingListScreen.dart';         // Route for the Shopping List screen
import 'screens/ClientScreens/HomeScreens/RecipeScreens/CreateRecipeScreen.dart';         // Route for the Create Recipe screen
import 'screens/ClientScreens/HomeScreens/ProfileScreens/EditProfileScreen.dart'; // Route for the Edit Profile screen
import 'screens/ClientScreens/HomeScreens/ProfileScreens/ReportScreen.dart';    // Route for the Reports screen
//import 'screens/ClientScreens/HomeScreens/RecipeScreens/Recipe';

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
        '/edit_profile': (context) => const Editprofile(), // Edit Profile screen route
        '/reports': (context) => const Reports(), // Reports screen route
      },
    );
  }
}
