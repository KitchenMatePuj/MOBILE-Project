import 'package:flutter/material.dart';

class CreateRecipe extends StatelessWidget {
  const CreateRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creación de Receta'),
        foregroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        backgroundColor: const Color(0xFF129575),
      ),
      body: const Center(
        child: Text('Pendiente Creación de Publicación de Receta'),
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
}
