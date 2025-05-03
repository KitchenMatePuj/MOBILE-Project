import 'package:flutter_dotenv/flutter_dotenv.dart';

String getFullImageUrl(String? path, {required String placeholder}) {
  try {
    if (path == null || path.isEmpty || path == 'example') return placeholder;
    if (path.startsWith('http')) return path;
    final base = dotenv.env['STRAPI_URL']?.replaceAll(RegExp(r'/$'), '') ?? '';
    final fixedPath = path.startsWith('/') ? path : '/$path';
    return '$base$fixedPath';
  } catch (_) {
    return placeholder;
  }
}
