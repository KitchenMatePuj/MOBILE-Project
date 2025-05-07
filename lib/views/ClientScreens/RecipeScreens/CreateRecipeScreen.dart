import 'package:mobile_kitchenmate/controllers/Recipes/recipe_steps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipe_steps_request.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_request.dart';
import 'package:mobile_kitchenmate/utils/animations_utils.dart';
import '../../../models/Recipes/ingredients_request.dart';
import '../../../models/Recipes/ingredients_response.dart';
import '../../../controllers/Recipes/ingredients.dart';
import '../../../models/Recipes/ingredients_response.dart';
import '../../../models/Recipes/ingredients_request.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_kitchenmate/controllers/strapi/strapi_controller.dart';
import 'package:mobile_kitchenmate/models/strapi/strapi_request.dart';
import 'package:mobile_kitchenmate/models/strapi/strapi_response.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // Import the services package for input formatters

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';

import 'package:mobile_kitchenmate/controllers/Recipes/categories.dart';
import 'package:mobile_kitchenmate/models/Recipes/categories_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/categories_request.dart';

// Default lists for ingredients and units
const List<String> defaultUnits = [
  'Otro',
  'Gramos',
  'Mililitros',
  'Cucharadas',
  'Cucharadita',
  'Tazas',
  'Pizca'
];

// const String keycloakUserId = 'user1234';

final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
final String strapiBaseUrl = dotenv.env['STRAPI_URL'] ?? '';
final String authbaseUrl = dotenv.env['AUTH_URL'] ?? '';
final String reportBaseUrl = dotenv.env['REPORT_URL'] ?? '';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController preparationTimeController =
      TextEditingController();
  final TextEditingController portionsController = TextEditingController();
  int selectedIndex = 0; // 0 = Detalles, 1 = Ingredientes, 2 = Procedimiento
  List<Ingredient> ingredients = [
    Ingredient(name: "", quantity: "", unit: ""),
    Ingredient(name: "", quantity: "", unit: ""),
    Ingredient(name: "", quantity: "", unit: ""),
  ];

  final IngredientController ingredientController =
      IngredientController(baseUrl: recipeBaseUrl);
  final RecipeController recipeController =
      RecipeController(baseUrl: recipeBaseUrl);
  final RecipeStepController stepController =
      RecipeStepController(baseUrl: recipeBaseUrl);
  final StrapiController strapiController =
      StrapiController(baseUrl: strapiBaseUrl);
  final CategoryController categoryController =
      CategoryController(baseUrl: recipeBaseUrl);

  late StrapiController _strapiCtl;

  late TextEditingController _timeController;
  late TextEditingController _portionController;

  late TextEditingController servingsController;
  late TextEditingController cookingTimeController;

  final AuthController _authController = AuthController(baseUrl: authbaseUrl);
  Uint8List? _imageBytes;

  List<String> steps = [
    "Describa este paso por favor.",
    "Describa este paso por favor.",
    "Describa este paso por favor."
  ];
  List<IngredientResponse> fetchedIngredients = [];
  List<CategoryResponse> availableCategories = [];
  bool _isLoadingCategories = true;
  CategoryResponse? selectedCategory;
  String estimatedTime = "";
  String estimatedPortions = "";
  String category = '';
  String recipeTitle = "";
  File? _image;
  String keycloakUserId = '';
  bool _isSubmitting = false;

  // ⓵ ───── Barra de navegación inferior ────────────────────────────────
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF129575),
      unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
      currentIndex: 2, // pestaña “Publicar” seleccionada
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, '/recipe_search');
            break;
          case 2:
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

// ⓶ ───── Botón “+ Ingrediente” reutilizable ──────────────────────────
  Widget _buildAddIngredientButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              ingredients.add(Ingredient(name: '', quantity: '', unit: ''));
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF129575),
            foregroundColor: Colors.white,
          ),
          child: const Text('Agregar Ingrediente'),
        ),
      ),
    );
  }

// ⓷ ───── Botón “+ Paso” reutilizable ─────────────────────────────────
  Widget _buildAddStepButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              steps.add('Describa este paso por favor.');
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF129575),
            foregroundColor: Colors.white,
          ),
          child: const Text('Agregar Paso'),
        ),
      ),
    );
  }

// ⓸ ───── Lógica de submit extraída ───────────────────────────────────
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return; // evita doble click
    setState(() => _isSubmitting = true);

    try {
      // Validación rápida
      if (recipeTitle.isEmpty ||
          estimatedTime.isEmpty ||
          estimatedPortions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Completa todos los campos antes de confirmar.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // 1️⃣  Crear receta (sin imagen todavía)
      final newRecipe = await recipeController.createRecipe(
        RecipeRequest(
          title: recipeTitle,
          categoryId: selectedCategory?.categoryId ?? 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cookingTime: int.parse(estimatedTime.replaceAll(' min', '')),
          foodType: 'General',
          totalPortions:
              int.parse(estimatedPortions.replaceAll(' porciones', '')),
          keycloakUserId: keycloakUserId,
          imageUrl: null,
        ),
      );
      final recipeId = newRecipe.recipeId;

      // 2️⃣  Si hay foto -> súbela y actualiza
      if (_image != null) {
        final url = await _uploadRecipeImage(recipeId);
        if (url != null) {
          await recipeController.updateRecipeImage(recipeId, url);
        }
      }

      // 3️⃣  Crear pasos e ingredientes en paralelo
      await Future.wait([
        ...steps.asMap().entries.map((e) {
          return stepController.createStep(
            recipeId,
            RecipeStepRequest(
              stepNumber: e.key + 1,
              title: 'Paso ${e.key + 1}',
              description: e.value,
            ),
          );
        }),
        ...ingredients.map((ing) {
          return ingredientController.createIngredient(
            IngredientRequest(
              name: ing.name,
              measurementUnit: '${ing.quantity} ${ing.unit}',
              recipeId: recipeId,
            ),
          );
        }),
      ]);

      // 4️⃣  Todo OK
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Receta creada exitosamente'),
        backgroundColor: Color(0xFF129575),
      ));
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Error al crear la receta: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> fetchCategoriesFromBackend() async {
    try {
      final categories = await categoryController.fetchCategories();
      setState(() {
        availableCategories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print("❌ Error al cargar categorías: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 1. operaciones asíncronas
      final bytes = await pickedFile.readAsBytes();
      final imageFile = File(pickedFile.path);

      // 2. actualización síncrona del estado.
      setState(() {
        _image = imageFile;
        _imageBytes = bytes;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _strapiCtl = StrapiController(baseUrl: strapiBaseUrl);

    _authController.getKeycloakUserId().then((id) {
      keycloakUserId = id;
    });

    fetchIngredientsFromBackend();
    fetchCategoriesFromBackend();

    _timeController =
        TextEditingController(text: estimatedTime.replaceAll(' min', ''));
    _portionController = TextEditingController(
        text: estimatedPortions.replaceAll(' porciones', ''));

    servingsController = TextEditingController();
    cookingTimeController = TextEditingController();
  }

  Future<void> fetchIngredientsFromBackend() async {
    try {
      final ingredients = await ingredientController.fetchIngredients();
      setState(() {
        fetchedIngredients = ingredients;
      });
    } catch (e) {
      print("❌ Error al cargar ingredientes: $e");
    }
  }

  String _mimeFromExt(String ext) {
    switch (ext.toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.svg':
        return 'image/svg+xml';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String?> _uploadRecipeImage(int recipeId) async {
    if (!kIsWeb && _image == null) return null;
    if (kIsWeb && _imageBytes == null) return null;

    final req = kIsWeb
        ? StrapiUploadRequest.fromBytes(
            bytes: _imageBytes!,
            filename: 'r$recipeId.jpg', // o usa extensión real
            mimeType: 'image/jpeg',
          )
        : StrapiUploadRequest.fromFile(_image!);

    final resp = await _strapiCtl.uploadImage(req);
    return '${dotenv.env['STRAPI_URL']}${resp.url}';
  }

  @override
  Widget build(BuildContext context) {
    // ⬇️ cuánto ocupa el teclado en este frame
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // permitir que el teclado ajuste la pantalla
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creación de Receta'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoadingCategories
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF129575)),
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen de la receta ----------------------------------------------------
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[800],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: _imageBytes != null
                                  ? Image.memory(_imageBytes!,
                                      fit: BoxFit.cover, width: double.infinity)
                                  : Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.white, size: 50),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tabs -------------------------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTab('Detalles', 0),
                          _buildTab('Ingredientes', 1),
                          _buildTab('Procedimiento', 2),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Contenido por pestaña --------------------------------------------------
                      Expanded(
                        child: selectedIndex == 0
                            ? _buildDetailsSection()
                            : selectedIndex == 1
                                ? CustomScrollView(
                                    slivers: [
                                      SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            if (index == ingredients.length) {
                                              return _buildAddIngredientButton();
                                            }
                                            final ing = ingredients[index];
                                            return IngredientCard(
                                              ingredient: ing,
                                              index: index + 1,
                                              onDelete: () {
                                                setState(() {
                                                  ingredients.removeAt(index);
                                                });
                                              },
                                              availableIngredients:
                                                  fetchedIngredients,
                                              fetchedIngredients:
                                                  fetchedIngredients,
                                            );
                                          },
                                          childCount: ingredients.length + 1,
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    itemCount: steps.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == steps.length) {
                                        return _buildAddStepButton();
                                      }
                                      final step = steps[index];
                                      return StepCard(
                                        step: step,
                                        stepNumber: index + 1,
                                        onDelete: () {
                                          setState(() {
                                            steps.removeAt(index);
                                          });
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),

                // Botón Confirmar Receta Fijo ------------------------------------------
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF129575),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Confirmar Receta",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDetailsSection() {
    return ListView(
      children: [
        _buildDetailRow(
          label: "Nombre de la Receta",
          value: recipeTitle.length > 14
              ? "${recipeTitle.substring(0, 14)}..."
              : recipeTitle,
          onTap: () async {
            final controller = TextEditingController(text: recipeTitle);
            final result =
                await _showTextInputDialog("Título de la Receta", controller);
            if (result != null && result.isNotEmpty) {
              setState(() {
                recipeTitle = result;
              });
            }
          },
        ),
        _buildDetailRow(
          label: "Categoría de tu Receta",
          value: selectedCategory?.name ?? '',
          onTap: () async {
            final result = await _showCategoryPickerDialog();
            if (result != null) {
              setState(() {
                selectedCategory = result;
              });
            }
          },
        ),
        _buildDetailRow(
          label: "Tiempo Estimado",
          value: estimatedTime,
          onTap: () async {
            // Asegúrate de que el controlador tenga el valor actual
            if (_timeController.text.isEmpty) {
              _timeController.text = estimatedTime.replaceAll(' min', '');
            }

            final result = await _showNumberInputDialog(
              "Tiempo Estimado",
              _timeController,
              "Ingrese el tiempo en minutos",
            );

            if (result != null && result.isNotEmpty) {
              setState(() {
                estimatedTime = "$result min";
              });
            }
          },
        ),
        _buildDetailRow(
          label: "Porciones Estimadas",
          value: estimatedPortions,
          onTap: () async {
            // Asegúrate de que el controlador tenga el valor actual
            if (_portionController.text.isEmpty) {
              _portionController.text =
                  estimatedPortions.replaceAll(' porciones', '');
            }

            final result = await _showNumberInputDialog(
              "Porciones Estimadas",
              _portionController,
              "Ingrese el número de porciones",
            );

            if (result != null && result.isNotEmpty) {
              setState(() {
                estimatedPortions = "$result porciones";
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 238, 238, 238),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(value, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, color: Colors.grey, size: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showTextInputDialog(
      String title, TextEditingController controller) {
    return showAnimatedDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF129575),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "Ingrese el texto",
                ),
                onTap: () {
                  if (controller.text.isEmpty) {
                    controller
                        .clear(); // Mantiene el texto si ya se ha ingresado algo
                  }
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 238, 99, 89),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: controller.text.isNotEmpty
                          ? () {
                              Navigator.pop(context, controller.text);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF129575),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showNumberInputDialog(
      String title, TextEditingController controller, String hint) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF129575),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(hintText: hint),
                onChanged: (value) {
                  setState(() {}); // Refresca la UI interna
                },
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: controller.text.isNotEmpty
                          ? () {
                              Navigator.pop(context, controller.text);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF129575),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<CategoryResponse?> _showCategoryPickerDialog() async {
    if (availableCategories.isEmpty) {
      return showAnimatedDialog<CategoryResponse>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("Cargando categorías..."),
            content: SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      );
    }

    final options = availableCategories.map((c) => c.name).toList();
    options.add("Otro");

    return showAnimatedDialog<CategoryResponse>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              "Selecciona una Categoría",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF129575),
              ),
            ),
          ),
          children: options.map((cat) {
            return SimpleDialogOption(
              child: Text(cat),
              onPressed: () async {
                if (cat == "Otro") {
                  final TextEditingController newCatController =
                      TextEditingController();
                  final String? newCatName = await _showTextInputDialog(
                      "Nueva Categoría", newCatController);
                  if (newCatName != null && newCatName.isNotEmpty) {
                    try {
                      final newCategory =
                          await categoryController.createCategory(
                        CategoryRequest(name: newCatName),
                      );
                      Navigator.pop(context, newCategory);
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear categoría: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                  }
                } else {
                  final selected =
                      availableCategories.firstWhere((c) => c.name == cat);
                  Navigator.pop(context, selected);
                }
              },
            );
          }).toList(),
        );
      },
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

  @override
  void dispose() {
    preparationTimeController.dispose();
    portionsController.dispose();
    super.dispose();
  }
}

class IngredientCard extends StatefulWidget {
  final Ingredient ingredient;
  final int index;
  final VoidCallback onDelete;
  final List<IngredientResponse> availableIngredients;
  final List<IngredientResponse> fetchedIngredients;

  const IngredientCard({
    required this.ingredient,
    required this.index,
    required this.onDelete,
    required this.availableIngredients,
    required this.fetchedIngredients,
  });

  @override
  _IngredientCardState createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 238, 238, 238),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ingrediente ${widget.index}:",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: DropdownButtonFormField<String>(
                    value: _getValidValue(widget.ingredient.name),
                    items: _buildIngredientItems(),
                    onChanged: (value) {
                      if (value == 'Otro') {
                        _showCustomIngredientDialog(context);
                      } else if (value != null) {
                        setState(() {
                          widget.ingredient.name = value;

                          // Opcional: Actualiza la unidad de medida si es necesario
                          final selected =
                              widget.availableIngredients.firstWhere(
                            (i) => i.name == value,
                            orElse: () => IngredientResponse(
                              ingredientId: -1,
                              recipeId: -1,
                              name: value,
                              measurementUnit: '',
                            ),
                          );
                          widget.ingredient.unit = selected.measurementUnit;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Seleccione un ingrediente",
                    ),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                IntrinsicWidth(
                  child: GestureDetector(
                    onTap: () {
                      _showQuantityDialog(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          widget.ingredient.quantity.isEmpty &&
                                  widget.ingredient.unit.isEmpty
                              ? "Cantidad"
                              : "${widget.ingredient.quantity} ${widget.ingredient.unit}",
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _getValidValue(String ingredientName) {
    final names = widget.availableIngredients.map((e) => e.name).toList();
    if (!names.contains(ingredientName)) return null;
    return ingredientName;
  }

  List<DropdownMenuItem<String>> _buildIngredientItems() {
    final uniqueList =
        widget.availableIngredients.map((e) => e.name).toSet().toList();
    final items = uniqueList.map((name) {
      return DropdownMenuItem<String>(
        value: name,
        child: Text(name),
      );
    }).toList();

    items.add(const DropdownMenuItem<String>(
      value: 'Otro',
      child: Text('Otro'),
    ));

    return items;
  }

  void _showCustomIngredientDialog(BuildContext context) {
    final TextEditingController customIngredientController =
        TextEditingController();

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Otro Ingrediente',
              style: TextStyle(
                color: Color(0xFF129575),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          content: TextField(
            controller: customIngredientController,
            decoration: const InputDecoration(
                hintText: "Ingrese el nombre del ingrediente"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final customIngredient = customIngredientController.text.trim();
                if (customIngredient.isNotEmpty) {
                  setState(() {
                    // Añadir el nuevo ingrediente a la lista de ingredientes disponibles
                    widget.fetchedIngredients.add(
                      IngredientResponse(
                        ingredientId:
                            -1, // Usa un ID temporal o único si es necesario
                        recipeId: -1,
                        name: customIngredient,
                        measurementUnit: '',
                      ),
                    );

                    // Actualizar el ingrediente seleccionado
                    widget.ingredient.name = customIngredient;
                  });
                }
                Navigator.pop(context, customIngredient);
              },
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
  }

  void _showQuantityDialog(BuildContext context) {
    final TextEditingController quantityController =
        TextEditingController(text: widget.ingredient.quantity);

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              "Cantidad",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF129575),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: "Ingrese la cantidad"),
              ),
              DropdownButtonFormField<String>(
                value: defaultUnits.contains(widget.ingredient.unit)
                    ? widget.ingredient.unit
                    : null,
                items: defaultUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    widget.ingredient.unit = value ?? "";
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Unidad de medida",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, quantityController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF129575),
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result.isNotEmpty) {
        setState(() {
          widget.ingredient.quantity = result;
        });
      }
    });
  }
}

void _showCustomUnitDialog(BuildContext context, Ingredient ingredient) {
  final TextEditingController customUnitController = TextEditingController();
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Otra Unidad',
            style: TextStyle(
              color: Color(0xFF129575),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        content: TextField(
          controller: customUnitController,
          keyboardType: TextInputType.text,
          decoration:
              const InputDecoration(hintText: "Ingrese la unidad de medida"),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 238, 99, 89),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, customUnitController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF129575),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ],
      );
    },
  ).then((result) {
    if (result != null && result.isNotEmpty) {
      ingredient.unit = result;
    }
  });
}

class StepCard extends StatelessWidget {
  final String step;
  final int stepNumber;
  final VoidCallback onDelete;

  const StepCard(
      {required this.step, required this.stepNumber, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final TextEditingController stepController =
            TextEditingController(text: step);
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Center(
                    child: Text(
                      'Editar Paso $stepNumber',
                      style: TextStyle(
                        color: Color(0xFF129575),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  content: TextField(
                    controller: stepController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        hintText: "Describa este paso por favor."),
                    onTap: () {
                      if (stepController.text ==
                          "Describa este paso por favor.") {
                        stepController.clear();
                      }
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 238, 99, 89),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: stepController.text.isNotEmpty &&
                                  stepController.text !=
                                      "Describa este paso por favor."
                              ? () {
                                  Navigator.pop(context, stepController.text);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF129575),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
        if (result != null && result.isNotEmpty) {
          (context as Element).markNeedsBuild();
          (context.findAncestorStateOfType<_CreateRecipeState>()!).setState(() {
            context
                .findAncestorStateOfType<_CreateRecipeState>()!
                .steps[stepNumber - 1] = result;
          });
        }
      },
      child: Card(
        color: Colors.grey[200],
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Paso $stepNumber",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: Colors.black, size: 16),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step,
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Ingredient {
  String name;
  String quantity;
  String unit;

  Ingredient({required this.name, required this.quantity, required this.unit});
}
