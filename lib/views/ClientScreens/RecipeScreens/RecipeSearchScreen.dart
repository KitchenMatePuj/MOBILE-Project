import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/Recipes/recipes.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/models/Recipes/recipes_response.dart';
import '/models/Profiles/profile_response.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  _RecipeSearchScreenState createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  late RecipeController _recipeController;
  late ProfileController _profileController;
  TextEditingController _searchController = TextEditingController();
  List<RecipeResponse> filteredRecipes = [];
  String selectedDuration = "Todos";
  String selectedRating = "Todas";
  String selectedCategory = "Todos";
  String selectedMealType = "Todos";
  String selectedCuisine = "Todas";
  int _recipesToShow = 8;

  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _recipeController = RecipeController(baseUrl: recipeBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _fetchRecipes();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _fetchRecipes() async {
    try {
      List<RecipeResponse> recipes = await _recipeController.fetchRecipes();
      setState(() {
        filteredRecipes = recipes;
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
      String query = _searchController.text.toLowerCase();
      // filteredRecipes = _recipeController.allRecipes.where((recipe) {
      //   bool matchesSearch = recipe.title.toLowerCase().contains(query) || recipe.keycloakUserId.toLowerCase().contains(query);
      //   bool matchesDuration = selectedDuration == "Todos" || _matchesDuration(recipe.cookingTime);
      //   bool matchesRating = selectedRating == "Todas" || recipe.ratingAvg == double.parse(selectedRating);
      //   bool matchesCategory = selectedCategory == "Todos" || recipe.foodType == selectedCategory;
      //   bool matchesMealType = selectedMealType == "Todos" || recipe.foodType == selectedMealType;
      //   bool matchesCuisine = selectedCuisine == "Todas" || recipe.foodType == selectedCuisine;
      //   return matchesSearch && matchesDuration && matchesRating && matchesCategory && matchesMealType && matchesCuisine;
      // }).toList();
    });
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
                              imageUrl: 'assets/recipes/recipe1.jpg',
                              width: cardWidth,
                              rating: recipe.ratingAvg.toInt(),
                              recipeId: recipe.recipeId,
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

  const RecipeCard({
    super.key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    required this.width,
    this.rating,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: width,
                  height: 100,
                ),
              ),
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
