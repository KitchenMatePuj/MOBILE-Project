class ReportRequest {
  final String reporterUserId;
  final String resourceType;
  final String? description;
  final String? status;

  ReportRequest({
    required this.reporterUserId,
    required this.resourceType,
    this.description,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'reporter_user_id': reporterUserId,
      'resource_type': resourceType,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
    };
  }
}
