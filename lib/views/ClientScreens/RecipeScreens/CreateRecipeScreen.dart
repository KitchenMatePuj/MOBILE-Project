import 'package:mobile_kitchenmate/controllers/Recipes/recipe_steps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipe_steps_request.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_request.dart';
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

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipeScreen> {
  int selectedIndex = 0;
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

  late StrapiController _strapiCtl;
  final AuthController _authController=AuthController(baseUrl: authbaseUrl);
  Uint8List? _imageBytes;

  List<String> steps = [
    "Describa este paso por favor.",
    "Describa este paso por favor.",
    "Describa este paso por favor."
  ];
  List<IngredientResponse> fetchedIngredients = [];
  String estimatedTime = "Tiempo estimado ";
  String estimatedPortions = "Porciones estimadas ";
  File? _image;
  String recipeTitle = "Nombre de la Receta";
  String keycloakUserId = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 1. operaciones asíncronas
      final bytes = await pickedFile.readAsBytes();
      final imageFile = File(pickedFile.path);

      // 2. actualización síncrona del estado
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creación de Receta'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
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
                        ? Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Center(
                            child: IconButton(
                              icon: Icon(Icons.add,
                                  color: Colors.white, size: 50),
                              onPressed: _pickImage,
                            ),
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
                      GestureDetector(
                        onTap: () async {
                          final TextEditingController timeController =
                              TextEditingController();
                          final result = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Center(
                                      child: Text(
                                        'Tiempo Estimado',
                                        style: TextStyle(
                                          color: Color(0xFF129575),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    content: TextField(
                                      controller: timeController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // PRIMERA RESTRICCIÓN
                                      decoration: const InputDecoration(
                                          hintText:
                                              "Ingrese el tiempo en minutos"),
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 238, 99, 89),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: timeController
                                                    .text.isNotEmpty
                                                ? () {
                                                    Navigator.pop(context,
                                                        timeController.text);
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF129575),
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
                            setState(() {
                              estimatedTime = "$result min";
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              estimatedTime,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title input for recipe name
            GestureDetector(
              onTap: () async {
                final TextEditingController titleController =
                    TextEditingController();
                final result = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Center(
                        child: Text(
                          'Título de la Receta',
                          style: TextStyle(
                            color: Color(0xFF129575),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: TextField(
                        controller: titleController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            hintText: "Ingrese el título de la receta"),
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
                              onPressed: () {
                                Navigator.pop(context, titleController.text);
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
                );
                if (result != null && result.isNotEmpty) {
                  setState(() {
                    recipeTitle = result;
                  });
                }
              },
              child: Row(
                children: [
                  Text(
                    recipeTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, color: Colors.black, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                    GestureDetector(
                      onTap: () async {
                        final TextEditingController portionsController =
                            TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Center(
                                    child: Text(
                                      'Porciones Estimadas',
                                      style: TextStyle(
                                        color: Color(0xFF129575),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  content: TextField(
                                    controller: portionsController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ], // SEGUNDA RESTRICCIÓN
                                    decoration: const InputDecoration(
                                        hintText:
                                            "Ingrese el número de porciones"),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 238, 99, 89),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: portionsController
                                                  .text.isNotEmpty
                                              ? () {
                                                  Navigator.pop(context,
                                                      portionsController.text);
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
                          setState(() {
                            estimatedPortions = "$result porciones";
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            estimatedPortions,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, color: Colors.grey, size: 16),
                        ],
                      ),
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
                      itemCount: ingredients.length + 1,
                      itemBuilder: (context, index) {
                        if (index == ingredients.length) {
                          return Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    ingredients.add(Ingredient(
                                        name: "", quantity: "", unit: ""));
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF129575),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("Agregar Ingrediente"),
                              ),
                            ),
                          );
                        }
                        final ingredient = ingredients[index];
                        return IngredientCard(
                          ingredient: ingredient,
                          index: index + 1,
                          onDelete: () {
                            setState(() {
                              ingredients.removeAt(index);
                            });
                          },
                          availableIngredients: fetchedIngredients,
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: steps.length + 1,
                      itemBuilder: (context, index) {
                        if (index == steps.length) {
                          return Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    steps.add("Describa este paso por favor.");
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF129575),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("Agregar Paso"),
                              ),
                            ),
                          );
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // 0️⃣ Validación rápida
                    if (recipeTitle.isEmpty ||
                        estimatedTime == "Tiempo estimado " ||
                        estimatedPortions == "Porciones estimadas ") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, complete todos los campos antes de confirmar la receta.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // 1️⃣ POST /recipes  (sin imagen todavía)
                    final newRecipe = await recipeController.createRecipe(
                      RecipeRequest(
                        title: recipeTitle,
                        categoryId: 1,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        cookingTime:
                            int.parse(estimatedTime.replaceAll(' min', '')),
                        foodType: 'General',
                        totalPortions: int.parse(
                            estimatedPortions.replaceAll(' porciones', '')),
                        keycloakUserId: keycloakUserId,
                        imageUrl: null,
                      ),
                    );

                    final int recipeId = newRecipe.recipeId;

                    // 2️⃣ Si hay foto -> súbela a Strapi y actualiza la receta
                    if (_image != null) {
                      final imageUrl = await _uploadRecipeImage(recipeId);
                      if (imageUrl != null) {
                        await recipeController.updateRecipeImage(
                            recipeId, imageUrl);
                      }
                    }

                    // 3️⃣ Pasos
                    for (var i = 0; i < steps.length; i++) {
                      await stepController.createStep(
                        recipeId,
                        RecipeStepRequest(
                          stepNumber: i + 1,
                          title: 'Paso ${i + 1}',
                          description: steps[i],
                        ),
                      );
                    }

                    // 4️⃣ Ingredientes
                    for (var ing in ingredients) {
                      await ingredientController.createIngredient(
                        IngredientRequest(
                          name: ing.name,
                          measurementUnit: ing.unit,
                          recipeId: recipeId,
                        ),
                      );
                    }

                    // 5️⃣ Éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Receta creada exitosamente.'),
                        backgroundColor: Color(0xFF129575),
                      ),
                    );
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error al crear la receta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Confirmar Receta", // Este es el texto del botón
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
        currentIndex: 2, // It is the 'selectedItemColor'
        onTap: (int index) {
          switch (index) {
            case 0:
              // Navegate to Dashboard
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 1:
              // Navegate to Search
              Navigator.pushNamed(context, '/recipe_search');
              break;
            case 2:
              break;
            case 3:
              // Navegate to Shopping List
              Navigator.pushNamed(context, '/shopping_list');
              break;
            case 4:
              // Navegate to Profile
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
}

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final int index;
  final VoidCallback onDelete;
  final List<IngredientResponse> availableIngredients;

  const IngredientCard(
      {required this.ingredient,
      required this.index,
      required this.onDelete,
      required this.availableIngredients});

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
                  "Ingrediente $index:",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _getValidValue(ingredient.name),
                    items: _buildIngredientItems(),
                    onChanged: (value) {
                      if (value == 'Otro') {
                        _showCustomIngredientDialog(context, ingredient);
                      } else if (value != null) {
                        ingredient.name = value;
                        final selected = availableIngredients.firstWhere(
                          (i) => i.name == value,
                          orElse: () => IngredientResponse(
                            ingredientId: -1,
                            recipeId: -1, // ID ficticio para "Otro"
                            name: value,
                            measurementUnit: '',
                          ),
                        );
                        ingredient.unit = selected.measurementUnit;
                      }
                      (context as Element).markNeedsBuild();
                    },
                    decoration: const InputDecoration(
                      hintText: "Seleccione un ingrediente",
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      _showQuantityDialog(context, ingredient);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ingredient.quantity.isEmpty && ingredient.unit.isEmpty
                              ? "Cantidad"
                              : "${ingredient.quantity} ${ingredient.unit}",
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

  void _showCustomIngredientDialog(
      BuildContext context, Ingredient ingredient) {
    final TextEditingController customIngredientController =
        TextEditingController();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
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
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
                hintText: "Ingrese el nombre del ingrediente"),
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
                    Navigator.pop(context, customIngredientController.text);
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
        ingredient.name = result;
      }
    });
  }

  String? _getValidValue(String ingredientName) {
    final names = availableIngredients.map((e) => e.name).toList();
    // Si no está en la lista, devuelvo null
    if (!names.contains(ingredientName)) return null;

    // Ver cuántas veces aparece
    final occurrences = names.where((n) => n == ingredientName).length;
    return occurrences == 1 ? ingredientName : null;
  }

  /// Construye la lista de items sin duplicados y con "Otro"
  List<DropdownMenuItem<String>> _buildIngredientItems() {
    // Evitar duplicados y mapear a DropdownMenuItem
    final uniqueList = availableIngredients.map((e) => e.name).toSet().toList();
    final items = uniqueList.map((name) {
      return DropdownMenuItem<String>(
        value: name,
        child: Text(name),
      );
    }).toList();

    // Agregamos la opción 'Otro'
    items.add(const DropdownMenuItem<String>(
      value: 'Otro',
      child: Text('Otro'),
    ));

    return items;
  }

  void _showQuantityDialog(BuildContext context, Ingredient ingredient) {
    final TextEditingController quantityController = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  'Cantidad',
                  style: TextStyle(
                    color: Color(0xFF129575),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ], // TERCERA RESTRICCIÓN
                    decoration:
                        const InputDecoration(hintText: "Ingrese la cantidad"),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: defaultUnits.contains(ingredient.unit)
                        ? ingredient.unit
                        : null,
                    items: defaultUnits.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == 'Otro') {
                        _showCustomUnitDialog(context, ingredient);
                      } else {
                        setState(() {
                          ingredient.unit = value!;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Seleccione una unidad",
                    ),
                  )
                ],
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
                      onPressed: quantityController.text.isNotEmpty &&
                              ingredient.unit.isNotEmpty
                          ? () {
                              Navigator.pop(context, quantityController.text);
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
    ).then((result) {
      if (result != null && result.isNotEmpty) {
        ingredient.quantity = result;
        (context as Element).markNeedsBuild();
      }
    });
  }

  void _showCustomUnitDialog(BuildContext context, Ingredient ingredient) {
    final TextEditingController customUnitController = TextEditingController();
    showDialog<String>(
      context: context,
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
