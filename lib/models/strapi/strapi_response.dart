class StrapiUploadResponse {
  final int id;
  final String name;
  final String url;
  final String mimeType;
  final double size;

  StrapiUploadResponse({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
    required this.size,
  });

  factory StrapiUploadResponse.fromJson(Map<String, dynamic> json) {
    return StrapiUploadResponse(
        id: json['id'],
        name: json['name'],
        url: json['url'],
        mimeType: json['mime'],
        size: (json['size'] as num).toDouble());
  }
}
