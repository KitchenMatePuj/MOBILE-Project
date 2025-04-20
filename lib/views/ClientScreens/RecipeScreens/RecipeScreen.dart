import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/comments.dart';

import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/ingredients.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipe_steps.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/saved_recipe_controller.dart';

class RecipeScreen extends StatefulWidget {
  final int recipeId;
  const RecipeScreen({super.key, required this.recipeId});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  int selectedIndex = 0;
  bool isSaved = false;

  int? recipeId;
  String imageUrl = 'assets/recipes/recipe_placeholder.jpg';
  String recipeTitle = '';
  String chefName = '';
  String chefImage = 'assets/chefs/default_chef.jpg';
  int duration = 0;
  int totalServings = 0;
  int totalComments = 0;
  List<String> steps = [];
  List<Map<String, String>> ingredients = [];

  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';

  late RecipeController _recipeController;
  late IngredientController _ingredientController;
  late RecipeStepController _stepController;
  late ProfileController _profileController;
  late SavedRecipeController _savedController;
  late CommentController _commentController;

  Future<void> _loadRecipeData(int recipeId) async {
    try {
      // receta principal y perfil del autor
      final recipe = await _recipeController.getRecipeById(recipeId);
      final chef = await _profileController.getProfile(recipe.keycloakUserId);

      // pasos e ingredientes
      final stepRes = await _stepController.fetchSteps(recipeId);
      final ingRes = await _ingredientController.fetchIngredients();
      final ingOfRecipe = ingRes.where((i) => i.recipeId == recipeId);

      final comments = await _commentController.fetchComments(recipeId);

      if (!mounted) return; // pantalla cerrada → salir
      setState(() {
        recipeTitle = recipe.title;
        duration = recipe.cookingTime;
        totalServings = recipe.totalPortions;
        chefName = chef.firstName ?? '';
        chefImage = chef.profilePhoto ?? chefImage;
        steps = stepRes.map((e) => e.description).toList();
        ingredients = ingOfRecipe
            .map((i) => {'name': i.name, 'unit': i.measurementUnit})
            .toList();
        totalComments = comments.length;
      });
    } catch (e) {
      // SnackBar tras el primer frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar receta: $e')),
          );
        }
      });
    }
  }

  // ────────────────── 2) InitState → solo instanciar controladores ─────
  @override
  void initState() {
    super.initState();
    _recipeController = RecipeController(baseUrl: recipeBaseUrl);
    _ingredientController = IngredientController(baseUrl: recipeBaseUrl);
    _stepController = RecipeStepController(baseUrl: recipeBaseUrl);
    _commentController = CommentController(baseUrl: recipeBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _savedController = SavedRecipeController(baseUrl: profileBaseUrl);
  }

  // ──────────────── 3) didChangeDependencies → leer arguments ──────────
  bool _loaded = false; // evita recargas múltiples

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args is Map<String, dynamic> && args['recipeId'] != null) {
      recipeId = args['recipeId'] as int;
      _loadRecipeData(recipeId!); // ← pasamos el id
      _loaded = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: no se recibió recipeId')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () {
              // Acción de reporte
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            const SizedBox(height: 10),
            _buildTitleAndComments(),
            const SizedBox(height: 14),
            _buildChefInfo(),
            const SizedBox(height: 14),
            _buildTabs(),
            const SizedBox(height: 30),
            _buildInfoRow(),
            const SizedBox(height: 10),
            Expanded(
                child: selectedIndex == 0
                    ? _buildIngredientsList()
                    : _buildStepsList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.darken),
            child: Image.asset(
              imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
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
              Text('$duration mins',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isSaved = !isSaved;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndComments() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            recipeTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/comments',
              arguments: {'recipeId': recipeId},
            );
          },
          child: Text(
            '$totalComments Comentarios',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildChefInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(chefImage), radius: 20),
            const SizedBox(width: 10),
            Text(chefName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF129575)),
              child: const Text("Seguir"),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF129575)),
              child:
                  const Text("+ Lista\nCompras", textAlign: TextAlign.center),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTab('Ingredientes', 0),
        _buildTab('Procedimiento', 1),
      ],
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
              fontWeight: FontWeight.bold,
              fontSize: 16,
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

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const Icon(Icons.restaurant, color: Colors.grey),
          const SizedBox(width: 4),
          Text('$totalServings Porciones',
              style: const TextStyle(color: Colors.grey)),
        ]),
        Text('${steps.length} Pasos',
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildIngredientsList() {
    return ListView.builder(
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ingredient['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                //${ingredient['quantity']}
                Text('${ingredient['unit']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepsList() {
    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paso ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(steps[index]),
              ],
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      selectedItemColor: const Color(0xFF129575),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Publicar'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Compras'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
