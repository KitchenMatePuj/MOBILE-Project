import 'dart:typed_data';
import 'dart:io' show File; // ok en mobile; se ignora en web si no se usa
import 'package:path/path.dart' as p;

/// Un único request que admite bytes (web) o File (mobile)
class StrapiUploadRequest {
  final File? file; // null en Web
  final Uint8List? bytes; // null en Mobile
  final String filename;
  final String mimeType;

  StrapiUploadRequest.fromFile(this.file)
      : bytes = null,
        filename = p.basename(file!.path),
        mimeType = _mime(p.extension(file!.path));

  StrapiUploadRequest.fromBytes({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  }) : file = null;

  static String _mime(String ext) {
    switch (ext.toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
