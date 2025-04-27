import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/strapi/strapi_request.dart';
import '../../models/strapi/strapi_response.dart';

class StrapiController {
  final String baseUrl;

  StrapiController({required this.baseUrl});

  Future<StrapiUploadResponse> uploadImage(StrapiUploadRequest req) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);

    // Selecciona el archivo correcto
    if (req.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          req.bytes!,
          filename: req.filename,
          contentType: MediaType.parse(req.mimeType),
        ),
      );
    } else if (req.file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          req.file!.path,
          filename: req.filename,
          contentType: MediaType.parse(req.mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📡 Strapi response status: ${response.statusCode}');
    print('📡 Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return StrapiUploadResponse.fromJson((data as List).first);
    } else {
      throw Exception('Strapi upload failed: ${response.body}');
    }
  }
}
