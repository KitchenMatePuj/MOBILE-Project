class Recipe {
  final String id; // Identificador único de la receta
  final String title; // Título de la receta
  final String chef; // Nombre del chef
  final String duration; // Duración de la receta
  final int rating; // Calificación de la receta
  final List<String> filters; // Filtros de la receta
  final List<String> ingredients; // lista de sus ingredientes
  final List<String> steps; // lista de pasos a seguir
  final String RecipeImageUrl; // Uri de fotos de las Recetas

  Recipe({
    required this.id,
    required this.title,
    required this.chef,
    required this.duration,
    required this.rating,
    required this.filters,
    required this.ingredients,
    required this.steps,
    required this.RecipeImageUrl,
  });

  // Método para convertir un JSON en una instancia de Recipe
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      chef: json['chef'],
      duration: json['duration'],
      rating: json['rating'],
      filters: List<String>.from(json['filters']),
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      RecipeImageUrl: json['RecipeImageUrl'],
    );
  }

  // Método para convertir una instancia de Recipe a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chef': chef,
      'duration': duration,
      'rating': rating,
      'filters': filters,
      'ingredients': ingredients,
      'steps': steps,
      'RecipeImageUrl': RecipeImageUrl,
    };
  }
}
