import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/controllers/Profiles/follow_controller.dart';
import '/models/Profiles/profile_response.dart';
import '/models/Profiles/follow_response.dart'; // Ensure FollowResponse is imported
import '/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedIndex = 0;
  late Future<ProfileResponse> _profileFuture;
  late Future<List<FollowResponse>> _followersFuture;
  late Future<List<FollowResponse>> _followingFuture;
  late ProfileController _profileController;
  late FollowController _followController;
  String keycloakUserId =
      '12'; // Reemplaza '12' con el keycloak_user_id correcto

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();
    _followController = FollowController();
    _profileFuture = _profileController.getProfile(
        keycloakUserId); // Reemplaza '12' con el keycloak_user_id correcto
    _followersFuture = _followController
        .listFollowers(2); // Reemplaza '12' con el profileId correcto
    _followingFuture = _followController
        .listFollowed(2); // Reemplaza '12' con el profileId correcto
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF129575),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: Colors.white,
            onSelected: (String value) {
              switch (value) {
                case 'Editar Perfil':
                  Navigator.pushNamed(context, '/edit_profile');
                  break;
                case 'Reportes':
                  Navigator.pushNamed(context, '/reports');
                  break;
                case 'Cerrar sesión':
                  Navigator.pushNamed(context, '/');
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Editar Perfil',
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Editar Perfil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Reportes',
                  child: Row(
                    children: const [
                      Icon(Icons.report, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Reportes'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Cerrar sesión',
                  child: Center(
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<ProfileResponse>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return Text('No data found');
          }

          final profile = snapshot.data!;
          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    FutureBuilder<List<FollowResponse>>(
                      future: _followersFuture,
                      builder: (context, followersSnapshot) {
                        if (followersSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (followersSnapshot.hasError) {
                          return Text('Error: ${followersSnapshot.error}');
                        }

                        final followers = followersSnapshot.data ?? [];
                        return FutureBuilder<List<FollowResponse>>(
                          future: _followingFuture,
                          builder: (context, followingSnapshot) {
                            if (followingSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (followingSnapshot.hasError) {
                              return Text('Error: ${followingSnapshot.error}');
                            }

                            final following = followingSnapshot.data ?? [];
                            return ProfileStats(
                              profile: profile,
                              followersCount: followers.length,
                              followingCount: following.length,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        profile.firstName ?? 'Nombre no disponible',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProfileBio(
                        description:
                            'Aquí va una descripción genérica del usuario.'), // Descripción quemada
                    const SizedBox(height: 16),
                    ProfileTabs(
                      selectedIndex: selectedIndex,
                      onTabSelected: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ), // Pestañas para publicaciones y guardados
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Center(
                    child: Text(
                        'Aquí irá el contenido de las recetas guardadas y publicadas.'),
                  ),
                ),
                // child: SavedRecipesGrid(
                //   selectedIndex: selectedIndex,
                //   profile: profile,
                // ), // Recetas guardadas
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF129575),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        currentIndex: 4,
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
}

class ProfileStats extends StatelessWidget {
  final ProfileResponse profile;
  final int followersCount;
  final int followingCount;

  const ProfileStats({
    required this.profile,
    required this.followersCount,
    required this.followingCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage(profile.profilePhoto ??
              'default_image_url'), // Utilizamos NetworkImage para imágenes desde una URL
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/followers_and_following',
              arguments: {
                'profile_id': profile.profileId, // Asegúrate de que profileId es un int válido
                'type': 'recipes'
              },
            );
          },
          child: _buildStatItem('Recetas', '0'), // Placeholder for the actual recipe count
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/followers_and_following',
              arguments: {
                'profile_id': profile.profileId, // Asegúrate de que profileId es un int válido
                'type': 'followers'
              },
            );
          },
          child: _buildStatItem('Seguidores', followersCount.toString()),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/followers_and_following',
              arguments: {
                'profile_id': profile.profileId, // Asegúrate de que profileId es un int válido
                'type': 'following'
              },
            );
          },
          child: _buildStatItem('Siguiendo', followingCount.toString()),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ProfileBio extends StatelessWidget {
  final String description;

  const ProfileBio({required this.description, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class ProfileTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ProfileTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTab('Recetas', 0),
        _buildTab('Guardados', 1),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
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

// class SavedRecipesGrid extends StatelessWidget {
//   final int selectedIndex;
//   final Profile profile;

//   const SavedRecipesGrid({
//     required this.selectedIndex,
//     required this.profile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final recipeController = RecipeController();
//     final savedRecipes = profile.saved_recipes
//         .map((recipeId) =>
//             recipeController.allRecipes.firstWhere((recipe) => recipe.recipeId == '$recipeId'))
//         .toList();
//     final publishedRecipes = profile.published_recipes
//         .map((recipeId) =>
//             recipeController.allRecipes.firstWhere((recipe) => recipe.recipeId == '$recipeId'))
//         .toList();

//     final recipesToShow = selectedIndex == 0 ? publishedRecipes : savedRecipes;

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),
//       itemCount: recipesToShow.length,
//       itemBuilder: (context, index) {
//         final recipe = recipesToShow[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.pushNamed(
//               context,
//               '/recipe',
//               arguments: {'recipeId': recipe.recipeId},
//             );
//           },
//           child: RecipeCard(
//             title: recipe.title,
//             chef: recipe.chef,
//             duration: recipe.duration,
//             imageUrl: recipe.imageUrl,
//             rating: recipe.rating,
//           ),
//         );
//       },
//     );
//   }
// }

// class RecipeCard extends StatelessWidget {
//   final String title;
//   final String chef;
//   final String duration;
//   final String imageUrl;
//   final int? rating;

//   const RecipeCard({
//     Key? key,
//     required this.title,
//     required this.chef,
//     required this.duration,
//     required this.imageUrl,
//     this.rating,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//             child: Image.asset(
//               imageUrl,
//               height: 120,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 12,
//                       backgroundImage: AssetImage('assets/chefs/$chef.jpg'),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       chef,
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '$duration mins',
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     Row(
//                       children: List.generate(5, (index) {
//                         return Icon(
//                           index < (rating ?? 0) ? Icons.star : Icons.star_border,
//                           color: Colors.amber,
//                           size: 12,
//                         );
//                       }),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
