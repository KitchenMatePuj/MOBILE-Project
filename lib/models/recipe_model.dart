class Recipe {
  final String title;
  final String chef;
  final String duration;
  final String imageUrl;
  final int? rating;
  final String? filters;

  Recipe({
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    this.rating,
    this.filters,
  });
}