import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/Recipes/recipes.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/models/Recipes/recipes_response.dart';
import '/models/Profiles/profile_response.dart';
import 'package:intl/intl.dart';

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  _RecipeSearchScreenState createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  late RecipeController _recipeController;
  late ProfileController _profileController;
  late AuthController _authController;
  TextEditingController _searchController = TextEditingController();
  List<RecipeResponse> filteredRecipes = [];
  String selectedDuration = "Todos";
  String selectedRating = "Todas";
  String selectedCategory = "Todos";
  String selectedMealType = "Todos";
  String selectedCuisine = "Todas";
  String keycloakUserId = '';
  int _recipesToShow = 8;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final String _authBase = dotenv.env['AUTH_URL'] ?? '';
  final String strapiBaseUrl = dotenv.env['STRAPI_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeController(baseUrl: recipeBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _authController = AuthController(baseUrl: _authBase);

    _authController.getKeycloakUserId().then((id) {
      keycloakUserId = id;
    });

    _fetchRecipes();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _fetchRecipes() async {
    try {
      List<RecipeResponse> recipes = await _recipeController.fetchRecipes();
      setState(() {
        filteredRecipes = recipes;
        _recipeController.allRecipes = recipes;
      });
    } catch (e) {
      // Manejar errores
      print('Failed to load recipes: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      filteredRecipes = _recipeController.allRecipes.where((recipe) {
        // Búsqueda por título o ID de usuario
        final matchesQuery = recipe.title.toLowerCase().contains(query) ||
            recipe.keycloakUserId.toLowerCase().contains(query);

        // Filtro por tiempo de cocción
        final matchesDuration =
            selectedDuration == "Todos" || _matchesDuration(recipe.cookingTime);

        // Filtro por rating
        final matchesRating = selectedRating == "Todas" ||
            recipe.ratingAvg.toInt().toString() == selectedRating;

        // Filtro por tipo de comida (meal type)
        final matchesFoodType = selectedMealType == "Todos" ||
            recipe.foodType.toLowerCase() == selectedMealType.toLowerCase();

        // Filtro por tipo de cocina (category -> ahora será totalPortions)
        final matchesPortions = selectedCategory == "Todos" ||
            recipe.totalPortions.toString() == selectedCategory;

        // Filtro por cocina (placeholder - si agregas un nuevo campo más adelante)
        final matchesCuisine = selectedCuisine == "Todas";

        // Filtro por rango de fechas
        bool matchesDate = true;
        if (selectedStartDate != null) {
          matchesDate = matchesDate &&
              !recipe.createdAt.isBefore(
                DateTime(selectedStartDate!.year, selectedStartDate!.month,
                    selectedStartDate!.day),
              );
        }
        if (selectedEndDate != null) {
          matchesDate = matchesDate &&
              !recipe.createdAt.isAfter(
                DateTime(selectedEndDate!.year, selectedEndDate!.month,
                    selectedEndDate!.day, 23, 59, 59),
              );
        }

        return matchesQuery &&
            matchesDuration &&
            matchesRating &&
            matchesFoodType &&
            matchesPortions &&
            matchesCuisine &&
            matchesDate;
      }).toList();
    });
  }

  String _fullImageUrl(String? path, {required String placeholder}) {
    try {
      if (path == null || path.isEmpty || path == 'example') return placeholder;
      if (path.startsWith('http')) return path;
      final cleanBase = strapiBaseUrl.endsWith('/')
          ? strapiBaseUrl.substring(0, strapiBaseUrl.length - 1)
          : strapiBaseUrl;
      final fixedPath = path.startsWith('/') ? path : '/$path';
      return '$cleanBase$fixedPath';
    } catch (_) {
      return placeholder;
    }
  }

  bool _matchesDuration(int cookingTime) {
    switch (selectedDuration) {
      case "0-15":
        return cookingTime <= 15;
      case "15-30":
        return cookingTime > 15 && cookingTime <= 30;
      case "30-60":
        return cookingTime > 30 && cookingTime <= 60;
      case "60-120":
        return cookingTime > 60 && cookingTime <= 120;
      case "+120":
        return cookingTime > 120;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recetas de la Comunidad'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 48) / 2;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    SearchBar(
                      controller: _searchController,
                      selectedDuration: selectedDuration,
                      selectedRating: selectedRating,
                      selectedCategory: selectedCategory,
                      selectedMealType: selectedMealType,
                      selectedCuisine: selectedCuisine,
                      selectedStartDate: selectedStartDate,
                      selectedEndDate: selectedEndDate,
                      onApplyFilters: _applyFilters,
                      onUpdateFilters:
                          (duration, rating, category, mealType, cuisine) {
                        setState(() {
                          selectedDuration = duration;
                          selectedRating = rating;
                          selectedCategory = category;
                          selectedMealType = mealType;
                          selectedCuisine = cuisine;
                        });
                        _applyFilters();
                      },
                      onStartDateChanged: (date) {
                        setState(() {
                          selectedStartDate = date;
                        });
                        _applyFilters();
                      },
                      onEndDateChanged: (date) {
                        setState(() {
                          selectedEndDate = date;
                        });
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Resultados de Búsqueda',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children:
                          filteredRecipes.take(_recipesToShow).map((recipe) {
                        return FutureBuilder<ProfileResponse>(
                          future: _profileController
                              .getProfile(recipe.keycloakUserId),
                          builder: (context, snapshot) {
                            String chefName = 'Chef: Cargando...';
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              ProfileResponse profile = snapshot.data!;
                              chefName =
                                  'Chef: ${profile.firstName} ${profile.lastName}';
                            }
                            return RecipeCard(
                              title: recipe.title,
                              chef: chefName,
                              duration: recipe.cookingTime.toString(),
                              imageUrl: recipe.imageUrl ?? '',
                              width: cardWidth,
                              rating: recipe.ratingAvg.toInt(),
                              recipeId: recipe.recipeId,
                              fullImageUrlBuilder: _fullImageUrl,
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    if (_recipesToShow < filteredRecipes.length)
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF129575),
                          ),
                          onPressed: () {
                            setState(() {
                              _recipesToShow += 4;
                            });
                          },
                          child: const Text(
                            'Cargar más',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 1,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 1:
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
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
  final double width;
  final int? rating;
  final int recipeId;
  final String Function(String?, {required String placeholder})
      fullImageUrlBuilder;

  const RecipeCard({
    super.key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    required this.width,
    this.rating,
    required this.recipeId,
    required this.fullImageUrlBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = fullImageUrlBuilder(
      imageUrl,
      placeholder: 'assets/recipes/platovacio.png',
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/recipe',
          arguments: {'recipeId': recipeId},
        );
      },
      child: SizedBox(
        width: width,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: fullUrl.startsWith('http')
                      ? Image.network(
                          fullUrl,
                          fit: BoxFit.cover,
                          width: width,
                          height: 100,
                        )
                      : Image.asset(
                          fullUrl,
                          fit: BoxFit.cover,
                          width: width,
                          height: 100,
                        )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chef,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 71, 71, 71),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$duration mins',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        if (rating != null)
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < rating!
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String selectedDuration;
  final String selectedRating;
  final String selectedCategory;
  final String selectedMealType;
  final String selectedCuisine;
  final VoidCallback onApplyFilters;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(String, String, String, String, String) onUpdateFilters;

  const SearchBar({
    super.key,
    required this.controller,
    required this.selectedDuration,
    required this.selectedRating,
    required this.selectedCategory,
    required this.selectedMealType,
    required this.selectedCuisine,
    required this.onApplyFilters,
    required this.onUpdateFilters,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Busca Recetas o Chefs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF129575),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    String tempSelectedDuration = selectedDuration;
                    String tempSelectedRating = selectedRating;
                    String tempSelectedCategory = selectedCategory;
                    String tempSelectedMealType = selectedMealType;
                    String tempSelectedCuisine = selectedCuisine;

                    return Padding(
                      padding: EdgeInsets.only(
                        top:
                            kToolbarHeight + MediaQuery.of(context).padding.top,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            List<String> durationOptions = [
                              "Todos",
                              "0-15",
                              "15-30",
                              "30-60",
                              "60-120",
                              "+120"
                            ];
                            List<String> ratingOptions = [
                              "Todas",
                              "1",
                              "2",
                              "3",
                              "4",
                              "5"
                            ];
                            List<String> categoryOptions = [
                              "Todos",
                              "Vegetales",
                              "Frutas",
                              "Proteina",
                              "Cereales",
                              "Mariscos",
                              "Arroz",
                              "Pasta"
                            ];
                            List<String> mealTypeOptions = [
                              "Todos",
                              "Desayuno",
                              "Almuerzo",
                              "Cena",
                              "Postre",
                              "Bebida"
                            ];
                            List<String> cuisineOptions = [
                              "Todas",
                              "India",
                              "Italiana",
                              "Asiatica",
                              "China",
                              "Mexicana",
                              "Francesa",
                              "Mediterránea",
                              "Japonesa",
                              "Colombiana",
                              "Venezolana"
                            ];

                            Widget buildFilterOption(
                                String title,
                                List<String> options,
                                String selectedValue,
                                Function(String) onSelected,
                                {bool showStar = false}) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 10,
                                    children: options.map((option) {
                                      bool isSelected = selectedValue == option;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              onSelected(
                                                  ""); // Deseleccionar si ya está seleccionado
                                            } else {
                                              onSelected(option);
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF129575)
                                                : Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFF129575)),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                option,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF129575),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (showStar &&
                                                  option != "Todas") ...[
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.star,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF129575),
                                                  size: 20,
                                                ),
                                              ]
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Center(
                                    child: Text(
                                      "Filtros de Búsqueda",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 23,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  buildFilterOption(
                                      "Duración en mins",
                                      durationOptions,
                                      tempSelectedDuration,
                                      (val) => tempSelectedDuration = val),
                                  buildFilterOption(
                                      "Calificación",
                                      ratingOptions,
                                      tempSelectedRating,
                                      (val) => tempSelectedRating = val,
                                      showStar: true),
                                  buildFilterOption(
                                      "Categoría",
                                      categoryOptions,
                                      tempSelectedCategory,
                                      (val) => tempSelectedCategory = val),
                                  buildFilterOption(
                                      "Tipo de Comida",
                                      mealTypeOptions,
                                      tempSelectedMealType,
                                      (val) => tempSelectedMealType = val),
                                  buildFilterOption(
                                      "Tipo de Cocina",
                                      cuisineOptions,
                                      tempSelectedCuisine,
                                      (val) => tempSelectedCuisine = val),
                                  const Text(
                                    "Fecha de Creación",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),

// Fecha Inicio
                                  Row(
                                    children: [
                                      const Text("Desde: "),
                                      TextButton(
                                        onPressed: () async {
                                          DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: selectedStartDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            onStartDateChanged(picked);
                                          }
                                        },
                                        child: Text(
                                          selectedStartDate != null
                                              ? "${selectedStartDate!.toLocal()}"
                                                  .split(' ')[0]
                                              : "Elegir fecha",
                                          style: const TextStyle(
                                              color: Color(0xFF129575)),
                                        ),
                                      ),
                                    ],
                                  ),
// Fecha Fin
                                  Row(
                                    children: [
                                      const Text("Hasta: "),
                                      TextButton(
                                        onPressed: () async {
                                          DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: selectedEndDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            onEndDateChanged(picked);
                                          }
                                        },
                                        child: Text(
                                          selectedEndDate != null
                                              ? "${selectedEndDate!.toLocal()}"
                                                  .split(' ')[0]
                                              : "Elegir fecha",
                                          style: const TextStyle(
                                              color: Color(0xFF129575)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF129575),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 80),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        onUpdateFilters(
                                          tempSelectedDuration,
                                          tempSelectedRating,
                                          tempSelectedCategory,
                                          tempSelectedMealType,
                                          tempSelectedCuisine,
                                        );
                                        onApplyFilters();
                                      },
                                      child: const Text(
                                        "Filtrar",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
