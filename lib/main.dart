import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'views/SignInAndSignUpScreens/HomeScreen.dart';
import 'views/SignInAndSignUpScreens/LoginScreen.dart';
import 'views/SignInAndSignUpScreens/SignUpScreen.dart';
import 'views/ClientScreens/DashboardScreen.dart';
import 'views/ClientScreens/RecipeScreens/RecipeSearchScreen.dart';
import 'views/ClientScreens/ProfileScreens/ProfileScreen.dart';
import 'views/ClientScreens/ProfileScreens/PublicProfileScreen.dart';
import 'views/SignInAndSignUpScreens/ForgotPasswordScreens/EmailForgotPassScreen.dart';
import 'views/ClientScreens/ShoppingListScreen.dart';
import 'views/ClientScreens/RecipeScreens/CreateRecipeScreen.dart';
import 'views/ClientScreens/RecipeScreens/RecipeScreen.dart';
import 'views/ClientScreens/ProfileScreens/EditProfileScreen.dart';
import 'views/ClientScreens/ProfileScreens/ReportScreen.dart';
import 'views/ClientScreens/RecipeScreens/CommentsScreen.dart';
import 'views/ClientScreens/ProfileScreens/FollowersAndFollowing.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env.txt");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/followers_and_following') {
          final args = settings.arguments as Map<String, dynamic>;
          final int profileId = args['profile_id'] ?? 0;
          final String type =
              args['type'] ?? 'followers';

          return MaterialPageRoute(
            builder: (context) {
              return FollowersAndFollowingScreen(
                profileId: profileId,
                type: type,
              );
            },
          );
        } else if (settings.name == '/public_profile') {
          final args = settings.arguments as Map<String, dynamic>;
          final int profileId = args['profile_id'] ?? 3;

          return MaterialPageRoute(
            builder: (context) {
              return PublicProfileScreen(profileId: profileId);
            },
          );
        } else if (settings.name == '/recipe') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null || args['recipeId'] == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('No se recibió recipeId')),
              ),
            );
          }

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => RecipeScreen(recipeId: args['recipeId'] as int),
          );
        } else if (settings.name == '/comments') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null || args['recipeId'] == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('No se recibió recipeId')),
              ),
            );
          }

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const CommentsScreen(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
      },
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/recipe_search': (context) => const RecipeSearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/email_forgot_pass': (context) => const EmailForgotPassScreen(),
        '/shopping_list': (context) => const ShoppingListScreen(),
        '/create': (context) => const CreateRecipeScreen(),
        '/edit_profile': (context) => const EditprofileScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
