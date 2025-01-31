class Ingredient {
  final String id; // Identificador único del ingrediente
  final String name; // Nombre del ingrediente
  final String imageUrl; // Ubicación de la imagen del ingrediente (assets/ingredientes/)

  Ingredient({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Método para convertir un JSON en una instancia de Ingredient
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  // Método para convertir una instancia de Ingredient a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}
