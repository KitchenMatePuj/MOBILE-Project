import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'views/SignInAndSignUpScreens/HomeScreen.dart';
import 'views/SignInAndSignUpScreens/LoginScreen.dart';
import 'views/SignInAndSignUpScreens/ForgotPasswordScreens/ForgotPasswordScreen.dart';
import 'views/SignInAndSignUpScreens/SignUpScreen.dart';
import 'views/SignInAndSignUpScreens/NutritionFormScreen.dart';
import 'views/ClientScreens/DashboardScreen.dart';
import 'views/ClientScreens/RecipeScreens/RecipeSearchScreen.dart';
import 'views/ClientScreens/ProfileScreens/ProfileScreen.dart';
import 'views/SignInAndSignUpScreens/ForgotPasswordScreens/EmailForgotPassScreen.dart';
import 'views/ClientScreens/ShoppingListScreen.dart';
import 'views/ClientScreens/RecipeScreens/CreateRecipeScreen.dart';
import 'views/ClientScreens/RecipeScreens/RecipeScreen.dart';
import 'views/ClientScreens/ProfileScreens/EditProfileScreen.dart';
import 'views/ClientScreens/ProfileScreens/ReportScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/nutrition_form': (context) => const NutritionFormScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/recipe_search': (context) => const RecipeSearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/email_forgot_pass': (context) => const EmailForgotPassScreen(),
        '/shopping_list': (context) => const ShoppingList(),
        '/create': (context) => const CreateRecipe(),
        '/recipe': (context) => const RecipeScreen(),
        '/edit_profile': (context) => const Editprofile(),
        '/reports': (context) => const Reports(),
      },
    );
  }
}