import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_kitchenmate/controllers/Reports/reports_controller.dart';
import 'package:mobile_kitchenmate/models/Reports/report_request.dart';
import 'package:mobile_kitchenmate/utils/image_utils.dart';
import 'package:mobile_kitchenmate/views/ClientScreens/RecipeScreens/CreateRecipeScreen.dart';

import '/controllers/Recipes/comments.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/models/Recipes/comments_request.dart';
import '/models/Recipes/comments_response.dart';
import '/models/Profiles/profile_response.dart';

import '/controllers/authentication/auth_controller.dart';

import 'package:mobile_kitchenmate/models/Reports/report_request.dart';
import 'package:mobile_kitchenmate/controllers/Reports/reports_controller.dart';

import 'dart:developer';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  /* ---------- configuración ---------- */
  final String recipeBaseUrl = dotenv.env['RECIPE_URL'] ?? '';
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final String _authBase = dotenv.env['AUTH_URL'] ?? '';
  final String _reportBase = dotenv.env['REPORTS_URL'] ?? '';
  final Stopwatch _stopwatch = Stopwatch();

  late final CommentController _commentCtl;
  late final ProfileController _profileCtl;
  late AuthController _authController;
  late ReportsController _reportController;

  /* ---------- ids & estado ---------- */
  late int recipeId;
  bool _loaded = false;
  double _rating = 0;

  String keycloakUserId = '';

  late Future<List<CommentResponse>> _commentsF;
  final _newComment = TextEditingController();
  final _profileCache = <String, ProfileResponse>{};

  /* ---------- ciclo de vida ---------- */

  @override
  void initState() {
    super.initState();
    _commentCtl = CommentController(baseUrl: recipeBaseUrl);
    _profileCtl = ProfileController(baseUrl: profileBaseUrl);
    _authController = AuthController(baseUrl: _authBase);
    _reportController = ReportsController(baseUrl: _reportBase);

    _stopwatch.start();

    _authController.getKeycloakUserId().then((id) {
      keycloakUserId = id;
    });
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
    if (_profileCache.containsKey(id)) {
      return _profileCache[id]!;
    }

    final profile = await _profileCtl.getProfile(id);
    _profileCache[id] = profile;
    return profile;
  }

  Future<void> _send() async {
    final txt = _newComment.text.trim();
    if (txt.isEmpty || _rating == 0) return;

    if (keycloakUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Espera un momento... aún cargando usuario')),
      );
      return;
    }

    final req = CommentRequest(
      authorUserId: keycloakUserId,
      text: txt,
      rating: _rating,
    );

    try {
      await _commentCtl.addComment(recipeId, req);
      _newComment.clear();
      setState(() {
        _rating = 0;
        _commentsF = _commentCtl.fetchComments(recipeId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo publicar: $e')),
      );
    }
  }

  String _fixEncoding(String text) {
    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }

  Future<void> _showReportDialog(BuildContext context, String commentId) async {
    final TextEditingController reportController = TextEditingController();
    bool isButtonEnabled = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Estás a punto de reportar este comentario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Por favor, escribe el motivo del reporte:'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reportController,
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        isButtonEnabled = value.trim().isNotEmpty;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Escribe los detalles aquí...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
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
                  onPressed: isButtonEnabled
                      ? () async {
                          await _submitReport(reportController.text, commentId);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF129575),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String description, String commentId) async {
    try {
      // Obtén el profileId del usuario logueado
      final profile = await _profileCtl.getProfile(keycloakUserId);

      final reportRequest = ReportRequest(
        reporterUserId: profile.profileId.toString(),
        resourceType: "Comentario",
        description: description,
      );

      await _reportController.createReport(reportRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar reporte: $e')),
      );
    }
  }

  /* ---------- UI ---------- */

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        print('CommentsScreen: ${_stopwatch.elapsedMilliseconds} ms');
      }
    });
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
                      builder: (_, p) {
                        if (!p.hasData) {
                          return const SizedBox(height: 48);
                        }
                        final profile = p.data;
                        final imageUrl = getFullImageUrl(
                          profile?.profilePhoto,
                          placeholder: 'assets/chefs/default_chef.jpg',
                        );
                        final imageProvider = (imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : AssetImage(imageUrl)) as ImageProvider<Object>;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: imageProvider,
                          ),
                          title:
                              Text(_fixEncoding(profile?.firstName ?? 'Chef')),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (c.rating != null)
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
                              Text(_fixEncoding(c.text)),
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
                                reporterUserId: keycloakUserId,
                                resourceType: 'comment',
                                description:
                                    'Comentario reportado automáticamente.',
                              );

                              try {
                                final reportController =
                                    ReportsController(baseUrl: _reportBase);
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
                        );
                      },
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
