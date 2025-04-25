import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/controllers/Profiles/follow_controller.dart';
import '/controllers/Recipes/recipes.dart';
import '/models/Profiles/profile_response.dart';
import '/models/Profiles/follow_response.dart';
import '/models/Profiles/follow_request.dart';
import '/models/Recipes/recipes_response.dart';

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';

class PublicProfileScreen extends StatefulWidget {
  final int profileId;

  const PublicProfileScreen({super.key, required this.profileId});

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final _authBase = dotenv.env['AUTH_URL'] ?? '';
  late ProfileController _profileController;
  late FollowController _followController;
  late RecipeController _recipeController;
  late Future<ProfileResponse> _profileFuture;
  late Future<List<FollowResponse>> _followersFuture;
  late Future<List<FollowResponse>> _followingFuture;
  late Future<List<RecipeResponse>> _recipesFuture;
  late AuthController _authController;
  bool _isFollowing = false;
  String keycloakUserId = '';

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _followController = FollowController(baseUrl: profileBaseUrl);
    _recipeController = RecipeController(baseUrl: recipeBaseUrl);
    _authController = AuthController(baseUrl: _authBase);

    _authController.getKeycloakUserId().then((id) {
      keycloakUserId = id;
    });

    _profileFuture =
        _profileController.getProfilebyid(widget.profileId.toString());
    _followersFuture = _followController.listFollowers(widget.profileId);
    _followingFuture = _followController.listFollowed(widget.profileId);
    _recipesFuture = _loadRecipes();
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    final followed = await _followController
        .listFollowed(2); // profile_id del usuario logueado
    setState(() {
      _isFollowing =
          followed.any((follow) => follow.followedId == widget.profileId);
    });
  }

  Future<List<RecipeResponse>> _loadRecipes() async {
    ProfileResponse profile = await _profileFuture;
    return _recipeController.getRecipesByUser(profile.keycloakUserId);
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing) {
      await _followController.deleteFollow(
          int.parse(keycloakUserId), widget.profileId); // profile_id del usuario logueado
    } else {
      await _followController.createFollow(
          FollowRequest(followerId: int.parse(keycloakUserId), followedId: widget.profileId));
    }
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Público'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<ProfileResponse>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text('Error: ${profileSnapshot.error}'));
          } else if (!profileSnapshot.hasData) {
            return const Center(child: Text('No se encontró el perfil'));
          }

          final profile = profileSnapshot.data!;
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
                          return const CircularProgressIndicator();
                        } else if (followersSnapshot.hasError) {
                          return Text('Error: ${followersSnapshot.error}');
                        }
                        final followers = followersSnapshot.data ?? [];
                        return FutureBuilder<List<FollowResponse>>(
                          future: _followingFuture,
                          builder: (context, followingSnapshot) {
                            if (followingSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (followingSnapshot.hasError) {
                              return Text('Error: ${followingSnapshot.error}');
                            }
                            final following = followingSnapshot.data ?? [];
                            return ProfileStats(
                              profile: profile,
                              followersCount: followers.length,
                              followingCount: following.length,
                              recipesFuture: _recipesFuture,
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
                            'Biografía del usuario'), // Biografía quemada
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF129575),
                            ),
                            child: Text(
                              _isFollowing ? 'Dejar de Seguir' : 'Seguir',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Lógica de reporte
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 181, 108, 106),
                            ),
                            child: const Text(
                              'Reportar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<RecipeResponse>>(
                  future: _recipesFuture,
                  builder: (context, recipesSnapshot) {
                    if (recipesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (recipesSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${recipesSnapshot.error}'));
                    } else if (!recipesSnapshot.hasData) {
                      return const Center(
                          child: Text('No se encontraron recetas'));
                    }

                    final recipes = recipesSnapshot.data!;
                    return PublishedRecipesGrid(
                        recipes: recipes, profile: profile);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 83, 83, 83),
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
      ),
    );
  }
}

class ProfileStats extends StatelessWidget {
  final ProfileResponse profile;
  final int followersCount;
  final int followingCount;
  final Future<List<RecipeResponse>> recipesFuture;

  const ProfileStats({
    required this.profile,
    required this.followersCount,
    required this.followingCount,
    required this.recipesFuture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecipeResponse>>(
      future: recipesFuture,
      builder: (context, recipesSnapshot) {
        int recipesCount = 0;
        if (recipesSnapshot.connectionState == ConnectionState.done &&
            recipesSnapshot.hasData) {
          recipesCount = recipesSnapshot.data!.length;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: profile.profilePhoto != null
                  ? NetworkImage(profile.profilePhoto!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/followers_and_following',
                  arguments: {
                    'profile_id': profile.profileId,
                    'type': 'recipes'
                  },
                );
              },
              child: _buildStatItem('Recetas', recipesCount.toString()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/followers_and_following',
                  arguments: {
                    'profile_id': profile.profileId,
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
                    'profile_id': profile.profileId,
                    'type': 'following'
                  },
                );
              },
              child: _buildStatItem('Siguiendo', followingCount.toString()),
            ),
          ],
        );
      },
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

class PublishedRecipesGrid extends StatelessWidget {
  final List<RecipeResponse> recipes;
  final ProfileResponse profile;

  const PublishedRecipesGrid(
      {required this.recipes, required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/recipe',
              arguments: {'recipeId': recipe.recipeId},
            );
          },
          child: RecipeCard(
            title: recipe.title,
            chef:
                'Chef: ${profile.firstName} ${profile.lastName}', // Placeholder for chef name
            duration: recipe.cookingTime.toString(),
            imageUrl: 'assets/recipes/recipe1.jpg', // Default image
            rating: recipe.ratingAvg.toInt(),
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;
  final int? rating;

  const RecipeCard({
    Key? key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  chef,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$duration mins',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (rating ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
