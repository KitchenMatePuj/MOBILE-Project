import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/follow_controller.dart';

import 'package:mobile_kitchenmate/controllers/Recipes/comments.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/ingredients.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipe_steps.dart';

import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/saved_recipe_controller.dart';
import 'package:mobile_kitchenmate/models/Profiles/follow_request.dart';

import 'package:mobile_kitchenmate/models/Recipes/ingredients_response.dart'
    as recipes;
import 'package:mobile_kitchenmate/models/Profiles/ingredient_response.dart'
    as profiles;

import 'package:mobile_kitchenmate/models/Recipes/comments_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipe_steps_response.dart';

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';
import '/models/Profiles/saved_recipe_request.dart';
import '/models/Profiles/saved_recipe_response.dart';
import '/models/Profiles/follow_request.dart';
import '/controllers/Profiles/follow_controller.dart';
import '/models/Reports/report_request.dart';
import '/models/Reports/report_response.dart';
import 'package:mobile_kitchenmate/controllers/Reports/reports_controller.dart';
import '/controllers/Profiles/shopping_list_controller.dart';
import '/models/Profiles/shopping_list_request.dart';
import '/models/Profiles/shopping_list_response.dart';

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
  String imageUrl = '';
  String recipeTitle = '';
  String chefName = '';
  String keycloakUserId = '';
  String chefImage = 'assets/chefs/default_user.png';
  int duration = 0;
  int totalServings = 0;
  int totalComments = 0;
  List<String> steps = [];
  List<Map<String, String>> ingredients = [];
  bool isFollowing = false;

  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final strapiBase = dotenv.env['STRAPI_URL'] ?? '';
  final String _authBase = dotenv.env['AUTH_URL'] ?? '';

  late RecipeController _recipeController;
  late IngredientController _ingredientController;
  late RecipeStepController _stepController;
  late ProfileController _profileController;
  late SavedRecipeController _savedController;
  late CommentController _commentController;
  late AuthController _authController;
  late FollowController _followController;

  late String _authUserId = '';
  late String recipeUserId = '';

  Future<void> _loadRecipeData(int recipeId) async {
    try {
      // Carga la receta principal y el perfil del autor
      final recipe = await _recipeController.getRecipeById(recipeId);
      final chef = await _profileController.getProfile(recipe.keycloakUserId);

      // Verifica si el usuario ya sigue al chef
      final profile = await _profileController.getProfile(keycloakUserId);
      final followedKeycloakIds =
          await FollowController(baseUrl: profileBaseUrl)
              .getFollowedKeycloakUserIds(profile.profileId);
      final isUserFollowing =
          followedKeycloakIds.contains(recipe.keycloakUserId);

      // Verifica si la receta ya está guardada
      final savedRecipes =
          await _savedController.getSavedRecipesByKeycloak(keycloakUserId);
      final isRecipeSaved =
          savedRecipes.any((saved) => saved.recipeId == recipeId);

      // Carga pasos e ingredientes
      final stepRes = await _stepController.fetchSteps(recipeId);
      final ingRes = await _ingredientController.fetchIngredients();
      final ingOfRecipe = ingRes.where((i) => i.recipeId == recipeId);

      // Carga comentarios
      final comments = await _commentController.fetchComments(recipeId);
      // Intentar obtener el perfil, pero seguir incluso si falla
      String fetchedChefName = 'Chef desconocido';
      String fetchedChefImage = 'assets/chefs/default_user.png';

      try {
        final chef = await _profileController.getProfile(recipeUserId);
        fetchedChefName = chef.firstName ?? 'Chef sin nombre';
        fetchedChefImage =
            (chef.profilePhoto != null && chef.profilePhoto!.isNotEmpty)
                ? (chef.profilePhoto!.startsWith('http')
                    ? chef.profilePhoto!
                    : '$strapiBase${chef.profilePhoto!}')
                : 'assets/chefs/default_user.png';
      } catch (e) {
        print(
            '[WARNING] No se pudo cargar el perfil del chef ($recipeUserId): $e');
      }

      final ingOfRecipe = ingRes.where((i) => i.recipeId == recipeId).toList();

      imageUrl = (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
          ? (recipe.imageUrl!.startsWith('http')
              ? recipe.imageUrl! // URL absoluta
              : '$strapiBase${recipe.imageUrl!}') // URL relativa → completar
          : 'assets/recipes/recipe_placeholder.jpg';

      if (!mounted) return; // Si la pantalla fue cerrada, salir
      setState(() {
        recipeTitle = recipe.title ?? '';
        duration = recipe.cookingTime ?? 0;
        totalServings = recipe.totalPortions ?? 0;
        chefName = fetchedChefName;
        chefImage = fetchedChefImage;

        steps = stepRes.map((e) => e.description ?? '').toList();
        ingredients = ingOfRecipe
            .map((i) => {
                  'name': i.name ?? '',
                  'unit': i.measurementUnit ?? '',
                })
            .cast<Map<String, String>>()
            .toList();

        totalComments = comments.length;
        isSaved = isRecipeSaved; // Actualiza el estado del icono de guardar
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar receta: $e')),
          );
        }
      });
    }
  }

  Future<void> _showReportDialog(BuildContext context) async {
    final TextEditingController reportController = TextEditingController();
    bool isButtonEnabled = false; // Estado inicial del botón

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Estas a punto de reportar esta receta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Por favor, escribe el motivo del reporte:'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reportController,
                    maxLines: 3,
                    onChanged: (value) {
                      // Actualiza el estado del botón cuando cambia el texto
                      setState(() {
                        isButtonEnabled = value.trim().isNotEmpty;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Escribe los detalles aquí...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el popup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 238, 99, 89),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () async {
                          await _submitReport(
                              reportController.text); // Enviar reporte
                          Navigator.pop(context); // Cerrar el popup
                        }
                      : null, // Deshabilita el botón si no hay texto
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF129575),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addToShoppingList() async {
    try {
      // Obtén el perfil del usuario logueado
      final profile = await _profileController.getProfile(keycloakUserId);

      // Crea una solicitud para la lista de compras
      final shoppingListRequest = ShoppingListRequest(
        profileId: profile.profileId,
        recipeName: recipeTitle,
        recipePhoto: imageUrl, // Usa la URL de la imagen de la receta
      );

      // Envía la solicitud al backend
      await ShoppingListController(baseUrl: profileBaseUrl)
          .createShoppingList(shoppingListRequest);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta añadida a la lista de compras')),
      );
    } catch (e) {
      // Maneja errores y muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir a la lista de compras: $e')),
      );
    }
  }

  Future<void> _submitReport(String description) async {
    try {
      final reportRequest = ReportRequest(
        reporterUserId: keycloakUserId, // Usuario que reporta
        resourceType: 'recipe', // Tipo de recurso (en este caso, receta)
        description: description,
        status: 'pending', // Estado inicial del reporte
      );

      await ReportsController()
          .createReport(reportRequest); // Enviar el reporte

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar reporte: $e')),
      );
    }
  }

  Future<void> _toggleFollowState() async {
    try {
      final profile = await _profileController.getProfile(keycloakUserId);
      final chefProfile = await _profileController.getProfile(recipeUserId);

      if (isFollowing) {
        // Dejar de seguir al chef
        await FollowController(baseUrl: profileBaseUrl)
            .deleteFollow(profile.profileId, chefProfile.profileId);
      } else {
        // Seguir al chef
        final followRequest = FollowRequest(
          followerId: profile.profileId,
          followedId: chefProfile.profileId,
        );
        await FollowController(baseUrl: profileBaseUrl)
            .createFollow(followRequest);
      }

      setState(() {
        isFollowing = !isFollowing; // Alterna el estado
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isFollowing
                ? 'Siguiendo al chef'
                : 'Dejaste de seguir al chef')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar seguimiento: $e')),
      );
    }
  }

  Future<void> _toggleSavedState() async {
    try {
      if (isSaved) {
        // Elimina la receta guardada
        final savedRecipes =
            await _savedController.getSavedRecipesByKeycloak(keycloakUserId);
        final savedRecipe =
            savedRecipes.firstWhere((saved) => saved.recipeId == recipeId);
        await _savedController.deleteSavedRecipe(savedRecipe.savedRecipeId);
      } else {
        // Crea una nueva receta guardada
        final profile = await _profileController.getProfile(keycloakUserId);
        final newSavedRecipe = SavedRecipeRequest(
          profileId: profile.profileId,
          recipeId: recipeId!,
        );
        await _savedController.createSavedRecipe(newSavedRecipe);
      }

      // Actualiza el estado del icono
      setState(() {
        isSaved = !isSaved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isSaved ? 'Receta guardada' : 'Receta eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar guardado: $e')),
      );
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
    _authController = AuthController(baseUrl: _authBase);
    _followController = FollowController(baseUrl: profileBaseUrl);

    _authController.getKeycloakUserId().then((id) {
      keycloakUserId = id;
    });

    _authUserId = keycloakUserId;
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
              _showReportDialog(context);
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
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
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
            onPressed: _toggleSavedState, // Alterna el estado de guardado
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
            CircleAvatar(
              radius: 20,
              backgroundImage: chefImage.startsWith('http')
                  ? NetworkImage(chefImage)
                  : AssetImage(chefImage) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              chefName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (_authUserId == recipeUserId)
              ElevatedButton(
                onPressed:
                    _toggleFollowState, // Llama al método para alternar estado
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.grey // Color para "Dejar de seguir"
                      : const Color(0xFF129575), // Color para "Seguir"
                ),
                child: Text(
                  isFollowing ? 'Siguiendo' : 'Seguir', // Texto dinámico
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed:
                  _addToShoppingList, // Llama al método para agregar a la lista
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF129575),
              ),
              child: const Text(
                "+ Lista\nCompras",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
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
      unselectedItemColor: Colors.black,
      onTap: (index) {
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
    );
  }
}
