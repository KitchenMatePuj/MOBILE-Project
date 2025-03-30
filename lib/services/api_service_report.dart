import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceReport {
  static const String _baseUrl = 'http://localhost:8002/reports/';

  Future<bool> createReport(String reporterUserId, String resourceType, String resourceId, String description, String status) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'reporter_user_id': reporterUserId,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'description': description,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create report: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listReports() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list reports: ${response.body}');
      return [];
    }
  }

  Future<bool> updateReport(int reportId, String description, String status) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$reportId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'description': description,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update report: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteReport(int reportId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$reportId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete report: ${response.body}');
      return false;
    }
  }
}