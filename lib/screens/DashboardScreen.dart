import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = "Recomendado";

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF129575),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UserHeader section
                const UserHeader(),
                const SizedBox(height: 24),
                // SearchBar section
                const SearchBar(),
                const SizedBox(height: 24),
                // Categories section
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
                const SizedBox(height: 24),
                // Featured Recipes section - First row with 3 horizontal SingleChildScrollViews










                // Row with 3 images in a single row (3 images per row)
                // First row with 3 SingleChildScrollView containing RecipeCards
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            RecipeCard(
                              title: "Salchipapa Venezolana XXL",
                              chef: "Laura_Bozzo",
                              duration: "35 mins",
                              imageUrl: "assets/icons/recipe1.jpg", // Actualizada la ruta
                            ),
                            SizedBox(width: 16),
                            RecipeCard(
                              title: "Perro Caliente Colombiano",
                              chef: "Tia_Piedad",
                              duration: "15 mins",
                              imageUrl: "assets/icons/recipe2.jpg", // Actualizada la ruta
                            ),
                            SizedBox(width: 16),
                            RecipeCard(
                              title: "Pasta Alfredo",
                              chef: "Machis",
                              duration: "30 mins",
                              imageUrl: "assets/icons/recipe3.jpg", // Actualizada la ruta
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Second row with 3 SingleChildScrollView containing RecipeCards
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            RecipeCard(
                              title: "Salchipapa Venezolana XXL",
                              chef: "Laura_Bozzo",
                              duration: "35 mins",
                              imageUrl: "assets/icons/recipe1.jpg", // Actualizada la ruta
                            ),
                            SizedBox(width: 16),
                            RecipeCard(
                              title: "Perro Caliente Colombiano",
                              chef: "Tia_Piedad",
                              duration: "15 mins",
                              imageUrl: "assets/icons/recipe2.jpg", // Actualizada la ruta
                            ),
                            SizedBox(width: 16),
                            RecipeCard(
                              title: "Pasta Alfredo",
                              chef: "Machis",
                              duration: "30 mins",
                              imageUrl: "assets/icons/recipe3.jpg", // Actualizada la ruta
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),














                const SizedBox(height: 24),
                // Nuevas Recetas section
                const Text(
                  'Recetas Añadidas Recientemente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Recipe Cards section
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      RecipeCard(
                        title: "Salchipapa Venezolana XXL",
                        chef: "Laura_Bozzo",
                        duration: "35 mins",
                        imageUrl: "assets/icons/recipe1.jpg", // Actualizada la ruta
                      ),
                      RecipeCard(
                        title: "Perro Caliente Colombiano",
                        chef: "Tia_Piedad",
                        duration: "15 mins", 
                        imageUrl: "assets/icons/recipe2.jpg", // Actualizada la ruta
                      ),
                      RecipeCard(
                        title: "Pasta Alfredo",
                        chef: "Machis",
                        duration: "30 mins",
                        imageUrl: "assets/icons/recipe3.jpg", // Actualizada la ruta
                      ),
                      // Más RecipeCards...
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// RecipeCard widget
class RecipeCard extends StatelessWidget {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;

  const RecipeCard({
    Key? key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
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
                      backgroundImage: AssetImage('assets/icons/chefs/$chef.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Text(chef),
                  ],
                ),
                const SizedBox(height: 8),
                Text(duration),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CategoryChip widget
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

// UserHeader widget
class UserHeader extends StatelessWidget {
  const UserHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Bienvenido Miguel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '¿Que deseas cocinar hoy?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFA9A9A9),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // Redirige a la pantalla de perfil
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/icons/chefs/profilePhoto.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// SearchBar widget
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Busca una receta...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Espacio entre el TextField y el botón
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF129575), // Color verde de fondo
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white), // Ícono de filtro
              onPressed: () {
                // Aquí va la acción para el botón, por ejemplo abrir un filtro o menú
                print("Filtro activado");
              },
            ),
          ),
        ],
      ),
    );
  }
}