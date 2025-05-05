import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/follow_controller.dart';

import 'package:mobile_kitchenmate/controllers/Recipes/comments.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipe_steps.dart';

import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/saved_recipe_controller.dart';
import 'package:mobile_kitchenmate/models/Profiles/follow_request.dart';
import 'package:mobile_kitchenmate/models/Profiles/profile_response.dart';

import 'package:mobile_kitchenmate/models/Recipes/ingredients_response.dart'
    as recipes;
import 'package:mobile_kitchenmate/models/Recipes/comments_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipe_steps_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_response.dart';
import 'package:mobile_kitchenmate/utils/image_utils.dart';

import '/controllers/authentication/auth_controller.dart';

import '/models/Profiles/saved_recipe_request.dart';
import '/models/Profiles/saved_recipe_response.dart';
import '/models/Reports/report_request.dart';

import 'package:mobile_kitchenmate/controllers/Reports/reports_controller.dart';
import '/controllers/Profiles/shopping_list_controller.dart';
import '/models/Profiles/shopping_list_request.dart';

import 'package:mobile_kitchenmate/controllers/Profiles/ingredient_controller.dart'
    as profile_ingredient;
import 'package:mobile_kitchenmate/controllers/Recipes/ingredients.dart'
    as recipe_ingredient;

import 'package:mobile_kitchenmate/models/Profiles/ingredient_request.dart'
    as profile_ingredient;

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
  final String _reportBase = dotenv.env['REPORTS_URL'] ?? '';

  late RecipeController _recipeController;
  late recipe_ingredient.IngredientController
      _ingredientController; // Usamos el alias 'recipe_ingredient' para ingredientes de recetas
  late profile_ingredient.IngredientController
      _profileIngredientController; // Usamos el alias 'profile_ingredient' para ingredientes de perfiles
  late RecipeStepController _stepController;
  late ProfileController _profileController;
  late SavedRecipeController _savedController;
  late CommentController _commentController;
  late AuthController _authController;
  late FollowController _followController;
  late ReportsController _reportController;

  late String _authUserId = '';
  late String recipeUserId = '';
  late String recipeUserId1 = '';

  Stopwatch _initStopwatch = Stopwatch();
  Stopwatch _loadRecipeDatapwatch = Stopwatch();

  Future<void> _loadRecipeData(int recipeId) async {
    _loadRecipeDatapwatch.start();
    try {
      print('⏳ [Inicio] Cargando datos de la receta...');

      // → PRIMER BLOQUE: Receta y Perfil en paralelo (deben estar antes que todo)
      final stopwatchFirstBlock = Stopwatch()..start();
      final recipeFuture = _recipeController.getRecipeById(recipeId);
      final profileFuture = _profileController.getProfile(keycloakUserId);

      final firstResults = await Future.wait([recipeFuture, profileFuture]);
      stopwatchFirstBlock.stop();
      print(
          '✅ [Receta + Perfil usuario] -> ${stopwatchFirstBlock.elapsedMilliseconds} ms');

      final recipe = firstResults[0] as RecipeResponse;
      final profile = firstResults[1] as ProfileResponse;

      recipeUserId = recipe.keycloakUserId;
      recipeUserId1 = recipe.keycloakUserId.toString();

      // → SEGUNDO BLOQUE: Una vez tengo la receta → lanzar todo lo demás
      final stopwatchSecondBlock = Stopwatch()..start();

      final chefFuture = _profileController.getProfile(recipe.keycloakUserId);
      final followedFuture =
          _followController.getFollowedKeycloakUserIds(profile.profileId);
      final savedRecipesFuture =
          _savedController.getSavedRecipesByKeycloak(keycloakUserId);
      final stepsFuture = _stepController.fetchSteps(recipeId);
      final ingredientsFuture =
          _ingredientController.getIngredientsByRecipe(recipeId);
      final commentsFuture = _commentController.fetchComments(recipeId);

      final results = await Future.wait([
        chefFuture,
        followedFuture,
        savedRecipesFuture,
        stepsFuture,
        ingredientsFuture,
        commentsFuture,
      ]).timeout(const Duration(seconds: 10));

      stopwatchSecondBlock.stop();
      print(
          '✅ [Restantes en paralelo] -> ${stopwatchSecondBlock.elapsedMilliseconds} ms');

      // Extraer resultados
      final chef = results[0] as ProfileResponse;
      final followedKeycloakIds = results[1] as List<String>;
      final savedRecipes = results[2] as List<SavedRecipeResponse>;
      final stepRes = results[3] as List<RecipeStepResponse>;
      final ingRes = results[4] as List<recipes.IngredientResponse>;
      final comments = results[5] as List<CommentResponse>;

      final isUserFollowing =
          followedKeycloakIds.contains(recipe.keycloakUserId);
      final isRecipeSaved =
          savedRecipes.any((saved) => saved.recipeId == recipeId);
      final ingOfRecipe = ingRes.where((i) => i.recipeId == recipeId).toList();

      imageUrl = getFullImageUrl(
        recipe.imageUrl,
        placeholder: 'assets/recipes/platovacio.png',
      );

      if (!mounted) return;

      setState(() {
        recipeTitle = recipe.title ?? '';
        duration = recipe.cookingTime ?? 0;
        totalServings = recipe.totalPortions ?? 0;
        chefName = chef.firstName ?? 'Chef sin nombre';
        chefImage = (chef.profilePhoto != null && chef.profilePhoto!.isNotEmpty)
            ? (chef.profilePhoto!.startsWith('http')
                ? chef.profilePhoto!
                : '$strapiBase${chef.profilePhoto!}')
            : 'assets/chefs/default_user.png';

        steps = stepRes.map((e) => e.description ?? '').toList();
        ingredients = ingOfRecipe
            .map((i) => {
                  'name': i.name ?? '',
                  'unit': i.measurementUnit ?? '',
                })
            .cast<Map<String, String>>()
            .toList();

        totalComments = comments.length;
        isSaved = isRecipeSaved;
        isFollowing = isUserFollowing;
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

    _loadRecipeDatapwatch.stop();
    print(
        '🏁 [Final] Tiempo total de _loadRecipeData -> ${_loadRecipeDatapwatch.elapsedMilliseconds} ms');
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
              backgroundColor: Colors.white, // Fondo blanco para todo el cuadro
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

      // Envía la solicitud al backend y obtiene la respuesta
      final shoppingListResponse =
          await ShoppingListController(baseUrl: profileBaseUrl)
              .createShoppingList(shoppingListRequest);

      final shoppingListId = shoppingListResponse.shoppingListId;

      // Obtén todos los ingredientes de la receta actual
      final allIngredients = await _ingredientController.fetchIngredients();
      final recipeIngredients = allIngredients
          .where((ingredient) => ingredient.recipeId == recipeId)
          .toList();

      // Guarda todos los ingredientes en el backend de Profiles
      for (final ingredient in recipeIngredients) {
        final ingredientRequest = profile_ingredient.IngredientRequest(
            shoppingListId: shoppingListId,
            ingredientName: ingredient.name,
            measurementUnit: ingredient.measurementUnit);

        await _profileIngredientController.createIngredient(ingredientRequest);
      }

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Receta e ingredientes añadidos a la lista de compras')),
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
      // Obtén el perfil del usuario logueado
      final profile = await _profileController.getProfile(keycloakUserId);

      // Configura el objeto ReportRequest
      final reportRequest = ReportRequest(
        reporterUserId: profile.profileId
            .toString(), // Usa el profileId del usuario logueado
        resourceType: "Receta", // Tipo de recurso fijo
        description: description,
        status: "pending", // Estado inicial del reporte
      );

      // Envía el reporte al backend
      await ReportsController(baseUrl: _reportBase).createReport(reportRequest);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado con éxito')),
      );
    } catch (e) {
      // Maneja errores y muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar reporte: $e')),
      );
    }
  }

  Future<void> _toggleFollowState() async {
    try {
      final profile = await _profileController.getProfile(keycloakUserId);
      final chefProfile = await _profileController.getProfile(recipeUserId1);

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

    _initStopwatch.start();
    _recipeController = RecipeController(baseUrl: recipeBaseUrl);
    _ingredientController = recipe_ingredient.IngredientController(
        baseUrl: recipeBaseUrl); // Controlador de recetas
    _profileIngredientController = profile_ingredient.IngredientController(
        baseUrl: profileBaseUrl); // Controlador de perfiles
    _stepController = RecipeStepController(baseUrl: recipeBaseUrl);
    _commentController = CommentController(baseUrl: recipeBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _savedController = SavedRecipeController(baseUrl: profileBaseUrl);
    _authController = AuthController(baseUrl: _authBase);
    _followController = FollowController(baseUrl: profileBaseUrl);
    _reportController = ReportsController(baseUrl: _reportBase);
    _initStopwatch.stop();
    print(
        'Tiempo de carga en el initstate: ${_initStopwatch.elapsedMilliseconds} ms');
    _initializeAuthUser();
  }

  Future<void> _initializeAuthUser() async {
    keycloakUserId = await _authController.getKeycloakUserId();
    _authUserId = keycloakUserId;
    setState(() {}); // ← Refresca la pantalla cuando termine de cargar
  }

  // ──────────────── 3) didChangeDependencies → leer arguments ──────────
  bool _loaded = false; // evita recargas múltiples

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return; // Evita recargas múltiples.

    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final int? idArg = args?['recipeId'] as int?;

    if (idArg == null) {
      // No llegó el parámetro → mensaje de error.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: no se recibió recipeId')),
          );
        }
      });
      return;
    }

    recipeId = idArg; // Guarda el id de receta.
    _loaded = true; // Marca como cargado una sola vez.

    _ensureAuthAndLoad(); // ← Nuevo helper.
  }

  /// Asegura que keycloakUserId esté cargado y luego llama a _loadRecipeData.
  Future<void> _ensureAuthAndLoad() async {
    if (keycloakUserId.isEmpty) {
      try {
        keycloakUserId = await _authController.getKeycloakUserId();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error obteniendo usuario: $e')),
          );
        }
        return;
      }
    }

    // Ahora que ya tenemos el userId, hacemos la carga de la receta.
    await _loadRecipeData(recipeId!);
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
    Widget displayedImage;

    if (imageUrl.isEmpty) {
      // ← Si aún no se ha cargado la imagen
      displayedImage = SizedBox(
        width: double.infinity,
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (imageUrl.startsWith('http')) {
      // Imagen de red con indicador de carga
      displayedImage = Image.network(
        imageUrl,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return SizedBox(
            width: double.infinity,
            height: 150,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/recipes/recipe_placeholder.jpg',
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Imagen local
      displayedImage = Image.asset(
        imageUrl,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.darken),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(3.14159), // rotar 180°
              child: displayedImage,
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
            onPressed: _toggleSavedState,
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
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/public_profile',
                  arguments: {'profile_id': recipeUserId}, // Usa el profileId
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: chefImage.startsWith('http')
                    ? NetworkImage(chefImage)
                    : AssetImage(chefImage) as ImageProvider,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/public_profile',
                  arguments: {'profile_id': recipeUserId}, // Usa el profileId
                );
              },
              child: Text(
                chefName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
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
      backgroundColor: Colors.white,
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
