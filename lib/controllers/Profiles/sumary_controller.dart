import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/Profiles/summary_response.dart';

class SumaryController {
  final String baseUrl;

  SumaryController({required this.baseUrl});

  Future<ProfileSummaryResponse> getProfileSummary(
      String keycloakUserId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profiles/summary/$keycloakUserId'),
    );

    if (response.statusCode == 200) {
      return ProfileSummaryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile summary');
    }
  }
}
