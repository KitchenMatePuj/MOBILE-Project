import 'package:flutter_dotenv/flutter_dotenv.dart';

String getFullImageUrl(String? path, {required String placeholder}) {
  try {
    if (path == null || path.isEmpty || path == 'example') return placeholder;

    path = path.replaceAll('"', '').trim();

    if (path.contains('/assets/recipes/platovacio')) {
      return placeholder;
    }

    if (path.startsWith('http')) return path;

    final assetReg =
        RegExp(r'^/?assets/.*\.(png|jpe?g|webp)$', caseSensitive: false);
    if (assetReg.hasMatch(path)) {
      return path.startsWith('/') ? path.substring(1) : path;
    }

    final base = dotenv.env['STRAPI_URL']?.replaceAll(RegExp(r'/$'), '') ?? '';
    final fixedPath = path.startsWith('/') ? path : '/$path';
    return '$base$fixedPath';
  } catch (_) {
    return placeholder;
  }
}
