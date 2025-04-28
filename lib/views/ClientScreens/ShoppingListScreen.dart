import 'package:flutter/material.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/Profiles/shopping_list_controller.dart';
import '/controllers/Profiles/ingredient_controller.dart';
import '/models/Profiles/ingredient_response.dart';
import '/models/Profiles/shopping_list_response.dart';
import '/models/Recipes/recipes_response.dart';
import '/controllers/Recipes/recipes.dart';
import '/controllers/authentication/auth_controller.dart';
import '/providers/user_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool isIngredientSelected = true;
  String searchTerm = '';
  late ShoppingListController shoppingListController;
  late IngredientController ingredientController;
  late RecipeController recipeController;
  ShoppingListResponse? selectedShoppingList;
  int? profileId; // profile_id del usuario logueado
  late AuthController authController;
  late ProfileController profileController;
  String keycloakUserId = '';

  final profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final authBaseUrl = dotenv.env['AUTH_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    shoppingListController = ShoppingListController(baseUrl: profileBaseUrl);
    ingredientController = IngredientController(baseUrl: profileBaseUrl);
    recipeController = RecipeController(baseUrl: recipeBaseUrl);
    authController = AuthController(baseUrl: authBaseUrl);
    profileController = ProfileController(baseUrl: profileBaseUrl);

    _loadProfileId();
  }

  Future<void> _loadProfileId() async {
    try {
      keycloakUserId = await authController.getKeycloakUserId();
      final profile = await profileController.getProfile(keycloakUserId);
      setState(() {
        profileId = profile.profileId;
      });
    } catch (e) {
      print('Error cargando profileId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por Ingrediente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Ingredient and Recipe options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isIngredientSelected = true;
                        selectedShoppingList = null;
                        searchTerm = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isIngredientSelected
                            ? const Color(0xFF129575)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF129575)),
                      ),
                      child: Text(
                        'Por Ingrediente',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isIngredientSelected
                              ? Colors.white
                              : const Color(0xFF129575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isIngredientSelected = false;
                        selectedShoppingList = null;
                        searchTerm = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isIngredientSelected
                            ? Colors.white
                            : const Color(0xFF129575),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF129575)),
                      ),
                      child: Text(
                        'Por Receta',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isIngredientSelected
                              ? const Color(0xFF129575)
                              : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Title based on selection
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isIngredientSelected
                          ? 'Ingredientes Pendientes'
                          : selectedShoppingList == null
                              ? 'Recetas en Lista de Compras'
                              : selectedShoppingList!.recipeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF121212),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedShoppingList != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF129575)),
                      onPressed: () {
                        setState(() {
                          selectedShoppingList = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            // Content based on selection
            Expanded(
              child: isIngredientSelected
                  ? FutureBuilder<List<ShoppingListResponse>>(
                      future: profileId == null
                          ? Future.value([])
                          : shoppingListController
                              .listShoppingListsByProfile(profileId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child:
                                  Text('No se encontraron listas de compras'));
                        }
                        final shoppingLists = snapshot.data!;
                        return IngredientsPendingList(
                          shoppingLists: shoppingLists,
                          ingredientController: ingredientController,
                          searchTerm: searchTerm,
                        );
                      },
                    )
                  : selectedShoppingList == null
                      ? FutureBuilder<List<ShoppingListResponse>>(
                          future: profileId == null
                              ? Future.value(
                                  []) // No cargar todavía si no hay profileId
                              : shoppingListController
                                  .listShoppingListsByProfile(profileId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text(
                                      'No se encontraron listas de compras'));
                            }
                            final shoppingLists = snapshot.data!;
                            return RecipesPendingList(
                              shoppingLists: shoppingLists,
                              onShoppingListSelected: (shoppingList) {
                                setState(() {
                                  selectedShoppingList = shoppingList;
                                });
                              },
                              searchTerm: searchTerm,
                            );
                          },
                        )
                      : RecipeIngredientsList(
                          shoppingList: selectedShoppingList!,
                          ingredientController: ingredientController,
                          searchTerm: searchTerm,
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 3,
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

class IngredientsPendingList extends StatelessWidget {
  final List<ShoppingListResponse> shoppingLists;
  final IngredientController ingredientController;
  final String searchTerm;

  const IngredientsPendingList(
      {required this.shoppingLists,
      required this.ingredientController,
      required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IngredientResponse>>(
      future: _fetchIngredients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron ingredientes'));
        }

        // Filtrar ingredientes por término de búsqueda
        final filteredIngredients = snapshot.data!.where((ingredient) {
          return ingredient.ingredientName
              .toLowerCase()
              .contains(searchTerm.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredIngredients.length,
          itemBuilder: (context, index) {
            final ingredient = filteredIngredients[index];
            return IngredientCard(
              ingredient: ingredient,
            );
          },
        );
      },
    );
  }

  Future<List<IngredientResponse>> _fetchIngredients() async {
    Set<IngredientResponse> ingredients = {};
    for (var shoppingList in shoppingLists) {
      // Aquí puedes obtener la lista de ingredientes por lista de compras
      final shoppingListIngredients = await ingredientController
          .listIngredientsByShoppingList(shoppingList.shoppingListId);
      ingredients.addAll(shoppingListIngredients);
    }
    return ingredients.toList();
  }
}

class RecipesPendingList extends StatelessWidget {
  final List<ShoppingListResponse> shoppingLists;
  final Function(ShoppingListResponse) onShoppingListSelected;
  final String searchTerm;

  const RecipesPendingList(
      {required this.shoppingLists,
      required this.onShoppingListSelected,
      required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    // Filtrar listas de compras por término de búsqueda
    final filteredShoppingLists = shoppingLists.where((shoppingList) {
      return shoppingList.recipeName
          .toLowerCase()
          .contains(searchTerm.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredShoppingLists.length,
      itemBuilder: (context, index) {
        final shoppingList = filteredShoppingLists[index];
        return GestureDetector(
          onTap: () {
            onShoppingListSelected(shoppingList);
          },
          child: ShoppingListCard(shoppingList: shoppingList),
        );
      },
    );
  }
}

class RecipeIngredientsList extends StatelessWidget {
  final ShoppingListResponse shoppingList;
  final IngredientController ingredientController;
  final String searchTerm;

  const RecipeIngredientsList(
      {required this.shoppingList,
      required this.ingredientController,
      required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IngredientResponse>>(
      future: ingredientController
          .listIngredientsByShoppingList(shoppingList.shoppingListId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron ingredientes'));
        }

        // Filtrar ingredientes por término de búsqueda
        final filteredIngredients = snapshot.data!.where((ingredient) {
          return ingredient.ingredientName
              .toLowerCase()
              .contains(searchTerm.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredIngredients.length,
          itemBuilder: (context, index) {
            final ingredient = filteredIngredients[index];
            return IngredientCard(
              ingredient: ingredient,
            );
          },
        );
      },
    );
  }
}

class IngredientCard extends StatelessWidget {
  final IngredientResponse ingredient;

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
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              "${ingredient.quantity} ${ingredient.measurementUnit}",
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingListCard extends StatelessWidget {
  final ShoppingListResponse shoppingList;

  const ShoppingListCard({required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              shoppingList.recipeName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
