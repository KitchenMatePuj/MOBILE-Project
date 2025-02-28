import 'package:flutter/material.dart';
import '/controllers/profile_controller.dart';
import '/controllers/ingredient_controller.dart';
import '/controllers/recipe_controller.dart'; // Importa el RecipeController
import '/models/profile_model.dart';
import '/models/ingredient_model.dart';
import '/models/recipe_model.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  int selectedIndex = 0;
  bool isSaved = false;

  ProfileController profileController = ProfileController();
  IngredientController ingredientController = IngredientController();
  RecipeController recipeController = RecipeController(); // Instancia del RecipeController

  Map<String, dynamic>? arguments;
  int? recipeId;
  Profile? chefProfile;
  List<Ingredient> ingredients = [];
  List<String> steps = [];
  String? imageUrl;
  String? recipeTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments!['recipeId'] != null) {
      recipeId = int.tryParse(arguments!['recipeId'].toString());
      if (recipeId != null) {
        chefProfile = profileController.getProfileByRecipeId(recipeId!);
        ingredients = ingredientController.getIngredientsByRecipeId(recipeId.toString());
        steps = recipeController.getSteps(recipeId.toString());
        imageUrl = recipeController.getImageUrl(recipeId.toString());
        recipeTitle = recipeController.getTitle(recipeId.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipeId == null || chefProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Receta'),
        ),
        body: const Center(
          child: Text('No se encontró la receta.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report, color: Colors.white),
            onPressed: () {
              // Acción para el icono de reportes
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la receta
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                      child: Image.asset(
                        imageUrl ?? 'assets/recipes/recipe_placeholder.jpg', // Use the imageUrl
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          "35 min", // Placeholder duration
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.5), // White color with opacity
                          border: Border.all(color: Colors.black), // Add black border
                        ),
                        padding: const EdgeInsets.all(3.0), // Increase padding to make the circle larger
                        child: Icon(Icons.bookmark, color: isSaved ? Colors.yellow : Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          isSaved = !isSaved;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 238, 228, 173).withOpacity(0.5), // White color with opacity
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow),
                          const SizedBox(width: 4),
                          Text(
                            "5", // Placeholder rating
                            style: const TextStyle(color: Colors.black), // Changed text color to black for better contrast
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Fila 1: Nombre de la receta y número de reseñas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    recipeTitle ?? "Receta Placeholder", // Use the recipeTitle
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "75 reseñas", // Placeholder reviews
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fila 2: Foto de perfil, nombre del chef y botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(chefProfile!.imageUrl),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        chefProfile!.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF129575),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Seguir"),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF129575),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("+ Lista de\nCompras"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fila 3: Ingredientes y Procedimiento
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTab('Ingredientes', 0),
                      _buildTab('Procedimiento', 1),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // New Row with portion and steps information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '4 Porción', // Placeholder total portions
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        '${steps.length} Pasos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Mostrar contenido según la pestaña seleccionada
              Expanded(
                child: selectedIndex == 0
                    ? ListView.builder(
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = ingredients[index];
                          return IngredientCard(ingredient: ingredient);
                        },
                      )
                    : ListView.builder(
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          final step = steps[index];
                          return StepCard(step: step, stepNumber: index + 1);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
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

  Widget _buildTab(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selectedIndex == index ? const Color(0xFF129575) : Colors.grey,
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

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientCard({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ingredient.ingredientName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              "${ingredient.quantity} ${ingredient.unit}",
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

class StepCard extends StatelessWidget {
  final String step;
  final int stepNumber;

  const StepCard({required this.step, required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Paso $stepNumber",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              step,
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
