import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/Profiles/shopping_list_controller.dart';
import '/controllers/Profiles/ingredient_controller.dart';
import '/models/Profiles/ingredient_response.dart';
import '/models/Profiles/shopping_list_response.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/controllers/authentication/auth_controller.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool isIngredientSelected = true;
  String searchTerm = '';
  String keycloakUserId = '';
  int? profileId;
  late ShoppingListController shoppingListController;
  late IngredientController ingredientController;
  late ProfileController profileController;
  ShoppingListResponse? selectedShoppingList;
  List<ShoppingListResponse>? shoppingListsCache;

  final profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final authBaseUrl = dotenv.env['AUTH_URL'] ?? '';
  final _authBase = dotenv.env['AUTH_URL'] ?? '';
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    shoppingListController = ShoppingListController(baseUrl: profileBaseUrl);
    ingredientController = IngredientController(baseUrl: profileBaseUrl);
    profileController = ProfileController(baseUrl: profileBaseUrl);
    _authController = AuthController(baseUrl: _authBase);

    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    try {
      final keycloakId = await _authController.getKeycloakUserId();
      setState(() {
        keycloakUserId = keycloakId;
      });

      final profile = await profileController.getProfile(keycloakId);
      setState(() {
        profileId = profile.profileId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inicializar el perfil: $e')),
      );
    }
  }

  Future<void> _fetchShoppingLists() async {
    try {
      final lists =
          await shoppingListController.listShoppingListsByProfile(profileId!);
      setState(() {
        shoppingListsCache = lists; //  guarda la lista
      });
    } catch (e) {
      debugPrint('Error al obtener listas de compras: $e');
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
      body: profileId == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSelectionOption(
                        'Por Ingrediente',
                        isIngredientSelected,
                        () {
                          setState(() {
                            isIngredientSelected = true;
                            selectedShoppingList = null;
                            searchTerm = '';
                          });
                        },
                      ),
                      const SizedBox(width: 30),
                      _buildSelectionOption(
                        'Por Receta',
                        !isIngredientSelected,
                        () {
                          setState(() {
                            isIngredientSelected = false;
                            selectedShoppingList = null;
                            searchTerm = '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                  Expanded(
                    child: isIngredientSelected
                        ? FutureBuilder<List<IngredientResponse>>(
                            future: _fetchAllIngredients(),
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
                                        Text('No se encontraron ingredientes'));
                              }

                              final ingredients = snapshot.data!
                                  .where((ingredient) => ingredient
                                      .ingredientName
                                      .toLowerCase()
                                      .contains(searchTerm.toLowerCase()))
                                  .toList();

                              return ListView.builder(
                                itemCount: ingredients.length,
                                itemBuilder: (context, index) {
                                  final ingredient = ingredients[index];
                                  return IngredientCard(
                                    ingredient: ingredient,
                                  );
                                },
                              );
                            },
                          )
                        : _buildRecipeContent(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Future<List<IngredientResponse>> _fetchAllIngredients() async {
    try {
      final shoppingLists =
          await shoppingListController.listShoppingListsByProfile(profileId!);

      List<IngredientResponse> allIngredients = [];
      for (var shoppingList in shoppingLists) {
        final listIngredients = await ingredientController
            .listIngredientsByShoppingList(shoppingList.shoppingListId);
        allIngredients.addAll(listIngredients);
      }
      return allIngredients;
    } catch (e, stackTrace) {
      print('Error al obtener los ingredientes: $e');
      print('StackTrace: $stackTrace');
      throw Exception('Error al obtener los ingredientes: $e');
    }
  }

  Widget _buildSelectionOption(
      String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF129575) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF129575)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF129575),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeContent() {
    return selectedShoppingList == null
        ? FutureBuilder<List<ShoppingListResponse>>(
            future: shoppingListsCache == null
                ? shoppingListController.listShoppingListsByProfile(profileId!)
                : Future.value(shoppingListsCache),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No se encontraron listas de compras'));
              }

              final shoppingLists = snapshot.data!;
              return RecipesPendingList(
                shoppingLists: shoppingLists,
                onShoppingListSelected: (shoppingList) {
                  setState(() => selectedShoppingList = shoppingList);
                },
                onShoppingListDeleted: () async {
                  // cuando el hijo avise ⇒ vaciamos la caché y recargamos
                  setState(() => shoppingListsCache = null);
                  await _fetchShoppingLists();
                },
                shoppingListController: shoppingListController,
                searchTerm: searchTerm,
              );
            },
          )
        : RecipeIngredientsList(
            shoppingList: selectedShoppingList!,
            ingredientController: ingredientController,
            searchTerm: searchTerm,
          );
  }

  Future<List<IngredientResponse>> _fetchFilteredIngredients() async {
    try {
      // Obtén las listas de compras del perfil
      final shoppingLists =
          await shoppingListController.listShoppingListsByProfile(profileId!);

      // Extrae los recipe_id de las listas de compras
      final recipeIds =
          shoppingLists.map((list) => list.shoppingListId).toSet();

      // Acumula ingredientes de todas las listas de compras
      List<IngredientResponse> allIngredients = [];
      for (var shoppingList in shoppingLists) {
        final listIngredients = await ingredientController
            .listIngredientsByShoppingList(shoppingList.shoppingListId);
        allIngredients.addAll(listIngredients);
      }

      // Filtra ingredientes únicos y por recipe_id
      return allIngredients
          .where((ingredient) => recipeIds.contains(ingredient.shoppingListId))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener los ingredientes: $e');
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
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
    );
  }
}

class IngredientsPendingList extends StatelessWidget {
  final List<ShoppingListResponse> shoppingLists;
  final ShoppingListController shoppingListController; // Añadido
  final IngredientController ingredientController; // Añadido
  final int profileId; // Añadido
  final String searchTerm;

  const IngredientsPendingList({
    required this.shoppingLists,
    required this.shoppingListController, // Añadido
    required this.ingredientController, // Añadido
    required this.profileId, // Añadido
    required this.searchTerm,
  });

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
    try {
      // Usa el controlador para obtener las listas de compras
      final shoppingLists =
          await shoppingListController.listShoppingListsByProfile(profileId);

      List<IngredientResponse> allIngredients = [];
      for (var shoppingList in shoppingLists) {
        // Usa el controlador de ingredientes
        final listIngredients = await ingredientController
            .listIngredientsByShoppingList(shoppingList.shoppingListId);
        allIngredients.addAll(listIngredients);
      }

      return allIngredients;
    } catch (e) {
      throw Exception('Error al obtener los ingredientes: $e');
    }
  }
}

class RecipesPendingList extends StatelessWidget {
  final List<ShoppingListResponse> shoppingLists;
  final Function(ShoppingListResponse) onShoppingListSelected;
  final Function() onShoppingListDeleted;
  final ShoppingListController shoppingListController;
  final String searchTerm;

  const RecipesPendingList({
    required this.shoppingLists,
    required this.onShoppingListSelected,
    required this.onShoppingListDeleted,
    required this.shoppingListController,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    final filteredShoppingLists = shoppingLists.where((shoppingList) {
      return shoppingList.recipeName
          .toLowerCase()
          .contains(searchTerm.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredShoppingLists.length,
      itemBuilder: (context, index) {
        final shoppingList = filteredShoppingLists[index];
        return Card(
          child: ListTile(
            title: Text(shoppingList.recipeName),
            subtitle: Text('Receta de la lista de compras'),
            leading: shoppingList.recipePhoto != null &&
                    shoppingList.recipePhoto!.isNotEmpty
                ? Image.network(
                    shoppingList.recipePhoto!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                        'assets/recipes/recipe_placeholder.jpg',
                        width: 56,
                        height: 56),
                  )
                : Image.asset('assets/recipes/recipe_placeholder.jpg',
                    width: 56, height: 56),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar lista'),
                    content: const Text(
                        '¿Estás seguro de que deseas eliminar esta lista de compras?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await shoppingListController
                        .deleteShoppingList(shoppingList.shoppingListId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Lista eliminada exitosamente')),
                    );
                    onShoppingListDeleted(); // <--- Refrescar listas
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar la lista: $e')),
                    );
                  }
                }
              },
            ),
          ),
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
              "${ingredient.measurementUnit}",
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
