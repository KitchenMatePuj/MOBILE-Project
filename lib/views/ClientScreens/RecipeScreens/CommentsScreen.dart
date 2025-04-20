import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Reports/reports_controller.dart';
import 'package:mobile_kitchenmate/models/Reports/report_request.dart';
import 'package:mobile_kitchenmate/views/ClientScreens/RecipeScreens/CreateRecipeScreen.dart';

import '/controllers/Recipes/comments.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/models/Recipes/comments_request.dart';
import '/models/Recipes/comments_response.dart';
import '/models/Profiles/profile_response.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  /* ---------- configuración ---------- */
  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';

  late final CommentController _commentCtl;
  late final ProfileController _profileCtl;

  /* ---------- ids & estado ---------- */
  late int recipeId; // llega por ruta
  bool _loaded = false; // evita set‑state dobles
  double _rating = 0; // ⭐ de 1‑5

  late Future<List<CommentResponse>> _commentsF;
  final _newComment = TextEditingController();
  final _profileCache = <String, ProfileResponse>{};

  /* ---------- ciclo de vida ---------- */

  @override
  void initState() {
    super.initState();
    _commentCtl = CommentController(baseUrl: recipeBaseUrl);
    _profileCtl = ProfileController(baseUrl: profileBaseUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['recipeId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se recibió recipeId')),
      );
      Navigator.pop(context);
      return;
    }

    recipeId = args['recipeId'] as int;
    _commentsF = _commentCtl.fetchComments(recipeId);
    _loaded = true;
  }

  /* ---------- helpers ---------- */

  Future<ProfileResponse> _author(String id) async {
    // Si ya está en cache, lo devolvemos
    if (_profileCache.containsKey(id)) {
      return _profileCache[id]!;
    }

    // Si no, lo pedimos al backend y lo guardamos
    final profile = await _profileCtl.getProfile(id);
    _profileCache[id] = profile;
    return profile;
  }

  Future<void> _send() async {
    final txt = _newComment.text.trim();
    if (txt.isEmpty || _rating == 0) return;

    final req = CommentRequest(
      authorUserId: keycloakUserId, // ← pon aquí el userId real
      text: txt,
      rating: _rating,
    );

    try {
      await _commentCtl.addComment(recipeId, req);
      _newComment.clear();
      setState(() {
        _rating = 0;
        _commentsF = _commentCtl.fetchComments(recipeId); // refresca
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo publicar: $e')),
      );
    }
  }

  /* ---------- UI ---------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        leading: BackButton(),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /* ----------- lista de comentarios ----------- */
          Expanded(
            child: FutureBuilder<List<CommentResponse>>(
              future: _commentsF,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final comments = snap.data!;
                if (comments.isEmpty) {
                  return const Center(
                      child: Text('¡Sé el primero en comentar!'));
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return FutureBuilder<ProfileResponse>(
                      future: _author(c.authorUserId),
                      builder: (_, p) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (p.data?.profilePhoto != null)
                              ? NetworkImage(p.data!.profilePhoto!)
                              : const AssetImage(
                                      'assets/chefs/default_chef.jpg')
                                  as ImageProvider,
                        ),
                        title: Text(p.data?.firstName ?? 'Chef'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.rating !=
                                null) // solo si el usuario dejó calificación
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < c.rating!.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(c.text),
                            Text(
                              '${c.createdAt.toLocal()}'.split(' ')[0],
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.report,
                              color: Color.fromARGB(255, 181, 108, 106)),
                          onPressed: () async {
                            final reportRequest = ReportRequest(
                              reporterUserId:
                                  'user1234', // ← este es fijo por ahora
                              resourceType: 'comment',
                              description:
                                  'Comentario reportado automáticamente.',
                            );

                            try {
                              final reportController = ReportsController();
                              await reportController
                                  .createReport(reportRequest);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Comentario reportado correctamente.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error al reportar el comentario: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /* ----------- caja inferior ----------- */
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ Estrellas centradas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    return IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        idx <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => _rating = idx.toDouble()),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Campo de texto + botón enviar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newComment,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Comparte tu opinión',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF129575)),
                      onPressed: _send,
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
