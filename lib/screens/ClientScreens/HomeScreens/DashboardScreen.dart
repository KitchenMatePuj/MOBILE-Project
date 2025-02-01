import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Lista de recetas principales
  final List<Recipe> allRecipes = [
    Recipe(title: "Lasagna Original Italiana", chef: "kitchenMate", duration: "35 mins", imageUrl: "assets/recipes/recipe12.jpg", rating: 4, filters: "Cena, Pasta, Italiana"),
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg", rating: 4, filters: "Proteina, Cena, Navidad"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg", rating: 5, filters: "Frutas, Postre"),
    Recipe(title: "Torta de Patatas", chef: "kitchenMate", duration: "40 mins", imageUrl: "assets/recipes/recipe10.jpg", rating: 5, filters: "Cena, Vegetariana, Española"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg", rating: 4, filters: "Cereal, Desayuno, Colombiana"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg", rating: 4, filters: "Frutas, Bebida"),
    Recipe(title: "Desayuno: Arepa Colombo Venezolana con Huevo", chef: "kitchenMate", duration: "15 mins", imageUrl: "assets/recipes/recipe11.jpg", rating: 4, filters: "Desayuno, Proteina, Colombiana, Venezolana"),
  ];

  // Lista de perfiles recomendados
  final List<Profile> recommendedProfiles = [
    Profile(name: "Laura_Bozzo", description: "Chef de comidas rápidas y cenas abundantes.", imageUrl: "assets/chefs/Laura_Bozzo.jpg"),
    Profile(name: "Tia_Piedad", description: "Cocinera de almuerzos rápidos y deliciosos.", imageUrl: "assets/chefs/Tia_Piedad.jpg"),
    Profile(name: "Machis", description: "Amante de la pasta y la cocina italiana.", imageUrl: "assets/chefs/Machis.jpg"),
    Profile(name: "Dora_Explora", description: "Chef de mariscos y cenas especiales.", imageUrl: "assets/chefs/Dora_Explora.jpg"),
    Profile(name: "Chilindrinita99", description: "Expert en cocina española y mariscos.", imageUrl: "assets/chefs/Chilindrinita99.jpg"),
  ];

  // Variable para almacenar el texto de la barra de búsqueda
  String query = '';

  // Recetas que se van a Mostrar
  int _recipesToShow = 6;

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UserHeader section
                const UserHeader(),
                const SizedBox(height: 10),
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                const SizedBox(height: 7),
                // Lista vertical de recetas principales
                Column(
                  children: allRecipes
                      .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
                      .take(_recipesToShow)
                      .map((recipe) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: RecipeCard(
                                title: recipe.title,
                                chef: recipe.chef,
                                duration: recipe.duration,
                                imageUrl: recipe.imageUrl,
                                rating: recipe.rating,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                if (_recipesToShow < allRecipes.length)
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
                const SizedBox(height: 19),
                const Text(
                  'Perfiles Recomendados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Lista horizontal de perfiles recomendados
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: recommendedProfiles
                        .map((profile) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: ProfileCard(
                                name: profile.name,
                                description: profile.description,
                                imageUrl: profile.imageUrl,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 0, // It is the 'selectedItemColor'
        onTap: (int index) {
          switch (index) {
            case 0:
              break;
            case 1:
              // Navegar a Buscar
              Navigator.pushNamed(context, '/recipe_search');
              break;
            case 2:
              // Navegar a Crear
              Navigator.pushNamed(context, '/create');
              break;
            case 3:
              // Navegar a Lista de Compras
              Navigator.pushNamed(context, '/shopping_list');
              break;
            case 4:
              // Navegar a Perfil
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

// Modelo de receta
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
    this.rating,
    this.filters,
  });

  final int? rating;
  final String? filters;
}

// RecipeCard widget
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
                      duration,
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
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '¿Qué deseas cocinar hoy?',
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 83, 83, 83),
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
              image: const DecorationImage(
                image: AssetImage('assets/chefs/profilePhoto.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Modelo de perfil
class Profile {
  final String name;
  final String description;
  final String imageUrl;

  Profile({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

// ProfileCard widget
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          ClipOval(
            child: Image.asset(
              imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description.length > 40 ? '${description.substring(0, 40)}...' : description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    // Acción de seguir
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF129575),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Seguir', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
