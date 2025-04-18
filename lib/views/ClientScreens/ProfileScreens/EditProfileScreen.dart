import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/models/Profiles/profile_request.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../controllers/Profiles/ingredient_allergy_controller.dart';
import '../../../models/Profiles/ingredientAllery_response.dart';
import '../../../models/Profiles/profile_response.dart';
import '../../../controllers/Profiles/profile_controller.dart';
import '/providers/user_provider.dart';

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({super.key});

  @override
  _EditprofileState createState() => _EditprofileState();
}

class _EditprofileState extends State<EditprofileScreen> {
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  late ProfileResponse? profile =
      ProfileResponse(profileId: 1, keycloakUserId: 'user1234', email: "email");
  bool isProfileInfoSelected = true;
  File? _profileImage;
  List<IngredientAllergyResponse> allergies = [];

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cookingTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final keycloak_user_id = 'user1234';
    _loadData(keycloak_user_id);
  }

  Future<void> _loadData(String keycloak_user_id) async {
    try {
      final fetchedProfile = await ProfileController(baseUrl: profileBaseUrl)
          .getProfile(keycloak_user_id);
      final fetchedAllergies =
          await IngredientAllergyController(baseUrl: profileBaseUrl)
              .listAllergiesByProfile(fetchedProfile.profileId);

      setState(() {
        profile = fetchedProfile;
        allergies = fetchedAllergies;

        firstNameController.text = profile?.firstName ?? '';
        lastNameController.text = profile?.lastName ?? '';
        emailController.text = profile?.email ?? '';
        phoneController.text = profile?.phone ?? '';
        cookingTimeController.text = profile?.cookingTime?.toString() ?? '';
      });
    } catch (e) {
      print('Error al cargar perfil o alergias: $e');
    }
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
            // Sección para alternar entre "Información de Perfil" y "Información Dietética"
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isProfileInfoSelected
                            ? const Color(0xFF129575)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF129575)),
                      ),
                      child: Text(
                        'Información de Perfil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isProfileInfoSelected
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
                        isProfileInfoSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isProfileInfoSelected
                            ? Colors.white
                            : const Color(0xFF129575),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF129575)),
                      ),
                      child: Text(
                        'Alergias',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isProfileInfoSelected
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

            // Contenido principal según la pestaña seleccionada
            if (isProfileInfoSelected) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Parte de la foto de perfil
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : AssetImage(
                                    // Ajusta el acceso a la foto de perfil real
                                    profile?.profilePhoto ??
                                        'assets/default_profile.png',
                                  ) as ImageProvider,
                          ),
                          const SizedBox(width: 35),
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.add,
                                color: Colors.grey[700],
                                size: 40,
                              ),
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

                      // Contenedores de información
                      TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_2),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: cookingTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tiempo de cocina (minutos)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                        ),
                      ),

                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final updatedProfile = ProfileRequest(
                                  keycloakUserId: profile?.keycloakUserId,
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  profilePhoto: profile?.profilePhoto,
                                  accountStatus: profile?.accountStatus,
                                  cookingTime:
                                      int.tryParse(cookingTimeController.text),
                                );

                                try {
                                  await ProfileController(
                                          baseUrl: profileBaseUrl)
                                      .updateProfile(
                                    profile!.keycloakUserId,
                                    updatedProfile,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Perfil actualizado exitosamente')),
                                  );
                                  Navigator.pushNamed(context, '/profile');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Error al actualizar el perfil')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF129575),
                              ),
                              child: const Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                backgroundColor:
                                    const Color.fromARGB(255, 181, 108, 106),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
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
                child: ListView.builder(
                  itemCount: allergies.length,
                  itemBuilder: (context, index) {
                    final allergy = allergies[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xFF129575), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                allergy.allergyName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF333333),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ],
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 4, // "Perfil"
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

  Widget buildInfoContainer(String title, String info,
      {bool isDescription = false}) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.edit,
                size: 20,
                color: Color.fromARGB(255, 113, 107, 114),
              ),
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
}
