import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/Reports/report_request.dart';
import '../../models/Reports/report_response.dart';

class ReportsController {
  static const String baseUrl = 'http://localhost:8002/reports/'; 

  Future<List<ReportResponse>> fetchAllReports() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<ReportResponse> fetchReportById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return ReportResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Report not found');
    }
  }

  Future<ReportResponse> createReport(ReportRequest report) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(report.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ReportResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create report');
    }
  }

  Future<ReportResponse> updateReport(int id, ReportRequest report) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(report.toJson()),
    );

    if (response.statusCode == 200) {
      return ReportResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update report');
    }
  }

  Future<void> deleteReport(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete report');
    }
  }
}
