// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/models/ingredient_model.dart';
// import '/models/profile_model.dart';
// import '/models/recipe_ingredient_model.dart';
// import '/models/recipe_model.dart';
// import '/controllers/recipe_controller.dart';
// import '/controllers/ingredient_controller.dart';
// import '/controllers/profile_controller.dart';
// import '/providers/user_provider.dart';

// class ShoppingListScreen extends StatefulWidget {
//   const ShoppingListScreen({super.key});

//   @override
//   _ShoppingListScreenState createState() => _ShoppingListScreenState();
// }

// class _ShoppingListScreenState extends State<ShoppingListScreen> {
//   bool isIngredientSelected = true;
//   String searchTerm = '';
//   late Profile profile;
//   late RecipeController recipeController;
//   late IngredientController ingredientController;
//   Recipe? selectedRecipe;

//   @override
//   void initState() {
//     super.initState();
//     final profileController = ProfileController();
//     final user = Provider.of<UserProvider>(context, listen: false).user;
//     if (user != null) {
//       profile = profileController.recommendedProfiles.firstWhere((p) => p.email == user.email);
//     } else {
//       profile = profileController.recommendedProfiles.firstWhere((p) => p.keycloak_user_id == 11);
//     }
//     recipeController = RecipeController();
//     ingredientController = IngredientController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lista de Compras'),
//         backgroundColor: const Color(0xFF129575),
//         foregroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchTerm = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Buscar por Ingrediente',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Ingredient and Recipe options
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isIngredientSelected = true;
//                         selectedRecipe = null;
//                         searchTerm = '';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                       decoration: BoxDecoration(
//                         color: isIngredientSelected ? const Color(0xFF129575) : Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: const Color(0xFF129575)),
//                       ),
//                       child: Text(
//                         'Por Ingrediente',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: isIngredientSelected ? Colors.white : const Color(0xFF129575),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 30),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isIngredientSelected = false;
//                         selectedRecipe = null;
//                         searchTerm = '';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                       decoration: BoxDecoration(
//                         color: isIngredientSelected ? Colors.white : const Color(0xFF129575),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: const Color(0xFF129575)),
//                       ),
//                       child: Text(
//                         'Por Receta',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: isIngredientSelected ? const Color(0xFF129575) : Colors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             // Title based on selection
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                     Flexible(
//                     child: Text(
//                       isIngredientSelected
//                         ? 'Ingredientes Pendientes'
//                         : selectedRecipe == null
//                           ? 'Recetas en Lista de Compras'
//                           : selectedRecipe!.title,
//                       style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF121212),
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     ),
//                   if (selectedRecipe != null)
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Color(0xFF129575)),
//                       onPressed: () {
//                         setState(() {
//                           selectedRecipe = null;
//                         });
//                       },
//                     ),
//                 ],
//               ),
//             ),
//             // Content based on selection
//             Expanded(
//               child: isIngredientSelected
//                   ? IngredientsPendingList(
//                       profile: profile,
//                       ingredientController: ingredientController,
//                       searchTerm: searchTerm,
//                     )
//                   : selectedRecipe == null
//                       ? RecipesPendingList(
//                           recipeController: recipeController,
//                           profile: profile,
//                           onRecipeSelected: (recipe) {
//                             setState(() {
//                               selectedRecipe = recipe;
//                             });
//                           },
//                           searchTerm: searchTerm,
//                         )
//                       : RecipeIngredientsList(
//                           recipe: selectedRecipe!,
//                           ingredientController: ingredientController,
//                           searchTerm: searchTerm,
//                         ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFF129575),
//         unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
//         currentIndex: 3,
//         onTap: (int index) {
//           switch (index) {
//             case 0:
//               Navigator.pushNamed(context, '/dashboard');
//               break;
//             case 1:
//               Navigator.pushNamed(context, '/recipe_search');
//               break;
//             case 2:
//               Navigator.pushNamed(context, '/create');
//               break;
//             case 3:
//               break;
//             case 4:
//               Navigator.pushNamed(context, '/profile');
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Inicio',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Buscar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.add),
//             label: 'Publicar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list),
//             label: 'Compras',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Perfil',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class IngredientsPendingList extends StatelessWidget {
//   final Profile profile;
//   final IngredientController ingredientController;
//   final String searchTerm;

//   const IngredientsPendingList({required this.profile, required this.ingredientController, required this.searchTerm});

//   @override
//   Widget build(BuildContext context) {
//     // Obtener ingredientes de las recetas en la lista de compras del usuario
//     Set<RecipeIngredient> ingredients = {};
//     for (var recipeId in profile.shopping_list_recipes) {
//       ingredients.addAll(ingredientController.getIngredientsByRecipeId(recipeId.toString()));
//     }

//     // Agrupar ingredientes repetidos y sumar cantidades
//     final Map<String, RecipeIngredient> groupedIngredients = {};
//     for (var recipeIngredient in ingredients) {
//       final key = '${recipeIngredient.ingredientId}-${recipeIngredient.unit}';
//       if (groupedIngredients.containsKey(key)) {
//         final existing = groupedIngredients[key]!;
//         final newQuantity = double.parse(existing.quantity) + double.parse(recipeIngredient.quantity);
//         groupedIngredients[key] = RecipeIngredient(
//           recipeId: existing.recipeId,
//           ingredientId: existing.ingredientId,
//           quantity: newQuantity.toString(),
//           unit: existing.unit,
//         );
//       } else {
//         groupedIngredients[key] = recipeIngredient;
//       }
//     }

//     // Convertir a lista y filtrar por término de búsqueda
//     final filteredIngredients = groupedIngredients.values.where((recipeIngredient) {
//       final ingredient = ingredientController.allIngredients.firstWhere((ing) => ing.ingredientId == recipeIngredient.ingredientId);
//       return ingredient.ingredientName.toLowerCase().contains(searchTerm.toLowerCase());
//     }).toList();

//     return ListView.builder(
//       itemCount: filteredIngredients.length,
//       itemBuilder: (context, index) {
//         final recipeIngredient = filteredIngredients[index];
//         final ingredient = ingredientController.allIngredients.firstWhere((ing) => ing.ingredientId == recipeIngredient.ingredientId);
//         return IngredientCard(
//           ingredient: ingredient,
//           quantity: recipeIngredient.quantity,
//           unit: recipeIngredient.unit,
//         );
//       },
//     );
//   }
// }

// class RecipesPendingList extends StatelessWidget {
//   final RecipeController recipeController;
//   final Profile profile;
//   final Function(Recipe) onRecipeSelected;
//   final String searchTerm;

//   const RecipesPendingList({required this.recipeController, required this.profile, required this.onRecipeSelected, required this.searchTerm});

//   @override
//   Widget build(BuildContext context) {
//     // Obtener recetas en la lista de compras del usuario
//     List<Recipe> recipes = profile.shopping_list_recipes.map((recipeId) {
//       return recipeController.allRecipes.firstWhere((recipe) => recipe.recipeId == recipeId.toString());
//     }).toList();

//     // Filtrar recetas por término de búsqueda
//     final filteredRecipes = recipes.where((recipe) {
//       return recipe.title.toLowerCase().contains(searchTerm.toLowerCase());
//     }).toList();

//     return ListView.builder(
//       itemCount: filteredRecipes.length,
//       itemBuilder: (context, index) {
//         final recipe = filteredRecipes[index];
//         return GestureDetector(
//           onTap: () {
//             onRecipeSelected(recipe);
//           },
//           child: RecipeCard(recipe: recipe),
//         );
//       },
//     );
//   }
// }

// class RecipeCard extends StatelessWidget {
//   final Recipe recipe;

//   const RecipeCard({required this.recipe});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white,
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10.0),
//             child: ColorFiltered(
//               colorFilter: ColorFilter.mode(
//                 Colors.black.withOpacity(0.3),
//                 BlendMode.darken,
//               ),
//               child: Image.asset(
//                 recipe.imageUrl,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 150,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 8,
//             right: 8,
//             child: Text(
//               recipe.title.length > 30 ? '${recipe.title.substring(0, 27)}...' : recipe.title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RecipeIngredientsList extends StatelessWidget {
//   final Recipe recipe;
//   final IngredientController ingredientController;
//   final String searchTerm;

//   const RecipeIngredientsList({required this.recipe, required this.ingredientController, required this.searchTerm});

//   @override
//   Widget build(BuildContext context) {
//     final ingredients = ingredientController.getIngredientsByRecipeId(recipe.recipeId);

//     // Filtrar ingredientes por término de búsqueda
//     final filteredIngredients = ingredients.where((recipeIngredient) {
//       final ingredient = ingredientController.allIngredients.firstWhere((ing) => ing.ingredientId == recipeIngredient.ingredientId);
//       return ingredient.ingredientName.toLowerCase().contains(searchTerm.toLowerCase());
//     }).toList();

//     return ListView.builder(
//       itemCount: filteredIngredients.length,
//       itemBuilder: (context, index) {
//         final recipeIngredient = filteredIngredients[index];
//         final ingredient = ingredientController.allIngredients.firstWhere((ing) => ing.ingredientId == recipeIngredient.ingredientId);
//         return IngredientCard(
//           ingredient: ingredient,
//           quantity: recipeIngredient.quantity,
//           unit: recipeIngredient.unit,
//         );
//       },
//     );
//   }
// }

// class IngredientCard extends StatelessWidget {
//   final Ingredient ingredient;
//   final String quantity;
//   final String unit;

//   const IngredientCard({
//     required this.ingredient, 
//     required this.quantity, 
//     required this.unit
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.grey[200],
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               ingredient.ingredientName,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//             ),
//             Text(
//               "$quantity $unit",
//               style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }