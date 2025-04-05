import 'package:flutter/material.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/categories.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/models/Recipes/categories_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_response.dart';

import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/sumary_controller.dart';
import 'package:mobile_kitchenmate/models/Profiles/profile_response.dart';
import 'package:mobile_kitchenmate/models/Profiles/summary_response.dart';

import 'package:mobile_kitchenmate/models/Recommendations/recommendation_request.dart';
import 'package:mobile_kitchenmate/models/Recommendations/recommendation_response.dart';
import 'package:mobile_kitchenmate/controllers/recommendations/recommendations_controller.dart';

import 'package:provider/provider.dart';
import '/providers/user_provider.dart';

import 'package:provider/provider.dart';
import '/providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ProfileController _profileController;
  late SumaryController _summaryController;
  late RecipeController _recipeController;
  late CategoryController _categoryController;
  late RecommendationsController _recommendationController;

  List<RecipeResponse> _savedRecipeDetails = [];
  List<RecommendationResponse> _recommendations = [];
  Map<int, CategoryResponse> _categoriesById = {};

  late Future<ProfileSummaryResponse> _summaryFuture;
  late Future<ProfileResponse> _profileFuture;

  String query = '';
  int _recipesToShow = 4;
  int selectedIndex = 0;
  String keycloakUserId = 'user1234';

  @override
  void initState() {
    super.initState();

    _recipeController = RecipeController(baseUrl: 'http://localhost:8004');
    _categoryController = CategoryController(baseUrl: 'http://localhost:8004');
    _summaryController = SumaryController();
    _profileController = ProfileController();
    _recommendationController =
        RecommendationsController(baseUrl: 'http://localhost:8007');

    _profileFuture = _profileController.getProfile(keycloakUserId);

    _summaryFuture = _summaryController.getProfileSummary(keycloakUserId)
      ..then((summary) async {
        await _loadSavedRecipes(summary.savedRecipes);
        await _loadCategoriesForRecipes(_savedRecipeDetails);

        final categoryNames = _savedRecipeDetails
            .map((r) => r.categoryId)
            .where((id) => _categoriesById.containsKey(id))
            .map((id) => _categoriesById[id]!.name)
            .toList();

        final recommendationRequest = RecommendationRequest(
          keycloakUserId: keycloakUserId,
          favoriteCategories: categoryNames,
          allergies: summary.ingredientAllergies,
          cookingTime: summary.cookingTime,
        );

        final recs = await _recommendationController
            .fetchRecommendations(recommendationRequest);
        setState(() {
          _recommendations = recs;
        });
      });
  }

  Future<void> _loadSavedRecipes(List<int> recipeIds) async {
    final List<RecipeResponse> loaded = [];
    for (int id in recipeIds) {
      try {
        final recipe = await _recipeController.getRecipeById(id);
        loaded.add(recipe);
      } catch (_) {
        continue;
      }
    }
    setState(() {
      _savedRecipeDetails = loaded;
    });
  }

  Future<void> _loadCategoriesForRecipes(List<RecipeResponse> recipes) async {
    for (var recipe in recipes) {
      final categoryId = recipe.categoryId;
      if (!_categoriesById.containsKey(categoryId)) {
        try {
          final category =
              await _categoryController.getCategoryById(categoryId);
          _categoriesById[categoryId] = category;
          print('📦 Categoría cargada: ${category.name}');
        } catch (e) {
          continue;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF129575),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 10),
              child: FutureBuilder<ProfileResponse>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Text('No data found');
                  }

                  final profile = snapshot.data!;
                  return UserHeader(user: profile);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar receta',
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF129575)),
                  ),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ProfileTabs(
              selectedIndex: selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  selectedIndex = index;
                  _recipesToShow = 4;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: selectedIndex == 0
                  ? _recommendations.isEmpty
                      ? Center(
                          child: Text(
                            'No hay recomendaciones por el momento.',
                            style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            final rec = _recommendations[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: RecipeCard(
                                title: rec.title,
                                chef: 'Chef',
                                duration: '${rec.cookingTime}',
                                imageUrl: 'assets/images/default.jpg',
                                rating: rec.ratingAvg.round(),
                              ),
                            );
                          },
                        )
                  : _savedRecipeDetails.isEmpty
                      ? Center(
                          child: Text(
                            'Aún no tienes recetas guardadas.',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _savedRecipeDetails.length,
                          itemBuilder: (context, index) {
                            final recipe = _savedRecipeDetails[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/recipe',
                                    arguments: {'recipeId': recipe.recipeId},
                                  );
                                },
                                child: RecipeCard(
                                  title: recipe.title,
                                  chef: 'Chef',
                                  duration: '${recipe.cookingTime}',
                                  imageUrl: 'assets/images/default.jpg',
                                  rating: recipe.ratingAvg.round(),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 0,
        onTap: (int index) {
          switch (index) {
            case 0:
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
      width: 240,
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
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/chefs/$chef.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Text(chef, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$duration mins',
                        style: const TextStyle(color: Colors.grey)),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (rating ?? 0)
                              ? Icons.star
                              : Icons.star_border,
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

class UserHeader extends StatelessWidget {
  final ProfileResponse user;

  const UserHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido ${user.firstName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '¿Qué deseas cocinar hoy?',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 83, 83, 83),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(user.profilePhoto ??
                    'default_image_url'), // Utilizamos NetworkImage para imágenes desde una URL
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
    );
  }
}

class ProfileTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ProfileTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('Recomendaciones', 0),
        const SizedBox(width: 45),
        _buildTab('Publicaciones', 1),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selectedIndex == index
                  ? const Color(0xFF129575)
                  : Colors.grey,
            ),
          ),
          if (selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 60,
              color: const Color(0xFF129575),
            ),
        ],
      ),
    );
  }
}
