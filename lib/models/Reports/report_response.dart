// lib/models/Reports/report_response.dart

class ReportResponse {
  final int reportId;
  final String reporterUserId;
  final String resourceType;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportResponse({
    required this.reportId,
    required this.reporterUserId,
    required this.resourceType,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reportId: json['report_id'],
      reporterUserId: json['reporter_user_id'],
      resourceType: json['resource_type'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'reporter_user_id': reporterUserId,
      'resource_type': resourceType,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
