import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/controllers/Profiles/profile_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/controllers/Reports/reports_controller.dart';
import '/models/Profiles/profile_response.dart';
import '/models/Reports/report_response.dart';
import '/providers/user_provider.dart';
import 'dart:developer';
import '/controllers/authentication/auth_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final String _authBase = dotenv.env['AUTH_URL'] ?? '';
  final String _reportBase = dotenv.env['REPORTS_URL'] ?? '';
  final String _profileBase = dotenv.env['PROFILE_URL'] ?? '';
  final List<int> _expandedReports = [];
  final Stopwatch _stopwatch = Stopwatch();
  late ReportsController _reportsController;
  late AuthController _authController;
  late ProfileController _profileController;
  late Future<List<ReportResponse>> _reportsFuture;

  String profileId = '';

  @override
  void initState() {
    super.initState();
    _authController = AuthController(baseUrl: _authBase);
    _profileController = ProfileController(baseUrl: _profileBase);
    _reportsController = ReportsController(baseUrl: _reportBase);

    _stopwatch.start();

    // Inicializar _reportsFuture con un Future vacío para evitar errores.
    _reportsFuture = Future.value([]);
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final keycloakUserId = await _authController.getKeycloakUserId();
      final profile = await _profileController.getProfile(keycloakUserId);
      setState(() {
        profileId = profile.profileId.toString();
        _reportsFuture = _fetchUserReports();
      });
    } catch (e) {
      setState(() {
        _reportsFuture = Future.error('Error al obtener datos del usuario: $e');
      });
    }
  }

  Future<List<ReportResponse>> _fetchUserReports() async {
    try {
      final allReports = await _reportsController.fetchAllReports();
      return allReports.where((report) => report.reporterUserId == profileId).toList();
    } catch (e) {
      throw Exception('Error al cargar los reportes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        print('⏱ ReportsScreen: ${_stopwatch.elapsedMilliseconds} ms');
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Reportes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ReportResponse>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar reportes: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text(
                        'Sin Reportes Realizados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                final userReports = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: userReports.length,
                    itemBuilder: (context, index) {
                      final report = userReports[index];
                      final formattedDate =
                          DateFormat('dd-MM-yyyy').format(report.createdAt);
                      final isExpanded =
                          _expandedReports.contains(report.reportId);
                      final statusColor = report.status == 'Resuelto'
                          ? const Color(0xFF129575)
                          : report.status == 'Eliminado'
                              ? Colors.red
                              : const Color.fromARGB(255, 237, 170, 69);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedReports.remove(report.reportId);
                            } else {
                              _expandedReports.add(report.reportId);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reporte ($formattedDate):',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    report.status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    text: 'Descripción de Reporte: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: report.description ??
                                            'No disponible',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Tipo de Reporte: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: report.resourceType,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'ID de Reporte: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: report.reportId.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
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
}