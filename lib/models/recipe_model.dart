class Recipe {
  final String recipeId;
  final String title;
  final String chef;
  final String imageUrl;
  final DateTime creationDate;
  final DateTime updateDate;
  final List<String> steps;
  final int? total_servings;
  final String? hashtags;
  final String duration;
  final int? rating;
  final String category;
  final String typeFood;
  final String typeCuisine;

  Recipe({
    required this.title,
    required this.chef,
    required this.duration,
    required this.imageUrl,
    this.rating,
    required this.total_servings,
    this.hashtags,
    required this.category,
    required this.typeFood,
    required this.typeCuisine,
    required this.steps,
    required this.recipeId,
    required this.creationDate,
    required this.updateDate,
  });
}