import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/profile_model.dart';
import '/controllers/profile_controller.dart';
import '/controllers/nutrition_controller.dart';
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
    final nutritionModel = NutritionModel();
    nutritionController = NutritionController(model: nutritionModel);
  }

  @override
  Widget build(BuildContext context) {
    final nutritionQuestions = nutritionController.getQuestions();

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
                            backgroundImage: AssetImage(profile.imageUrl),
                          ),
                          const SizedBox(width: 35),
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.add, color: Colors.grey[700], size: 40),
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
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    ...nutritionQuestions.map((q) => _buildMultiSelect(q)).toList(),
                    const SizedBox(height: 1),
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

  Widget _buildMultiSelect(NutritionQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0, // Add spacing between options
          children: question.options.map((option) {
            final isSelected = question.selected.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    question.selected.add(option);
                  } else {
                    question.selected.remove(option);
                  }
                  nutritionController.updateSelectedOptions(question, question.selected);
                });
              },
              selectedColor: const Color(0xFF129575),
              backgroundColor: isSelected ? const Color(0xFF129575) : Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}