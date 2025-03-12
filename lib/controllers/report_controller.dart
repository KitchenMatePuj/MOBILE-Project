import '/models/report_model.dart';

class ReportController {
  final List<Report> reports = [
    Report(
      reportId: 1,
      reportingUserId: 11,
      description: "Es un perfil que solo sube recetas Fake.",
      creationDate: DateTime.now(),
      status: "Resuelto",
      reportType: "Perfil",
      reportedRecipeId: 0,
      reportedProfileId: 11,
      ReportedCommentId: 0,
    ),
    Report(
      reportId: 2,
      reportingUserId: 11,
      description: "Fue muy grosero conmigo en un comentario.",
      creationDate: DateTime(2025, 3, 10),
      status: "Pendiente",
      reportType: "Comentario",
      reportedRecipeId: 0,
      reportedProfileId: 0,
      ReportedCommentId: 20,
    ),
    Report(
      reportId: 3,
      reportingUserId: 11,
      description: "La receta no tiene sentido.",
      creationDate: DateTime(2024, 3, 10),
      status: "Eliminado",
      reportType: "Comentario",
      reportedRecipeId: 3,
      reportedProfileId: 0,
      ReportedCommentId: 0,
    ),
  ];

  void addReport(Report report) {
    reports.add(report);
  }

  List<Report> getReportsByUserId(int userId) {
    return reports.where((report) => report.reportingUserId == userId).toList();
  }

  Report getReportById(int reportId) {
    return reports.firstWhere((report) => report.reportId == reportId);
  }
}