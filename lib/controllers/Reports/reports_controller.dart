import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/Reports/report_request.dart';
import '../../models/Reports/report_response.dart';

class ReportsController {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ReportsController({required this.baseUrl});

  /// Función privada para agregar Headers con Authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No JWT token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<ReportResponse>> fetchAllReports() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reports/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<ReportResponse> fetchReportById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ReportResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Report not found');
    }
  }

  Future<ReportResponse> createReport(ReportRequest report) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/reports/'),
      headers: headers,
      body: json.encode(report.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ReportResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create report');
    }
  }

  Future<ReportResponse> updateReport(int id, ReportRequest report) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/reports/$id'),
      headers: headers,
      body: json.encode(report.toJson()),
    );

    if (response.statusCode == 200) {
      return ReportResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update report');
    }
  }

  Future<void> deleteReport(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/reports/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete report');
    }
  }
}
