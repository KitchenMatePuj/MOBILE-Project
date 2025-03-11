import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controllers/profile_controller.dart';
import '/controllers/recipe_controller.dart';
import '/models/recipe_model.dart';
import '/models/profile_model.dart';
import '/providers/user_provider.dart';
import '/models/user_model.dart';

class PublicProfileScreen extends StatelessWidget {
  final int keycloakUserId;

  const PublicProfileScreen({super.key, required this.keycloakUserId});

  @override
  Widget build(BuildContext context) {
    final profileController = ProfileController();
    final profile = profileController.recommendedProfiles.firstWhere((p) => p.keycloak_user_id == keycloakUserId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              children: [
                ProfileStats(profile: profile), // Estadísticas del usuario
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ProfileBio(description: profile.description), // Biografía
              ],
            ),
          ),
          Expanded(
            child: PublishedRecipesGrid(profile: profile), // Recetas publicadas
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 4,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/recipe_search');
              break;
            case 2:
              Navigator.pushNamed(context, '/create');
              break;
            case 3:
              Navigator.pushNamed(context, '/shopping_list');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Publicar'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class ProfileStats extends StatelessWidget {
  final Profile profile;

  const ProfileStats({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: AssetImage(profile.imageUrl),
        ),
        const SizedBox(width: 2),
        _buildStatItem('Recetas', profile.published_recipes.length.toString()),
        _buildStatItem('Seguidores', profile.followers.length.toString()),
        _buildStatItem('Siguiendo', profile.following.length.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ProfileBio extends StatelessWidget {
  final String description;

  const ProfileBio({required this.description, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class PublishedRecipesGrid extends StatelessWidget {
  final Profile profile;

  const PublishedRecipesGrid({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    final recipeController = RecipeController();
    final publishedRecipes = profile.published_recipes
        .map((recipeId) =>
            recipeController.allRecipes.firstWhere((recipe) => recipe.recipeId == '$recipeId'))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
      itemCount: publishedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = publishedRecipes[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/recipe',
              arguments: {'recipeId': recipe.recipeId},
            );
          },
          child: RecipeCard(
            title: recipe.title,
            chef: recipe.chef,
            duration: recipe.duration,
            imageUrl: recipe.imageUrl,
            rating: recipe.rating,
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;
  final int? rating;

  const RecipeCard({
    Key? key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/chefs/$chef.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chef,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$duration mins',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (rating ?? 0) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}