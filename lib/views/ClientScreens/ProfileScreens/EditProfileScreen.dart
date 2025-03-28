import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/models/profile_model.dart';
import '/controllers/profile_controller.dart';
import '/controllers/nutrition_controller.dart';
import '/controllers/ingredient_controller.dart';
import '/models/nutrition_model.dart';
import '/providers/user_provider.dart';

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({super.key});

  @override
  _EditprofileState createState() => _EditprofileState();
}

class _EditprofileState extends State<EditprofileScreen> {
  late Profile profile;
  late NutritionController nutritionController;
  bool isProfileInfoSelected = true;
  File? _profileImage;
  String _searchQuery = '';
  int _ingredientsToShow = 10;

  @override
  void initState() {
    super.initState();
    final profileController = ProfileController();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      profile = profileController.recommendedProfiles.firstWhere((p) => p.email == user.email);
    } else {
      profile = profileController.recommendedProfiles.firstWhere((p) => p.keycloak_user_id == 11);
    }
    final ingredientController = IngredientController();
    final sortedIngredients = ingredientController.getAllIngredientNames()..sort();
    final nutritionModel = NutritionModel(sortedIngredients);
    nutritionController = NutritionController(model: nutritionModel);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutritionQuestions = nutritionController.getQuestions();
    final currentQuestion = nutritionQuestions.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        backgroundColor: const Color(0xFF129575),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isProfileInfoSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isProfileInfoSelected ? const Color(0xFF129575) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF129575)),
                      ),
                      child: Text(
                        'Información de Perfil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isProfileInfoSelected ? Colors.white : const Color(0xFF129575),
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
                        isProfileInfoSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isProfileInfoSelected ? Colors.white : const Color(0xFF129575),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF129575)),
                      ),
                      child: Text(
                        'Información Dietética',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isProfileInfoSelected ? const Color(0xFF129575) : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isProfileInfoSelected) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : AssetImage(profile.imageUrl) as ImageProvider,
                          ),
                          const SizedBox(width: 35),
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.add, color: Colors.grey[700], size: 40),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Editar Foto de Perfil',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      buildInfoContainer('Nombre de Perfil', profile.name),
                      buildInfoContainer('Descripción', profile.description, isDescription: true),
                      buildInfoContainer('Correo Electrónico', profile.email),
                      buildInfoContainer('Contraseña', profile.password),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF129575),
                              ),
                              child: const Text(
                                'Guardar Cambios',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 181, 108, 106),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                        Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Alimentos Restringidos",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
                        ),
                        ),
                      const SizedBox(height: 15),
                      _buildSearchBar(),
                      const SizedBox(height: 10),
                      _buildCheckboxList(currentQuestion),
                      _buildLoadMoreButton(currentQuestion),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF129575),
                              ),
                              child: const Text(
                                'Guardar Cambios',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 193, 128, 124),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 4,
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

  Widget buildInfoContainer(String title, String info, {bool isDescription = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), // title
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.edit, size: 20, color: Color.fromARGB(255, 113, 107, 114)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  info,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: isDescription ? 1 : null,
                  overflow: isDescription ? TextOverflow.ellipsis : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _ingredientsToShow = 10;
        });
      },
      decoration: InputDecoration(
        labelText: 'Buscar alimentos',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildCheckboxList(NutritionQuestion question) {
    final filteredOptions = question.options
        .where((option) => option.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
        .take(_ingredientsToShow)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filteredOptions.map((option) {
          final isSelected = question.selected.contains(option);
          return CheckboxListTile(
            title: Text(option),
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  question.selected.add(option);
                } else {
                  question.selected.remove(option);
                }
                nutritionController.updateSelectedOptions(question, question.selected);
              });
            },
            activeColor: const Color(0xFF129575),
            checkColor: Colors.white,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoadMoreButton(NutritionQuestion question) {
    final filteredOptions = question.options
        .where((option) => option.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
    if (_ingredientsToShow >= filteredOptions.length) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: () {
          setState(() {
            _ingredientsToShow += 10;
          });
        },
        child: const Text(
          'Cargar más',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}