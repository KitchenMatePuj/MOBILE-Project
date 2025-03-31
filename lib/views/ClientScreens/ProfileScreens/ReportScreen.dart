import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/controllers/profile_controller.dart';
import '/controllers/report_controller.dart';
import '/models/profile_model.dart';
import '/models/report_model.dart';
import '/providers/user_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<int> _expandedReports = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final profileController = ProfileController();
    final reportController = ReportController();

    final profile = user != null
        ? profileController.recommendedProfiles.firstWhere((p) => p.email == user.email)
        : profileController.recommendedProfiles.firstWhere((profile) => profile.keycloak_user_id == 11);

    final userReports = reportController.getReportsByUserId(profile.keycloak_user_id.toString());

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
            userReports.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        'Sin Reportes Realizados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                  child: ListView.builder(
                  itemCount: userReports.length,
                  itemBuilder: (context, index) {
                  final report = userReports[index];
                  final formattedDate = DateFormat('dd-MM-yyyy').format(report.creationDate);
                  final isExpanded = _expandedReports.contains(report.reportId);
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      '${report.status}',
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: [
                      TextSpan(
                        text: '${report.description}',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      ],
                      ),
                      ),
                      RichText(
                      text: TextSpan(
                      text: 'Tipo de Reporte: ',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: [
                      TextSpan(
                        text: report.reportedRecipeId != 0
                        ? 'Receta'
                        : report.reportedProfileId != 0
                          ? 'Perfil'
                          : 'Comentario',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      ],
                      ),
                      ),
                      RichText(
                      text: TextSpan(
                      text: 'ID de Reporte: ',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      children: [
                      TextSpan(
                        text: '${report.reportId}',
                        style: const TextStyle(fontWeight: FontWeight.normal),
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