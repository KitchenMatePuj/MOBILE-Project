// ignore_for_file: public_member_api_docs, sort_constructors_first
// ---------------------------------------------------------------
// ProfileScreen
// ---------------------------------------------------------------
// Pantalla que muestra el perfil del usuario junto con sus recetas
// publicadas y guardadas.  Incluye:
//   • carga perezosa de datos con FutureBuilder
//   • tabs para alternar entre recetas publicadas / guardadas
//   • cálculo del nombre del chef y las fotos – incluyendo la URL
//     absoluta a Strapi cuando el backend devuelve una ruta relativa.
//   • comentarios en línea para que el código sea más fácil de seguir.
// ---------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Controladores de negocio ----------------------------------------------------
import 'package:mobile_kitchenmate/controllers/Profiles/sumary_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/profile_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/follow_controller.dart';
import 'package:mobile_kitchenmate/controllers/Profiles/saved_recipe_controller.dart';
import 'package:mobile_kitchenmate/controllers/Recipes/recipes.dart';

// Modelos ---------------------------------------------------------------------
import 'package:mobile_kitchenmate/models/Profiles/summary_response.dart';
import 'package:mobile_kitchenmate/models/Profiles/profile_response.dart';
import 'package:mobile_kitchenmate/models/Profiles/follow_response.dart';
import 'package:mobile_kitchenmate/models/Recipes/recipes_response.dart';

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ---------------------------------------------------------------------------
  // Controladores (inyección manual – podrías migrar a Provider / Riverpod)
  // ---------------------------------------------------------------------------
  late final SumaryController _summaryCtl;
  late final FollowController _followCtl;
  late final ProfileController _profileCtl;
  late final RecipeController _recipeCtl;
  late final SavedRecipeController _savedCtl;

  // ---------------------------------------------------------------------------
  // Estado UI – tab seleccionado & futuros para la data pesada
  // ---------------------------------------------------------------------------
  int _tabIndex = 0; // 0 = publicadas, 1 = guardadas

  Future<ProfileResponse>? _profileF;
  Future<ProfileSummaryResponse>? _summaryF;
  Future<List<FollowResponse>>? _followersF;
  Future<List<FollowResponse>>? _followingF;
  late Future<List<RecipeResponse>> _publishedF;
  late Future<List<RecipeResponse>> _savedF;

  // ---------------------------------------------------------------------------
  // Constantes de configuración y usuario en sesión (mock)
  // ---------------------------------------------------------------------------
  final _profileBase = dotenv.env['PROFILE_URL'] ?? '';
  final _recipeBase = dotenv.env['RECIPE_URL'] ?? '';
  final _strapiBase = dotenv.env['STRAPI_URL'] ?? '';
  final _authBase = dotenv.env['AUTH_URL'] ?? '';
  late final AuthController _authController;

  // ⚠️ En una app real obtendrías esto del provider de autenticación.
  String _keycloakId = '';

  // ---------------------------------------------------------------------------
  // Ciclo de vida – instanciamos controladores y disparamos la carga inicial
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _summaryCtl = SumaryController(baseUrl: _profileBase);
    _followCtl = FollowController(baseUrl: _profileBase);
    _profileCtl = ProfileController(baseUrl: _profileBase);
    _recipeCtl = RecipeController(baseUrl: _recipeBase);
    _savedCtl = SavedRecipeController(baseUrl: _profileBase);
    _authController = AuthController(baseUrl: _authBase);

    _authController.getKeycloakUserId().then((id) {
      _keycloakId = id;

      _loadAll();
    });
  }

  /// Carga los distintos bloques de información en paralelo y refresca la UI
  Future<void> _loadAll() async {
    // 1️⃣ Perfil principal ------------------------------------------------------
    final profile = await _profileCtl.getProfile(_keycloakId);
    _profileF = Future.value(profile);

    // 2️⃣ Resumen (ej. alergias, tiempo de cocción preferido…) ---------------
    _summaryF = _summaryCtl.getProfileSummary(_keycloakId);

    // 3️⃣ Seguidores / seguidos ------------------------------------------------
    _followersF = _followCtl.listFollowers(profile.profileId);
    _followingF = _followCtl.listFollowed(profile.profileId);

    // 4️⃣ Recetas publicadas ---------------------------------------------------
    _publishedF = _recipeCtl.getRecipesByUser(_keycloakId);

    // 5️⃣ Recetas guardadas ----------------------------------------------------
    //    • primero obtenemos la lista de IDs guardados
    //    • luego hacemos N peticiones paralelas para traer cada receta
    _savedF = _savedCtl
        .getSavedRecipesByKeycloak(_keycloakId)
        .then((savedList) async {
      final results = await Future.wait(savedList.map((s) async {
        try {
          return await _recipeCtl.getRecipeById(s.recipeId);
        } catch (_) {
          return null; // receta fue eliminada
        }
      }));
      return results.whereType<RecipeResponse>().toList();
    });

    setState(() {}); // fuerza un rebuild cuando todos los futuros están listos
  }

  // ---------------------------------------------------------------------------
  // Helper: construye una URL absoluta para imágenes que vienen relativas
  // ---------------------------------------------------------------------------
  String _fullImageUrl(String? path, {required String placeholder}) {
    try {
      if (path == null || path.isEmpty || path == 'example') return placeholder;
      if (path.startsWith('http')) return path;
      final base = _strapiBase.endsWith('/')
          ? _strapiBase.substring(0, _strapiBase.length - 1)
          : _strapiBase;
      final fixedPath = path.startsWith('/') ? path : '/$path';
      return '$base$fixedPath';
    } catch (_) {
      return placeholder;
    }
  }

  // ---------------------------------------------------------------------------
  // UI principal --------------------------------------------------------------
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: _profileF == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<ProfileResponse>(
              future: _profileF,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final profile = snap.data!;
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23),
                      child: Column(
                        children: [
                          _buildStats(profile),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              profile.firstName ?? 'Nombre no disponible',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const ProfileBio(
                            description:
                                'Aquí va una descripción genérica del usuario.',
                          ),
                          const SizedBox(height: 16),
                          ProfileTabs(
                            selectedIndex: _tabIndex,
                            onTabSelected: (i) => setState(() => _tabIndex = i),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      // Cambiamos el future según la pestaña seleccionada
                      child: _tabIndex == 0
                          ? _recipeList(_publishedF)
                          : _recipeList(_savedF),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar con menú de opciones ----------------------------------------------
  // ---------------------------------------------------------------------------
  AppBar _buildAppBar() => AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF129575),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: Colors.white, // Fondo blanco para el menú
            onSelected: (v) {
              switch (v) {
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
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'Editar Perfil', child: Text('Editar Perfil')),
              PopupMenuItem(value: 'Reportes', child: Text('Reportes')),
              PopupMenuItem(
                value: 'Cerrar sesión',
                child:
                    Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Widget cabecera con avatar + recuento followers / following ---------------
  // ---------------------------------------------------------------------------
  Widget _buildStats(ProfileResponse profile) {
    final followersFuture = _followCtl.listFollowers(profile.profileId);
    final followingFuture = _followCtl.listFollowed(profile.profileId);
    final publishedFuture = _recipeCtl.getRecipesByUser(_keycloakId);

    return FutureBuilder(
      future: Future.wait([
        followersFuture,
        followingFuture,
        publishedFuture,
      ]),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();

        final followersList = snap.data![0] as List<FollowResponse>;
        final followingList = snap.data![1] as List<FollowResponse>;
        final publishedList = snap.data![2] as List<RecipeResponse>;

        final followers = followersList.length;
        final following = followingList.length;
        final published = publishedList.length;

        final avatar = _fullImageUrl(
          profile.profilePhoto,
          placeholder: 'assets/chefs/default_user.png',
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: avatar.startsWith('http')
                  ? NetworkImage(avatar)
                  : AssetImage(avatar) as ImageProvider,
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/followers_and_following',
                  arguments: {
                    'profile_id': profile.profileId,
                    'type': 'recipes',
                  },
                );
              },
              child: _buildStatItem('Recetas', published.toString()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/followers_and_following',
                  arguments: {
                    'profile_id': profile.profileId,
                    'type': 'followers',
                  },
                );
              },
              child: _buildStatItem('Seguidores', followers.toString()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/followers_and_following',
                  arguments: {
                    'profile_id': profile.profileId,
                    'type': 'following',
                  },
                );
              },
              child: _buildStatItem('Siguiendo', following.toString()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) => Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      );

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      );

  // ---------------------------------------------------------------------------
  // Lista (perezosa) de recetas ------------------------------------------------
  // ---------------------------------------------------------------------------
  Widget _recipeList(Future<List<RecipeResponse>> future) =>
      FutureBuilder<List<RecipeResponse>>(
        future: future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Sin recetas'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];

              // Imagen de la receta ------------------------------------------
              final img = _fullImageUrl(
                r.imageUrl,
                placeholder: 'assets/styles/recipe_placeholder.jpg',
              );

              // Traemos perfil del autor para mostrar su nombre y avatar
              return FutureBuilder<ProfileResponse>(
                future: _profileCtl.getProfile(r.keycloakUserId),
                builder: (context, chefSnap) {
                  if (!chefSnap.hasData) {
                    return const SizedBox.shrink();
                  }

                  final chefProfile = chefSnap.data!;
                  final chefName =
                      chefProfile.firstName ?? chefProfile.keycloakUserId;
                  final avatar = _fullImageUrl(
                    chefProfile.profilePhoto,
                    placeholder: 'assets/chefs/default_user.png',
                  );

                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/recipe',
                      arguments: {'recipeId': r.recipeId},
                    ),
                    child: RecipeCard(
                      title: r.title,
                      chef: chefName, // ← mostramos nombre, no ID ✅
                      duration: '${r.cookingTime}',
                      imageUrl: img,
                      avatarUrl: avatar,
                      rating: r.ratingAvg.round(),
                    ),
                  );
                },
              );
            },
          );
        },
      );

  // ---------------------------------------------------------------------------
  // Bottom navigation ---------------------------------------------------------
  // ---------------------------------------------------------------------------
  BottomNavigationBar _buildBottomBar() => BottomNavigationBar(
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
      );
}

// ---------------------------------------------------------------------------
// Widgets auxiliares ---------------------------------------------------------
// ---------------------------------------------------------------------------
class ProfileBio extends StatelessWidget {
  final String description;
  const ProfileBio({super.key, required this.description});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(description, style: const TextStyle(color: Colors.grey)),
      );
}

class ProfileTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  const ProfileTabs(
      {super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tab('Recetas', 0),
          _tab('Guardados', 1),
        ],
      );

  Widget _tab(String label, int index) => GestureDetector(
        onTap: () => onTabSelected(index),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
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

class RecipeCard extends StatelessWidget {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;
  final int? rating;
  final String avatarUrl;
  const RecipeCard({
    super.key,
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    required this.avatarUrl,
    this.rating,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
            // Imagen de cabecera ------------------------------------------------
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            // Detalles ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la receta
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  // Nombre + avatar del chef
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: avatarUrl.startsWith('http')
                            ? NetworkImage(avatarUrl)
                            : AssetImage(avatarUrl) as ImageProvider,
                      ),
                      const SizedBox(width: 8),
                      Text(chef, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Duración + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$duration mins',
                          style: const TextStyle(color: Colors.grey)),
                      Row(
                        children: List.generate(
                            5,
                            (i) => Icon(
                                  i < (rating ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 12,
                                )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
}
