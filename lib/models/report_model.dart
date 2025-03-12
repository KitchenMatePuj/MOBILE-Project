class Report {
  final int reportId;
  final int reportingUserId;
  final String description;
  final DateTime creationDate;
  final String status;
  final String reportType;
  final int reportedRecipeId;
  final int reportedProfileId;
  final int ReportedCommentId;

  Report({
    required this.reportId,
    required this.reportingUserId,
    required this.description,
    required this.creationDate,
    required this.status,
    required this.reportType,
    required this.reportedRecipeId,
    required this.reportedProfileId,
    required this.ReportedCommentId,
  });
}