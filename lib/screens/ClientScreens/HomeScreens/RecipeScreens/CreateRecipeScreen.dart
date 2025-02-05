import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Default lists for ingredients and units
const List<String> defaultIngredients = ['Otro', 'Tomate', 'Cebolla', 'Ajo', 'Pimienta', 'Sal', 'Azúcar', 'Aceite', 'Vinagre', 'Leche', 'Huevos', 'Harina', 'Arroz', 'Pasta', 'Carne', 'Pollo', 'Pescado', 'Mariscos', 'Verduras', 'Frutas', 'Queso', 'Yogurt', 'Mantequilla', 'Pan', 'Cereal', 'Galletas', 'Chocolate', 'Café', 'Té', 'Agua', 'Vino', 'Cerveza', 'Ron', 'Whisky', 'Vodka', 'Ginebra', 'Brandy', 'Coñac', 'Licor'];
const List<String> defaultUnits = ['Otro', 'Gramos', 'Mililitros', 'Cucharadas', 'Tazas'];

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  int selectedIndex = 0;
  List<Ingredient> ingredients = [
    Ingredient(name: "", quantity: "", unit: ""),
    Ingredient(name: "", quantity: "", unit: ""),
    Ingredient(name: "", quantity: "", unit: ""),
  ];
  List<String> steps = ["Describa este paso por favor.", "Describa este paso por favor.", "Describa este paso por favor."];
  String estimatedTime = "Tiempo estimado ";
  String estimatedPortions = "Porciones estimadas ";
  File? _image;
  String recipeTitle = "Escriba el nombre de su Receta aquí por favor ";

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                          )
                        : null,
                  ),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white, size: 50),
                      onPressed: _pickImage,
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
                          final TextEditingController timeController = TextEditingController();
                          final result = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
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
                                  decoration: const InputDecoration(hintText: "Ingrese el tiempo en minutos"),
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
                                          Navigator.pop(context, timeController.text);
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
                            const Icon(Icons.edit, color: Colors.white, size: 16),
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
                final TextEditingController titleController = TextEditingController();
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
                        decoration: const InputDecoration(hintText: "Ingrese el título de la receta"),
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
                        final TextEditingController portionsController = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
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
                                decoration: const InputDecoration(hintText: "Ingrese el número de porciones"),
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
                                        Navigator.pop(context, portionsController.text);
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
                              ingredients.add(Ingredient(name: "", quantity: "", unit: ""));
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
  final int index;
  final VoidCallback onDelete;

  const IngredientCard({required this.ingredient, required this.index, required this.onDelete});

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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
              ],
            ),
            Row(
              children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                value: ingredient.name.isEmpty ? null : ingredient.name,
                items: defaultIngredients.map((String ingredient) {
                  return DropdownMenuItem<String>(
                  value: ingredient,
                  child: Container(
                    child: Text(ingredient),
                  ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == 'Otro') {
                  _showCustomIngredientDialog(context, ingredient);
                  } else {
                  ingredient.name = value!;
                  }
                },
                decoration: const InputDecoration(hintText: "Seleccione un ingrediente"),
                dropdownColor: Colors.white, // Set the dropdown background color to white
                ),
              ),
              const SizedBox(width: 16), // Increase the width of the SizedBox for more separation
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
                    "Cantidad ",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${ingredient.quantity} ${ingredient.unit}",
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomIngredientDialog(BuildContext context, Ingredient ingredient) {
    final TextEditingController customIngredientController = TextEditingController();
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
            decoration: const InputDecoration(hintText: "Ingrese el nombre del ingrediente"),
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

  void _showQuantityDialog(BuildContext context, Ingredient ingredient) {
    final TextEditingController quantityController = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
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
                decoration: const InputDecoration(hintText: "Ingrese la cantidad"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: ingredient.unit.isEmpty ? null : ingredient.unit,
                items: defaultUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Container(
                      color: Colors.white,
                      child: Text(unit),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == 'Otro') {
                    _showCustomUnitDialog(context, ingredient);
                  } else {
                    ingredient.unit = value!;
                  }
                },
                decoration: const InputDecoration(hintText: "Seleccione una unidad"),
                dropdownColor: Colors.white,
              ),
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
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result.isNotEmpty) {
        ingredient.quantity = result;
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
            decoration: const InputDecoration(hintText: "Ingrese la unidad de medida"),
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

  const StepCard({required this.step, required this.stepNumber, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final TextEditingController stepController = TextEditingController(text: step);
        final result = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
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
                decoration: const InputDecoration(hintText: "Describa este paso por favor"),
                onTap: () {
                  if (stepController.text == "Describa este paso por favor.") {
                    stepController.clear();
                  }
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
                      onPressed: () {
                        Navigator.pop(context, stepController.text);
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
          (context as Element).markNeedsBuild();
          (context.findAncestorStateOfType<_CreateRecipeState>()!).setState(() {
            context.findAncestorStateOfType<_CreateRecipeState>()!.steps[stepNumber - 1] = result;
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
                  Text(
                    "Paso $stepNumber",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
                style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 51, 50, 50)),
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