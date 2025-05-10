import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/categories.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/models/Recipes/categories_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_response.dart';

import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/sumary_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/follow_controller.dart';
import 'package:mobile_kitchenmate/models/Profiles/profile_response.dart';
import 'package:mobile_kitchenmate/models/Profiles/summary_response.dart';

import 'package:mobile_kitchenmate/models/Recommendations/recommendation_request.dart';
import 'package:mobile_kitchenmate/models/Recommendations/recommendation_response.dart';
import 'package:mobile_kitchenmate/controllers/recommendations/recommendations_controller.dart';

import 'package:mobile_kitchenmate/utils/image_utils.dart';

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';
import 'dart:developer';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

const image = '';

class _DashboardScreenState extends State<DashboardScreen> {
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final String authBaseUrl = dotenv.env['AUTH_URL'] ?? '';
  final String recomendationBaseUrl = dotenv.env['RECOMMENDATION_URL'] ?? '';
  final Stopwatch _stopwatch = Stopwatch();
  late ProfileController _profileController;
  late SumaryController _summaryController;
  late RecipeController _recipeController;
  late CategoryController _categoryController;
  late RecommendationsController _recommendationController;
  late AuthController _authController;
  ImageProvider _profileImage =
      const AssetImage('assets/recipes/platovacio.png');
  bool _profileImageLoaded = false;
  bool _recommendationsLoaded = false;
  bool _publishedRecipesLoaded = false;

  List<RecipeResponse> _savedRecipeDetails = [];
  List<RecipeResponse> _publishedRecipes = [];
  List<RecommendationResponse> _recommendations = [];
  Map<int, CategoryResponse> _categoriesById = {};
  Map<String, ProfileResponse> _authorProfiles = {};

  Future<ProfileResponse>? _profileFuture;
  Future<ProfileSummaryResponse>? _summaryFuture;

  String keycloakUserId = '';

  String query = '';
  int _recipesToShow = 4;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _recipeController = RecipeController(baseUrl: recipeBaseUrl);
    _categoryController = CategoryController(baseUrl: recipeBaseUrl);
    _summaryController = SumaryController(baseUrl: profileBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _recommendationController =
        RecommendationsController(baseUrl: recomendationBaseUrl);
    _authController = AuthController(baseUrl: authBaseUrl);

    _stopwatch.start();

    _loadUserData(); // llamamos la lógica aparte
  }

  Future<void> _loadUserData() async {
    try {
      keycloakUserId = await _authController.getKeycloakUserId();

      // 1. Perfil
      _profileFuture =
          _profileController.getProfile(keycloakUserId).then((profile) async {
        // Imagen (igual que antes)
        if ((profile.profilePhoto ?? '').isNotEmpty) {
          final fullImageUrl = getFullImageUrl(profile.profilePhoto!,
              placeholder: 'assets/recipes/platovacio.png');

          final imageProvider = NetworkImage(fullImageUrl);
          await precacheImage(imageProvider, context);

          if (mounted) {
            setState(() {
              _profileImage = imageProvider;
              _profileImageLoaded = true;
            });
          }
        } else {
          _profileImage = const AssetImage('assets/recipes/platovacio.png');
          _profileImageLoaded = true;
        }

        return profile;
      });

      // 2. Resumen
      final summary =
          await _summaryController.getProfileSummary(keycloakUserId);

      // 3. Recetas guardadas y categorías
      await _loadSavedRecipes(summary.savedRecipes);
      await _loadCategoriesForRecipes(_savedRecipeDetails);

      // 4. Preparar categorías favoritas
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

      // 🚀 Lanzar las recomendaciones sin await (en paralelo)
      final recommendationsFuture =
          _recommendationController.fetchRecommendations(recommendationRequest);

      // 🚀 Mientras tanto, cargar published recipes
      final publishedRecipes = await _loadPublishedRecipes(keycloakUserId);

      // ✅ Finalmente esperamos a que terminen las recomendaciones
      final recs = await recommendationsFuture;

      if (mounted) {
        setState(() {
          _recommendations = recs;
          _recommendationsLoaded = true;
          _publishedRecipes = publishedRecipes;
          _publishedRecipesLoaded = true;
        });
      }
    } catch (e) {
      print('❌ Error al cargar usuario: $e');
    }
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
        } catch (e) {
          continue;
        }
      }
    }
  }

  Future<List<RecipeResponse>> _loadPublishedRecipes(String userId) async {
    if (_publishedRecipesLoaded)
      return []; // ← evita recarga si ya están cargadas
    _publishedRecipesLoaded = true;

    try {
      // Obtener perfil para obtener el profileId
      final profile = await _profileController.getProfile(userId);

      // Instanciar FollowController SOLO aquí → optimizado
      final followController = FollowController(baseUrl: profileBaseUrl);

      // Obtener Keycloak de los usuarios seguidos
      final followedKeycloaks =
          await followController.getFollowedKeycloakUserIds(profile.profileId);

      final List<RecipeResponse> allRecipes = [];

      // Cargar recetas de cada seguido
      for (String followedUserId in followedKeycloaks) {
        try {
          final userRecipes =
              await _recipeController.getRecipesByUser(followedUserId);
          allRecipes.addAll(userRecipes);
        } catch (_) {
          // Ignorar errores individuales
          continue;
        }
      }

      return allRecipes; // ✅ retornar resultado
    } catch (e) {
      print('❌ Error al cargar recetas publicadas: $e');
      return []; // Si falla → regresar lista vacía
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        print('⏱ DashboardScreen: ${_stopwatch.elapsedMilliseconds} ms');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF129575),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 10),
                child: FutureBuilder<ProfileResponse>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      // TERMINO DE CARGAR PERO NO HAY DATOS -> no data found
                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: Text(
                            'No data found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final profile = snapshot.data!;
                    return UserHeader(
                        user: profile,
                        profileImage: _profileImage,
                        profileImageLoaded: _profileImageLoaded);
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: selectedIndex == 0
                      ? !_recommendationsLoaded
                          ? Center(child: CircularProgressIndicator())
                          : _recommendations.isEmpty
                              ? Center(
                                  child: Text(
                                      'No hay recomendaciones por el momento.',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic)))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _recommendations.length,
                                  itemBuilder: (context, index) {
                                    final rec = _recommendations[index];
                                    final recipe = _recommendations[index];

                                    final profile =
                                        _authorProfiles[recipe.keycloakUserId];
                                    final chefName = profile != null
                                        ? '${profile.firstName} ${profile.lastName}'
                                        : 'Chef';
                                    final img = getFullImageUrl(
                                      rec.imageUrl,
                                      placeholder:
                                          'assets/recipes/platovacio.png',
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/recipe', arguments: {
                                            'recipeId': rec.recipeId
                                          });
                                        },
                                        child: RecipeCard(
                                          title: recipe.title,
                                          chef: chefName,
                                          duration: '${recipe.cookingTime}',
                                          imageUrl: img,
                                          rating: recipe.ratingAvg.round(),
                                        ),
                                      ),
                                    );
                                  },
                                )
                      : !_publishedRecipesLoaded
                          ? Center(child: CircularProgressIndicator())
                          : _publishedRecipes.isEmpty
                              ? Center(
                                  child: Text('Aún no sigues a nadie.',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic)))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _publishedRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = _publishedRecipes[index];
                                    final profile =
                                        _authorProfiles[recipe.keycloakUserId];
                                    final chefName = profile != null
                                        ? '${profile.firstName} ${profile.lastName}'
                                        : 'Chef';
                                    final img = getFullImageUrl(
                                      recipe.imageUrl,
                                      placeholder:
                                          'assets/recipes/platovacio.png',
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/recipe', arguments: {
                                            'recipeId': recipe.recipeId
                                          });
                                        },
                                        child: RecipeCard(
                                          title: recipe.title,
                                          chef: chefName,
                                          duration: '${recipe.cookingTime}',
                                          imageUrl: img,
                                          rating: recipe.ratingAvg.round(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
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

// Nota: Se mantuvieron las clases RecipeCard, UserHeader, ProfileCard y ProfileTabs sin cambios.

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
            child: Image.network(
              getFullImageUrl(imageUrl,
                  placeholder: 'assets/recipes/platovacio.png'),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/recipes/platovacio.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
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
                      backgroundImage:
                          AssetImage('assets/chefs/default_user.png'),
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
  final ImageProvider? profileImage;
  final bool profileImageLoaded;

  const UserHeader({
    Key? key,
    required this.user,
    this.profileImage,
    required this.profileImageLoaded,
  }) : super(key: key);

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
            child: profileImageLoaded
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(child: CircularProgressIndicator.adaptive()),
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
