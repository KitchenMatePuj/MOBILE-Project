import 'package:flutter/material.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  _RecipeSearchScreenState createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  String selectedCategory = "Recomendado";
  // Comtroller for the search bar
  TextEditingController _searchController = TextEditingController();
  
  // Recipe's List
  List<Recipe> allRecipes = [
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg"),
    Recipe(title: "Paella Sencilla", chef: "Chilindrinita99", duration: "80 mins", imageUrl: "assets/recipes/recipe7.jpg"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg"),
    Recipe(title: "Mariscos Caleños", chef: "Dora_Explora", duration: "35 mins", imageUrl: "assets/recipes/recipe6.jpg"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg"),
    Recipe(title: "Perro Caliente Colombiano", chef: "Tia_Piedad", duration: "15 mins", imageUrl: "assets/recipes/recipe2.jpg"),
    Recipe(title: "Salchipapa Venezolana XXL", chef: "Laura_Bozzo", duration: "35 mins", imageUrl: "assets/recipes/recipe1.jpg"),
    Recipe(title: "Pasta Alfredo", chef: "Machis", duration: "30 mins", imageUrl: "assets/recipes/recipe3.jpg"),
  ];

  // Filtered recipe list that updates with search
  List<Recipe> filteredRecipes = [];

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  void initState() {
    super.initState();
    filteredRecipes = allRecipes;
    _searchController.addListener(_filterRecipes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter Recipes
  void _filterRecipes() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      filteredRecipes = allRecipes.where((recipe) {
        return recipe.title.toLowerCase().contains(query) || recipe.chef.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Últimas Recetas Publicadas'),
        backgroundColor: const Color(0xFF129575),
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
                    // Categories section
                    const SizedBox(height: 5),
                    SearchBar(controller: _searchController),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CategoryChip(
                            label: "Recomendado",
                            isSelected: selectedCategory == "Recomendado",
                            onTap: () => selectCategory("Recomendado"),
                          ),
                          CategoryChip(
                            label: "India",
                            isSelected: selectedCategory == "India",
                            onTap: () => selectCategory("India"),
                          ),
                          CategoryChip(
                            label: "Italiana",
                            isSelected: selectedCategory == "Italiana",
                            onTap: () => selectCategory("Italiana"),
                          ),
                          CategoryChip(
                            label: "Asiatica",
                            isSelected: selectedCategory == "Asiatica",
                            onTap: () => selectCategory("Asiatica"),
                          ),
                          CategoryChip(
                            label: "China",
                            isSelected: selectedCategory == "China",
                            onTap: () => selectCategory("China"),
                          ),
                          CategoryChip(
                            label: "Frutas",
                            isSelected: selectedCategory == "Frutas",
                            onTap: () => selectCategory("Frutas"),
                          ),
                          CategoryChip(
                            label: "Vegetales",
                            isSelected: selectedCategory == "Vegetales",
                            onTap: () => selectCategory("Vegetales"),
                          ),
                          CategoryChip(
                            label: "Proteina",
                            isSelected: selectedCategory == "Proteina",
                            onTap: () => selectCategory("Proteina"),
                          ),
                          CategoryChip(
                            label: "Cereales",
                            isSelected: selectedCategory == "Cereales",
                            onTap: () => selectCategory("Cereales"),
                          ),
                          CategoryChip(
                            label: "Platos Locales",
                            isSelected: selectedCategory == "Platos Locales",
                            onTap: () => selectCategory("Platos Locales"),  
                          ),
                        ],
                      ),
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
                      children: filteredRecipes.map((recipe) {
                        return RecipeCard(
                          title: recipe.title,
                          chef: recipe.chef,
                          duration: recipe.duration,
                          imageUrl: recipe.imageUrl,
                          width: cardWidth,
                        );
                      }).toList(),
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

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF129575) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF129575),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF129575),
          ),
        ),
      ),
    );
  }
}

class Recipe {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;

  Recipe({
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
  });
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;
  final double width;

  const RecipeCard({
    super.key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chef: $chef',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 82, 82, 82),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const SearchBar({super.key, required this.controller});

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
          const SizedBox(width: 8), // Space between the TextField and the button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF129575), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white), // Filter's Icon 
              onPressed: () {
                print("Filtro activado");
              },
            ),
          ),
        ],
      ),
    );
  }
}