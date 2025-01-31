class Profile {
  final String email;
  final String name;
  final String username; // Identificador único
  final String password;
  final bool isComplete;
  final List<String> dietaryPreferences;
  final String profilePicture; // Ubicación de la foto en assets/chefs/
  final String description; // Descripción del perfil
  final List<String> followers; // Usernames de los seguidores
  final List<String> following; // Usernames de los seguidos
  final List<String> savedRecipes; // IDs de recetas guardadas
  final List<String> shoppingListRecipes; // IDs de recetas agregadas a la lista de compras
  final List<String> puplishedRecipes; // IDs de recetas publicadas

  Profile({
    required this.email,
    required this.name,
    required this.username,
    required this.password,
    required this.isComplete,
    required this.dietaryPreferences,
    required this.profilePicture,
    required this.description,
    required this.followers,
    required this.following,
    required this.savedRecipes,
    required this.puplishedRecipes,
    required this.shoppingListRecipes,
  });

  // Método para convertir un JSON en una instancia de Profile
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      email: json['email'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      isComplete: json['isComplete'],
      dietaryPreferences: List<String>.from(json['dietaryPreferences']),
      profilePicture: json['profilePicture'],
      description: json['description'],
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
      savedRecipes: List<String>.from(json['savedRecipes']),
      puplishedRecipes: List<String>.from(json['puplishedRecipes']),
      shoppingListRecipes: List<String>.from(json['shoppingListRecipes']),
    );
  }

  // Método para convertir una instancia de Profile a JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'password': password,
      'isComplete': isComplete,
      'dietaryPreferences': dietaryPreferences,
      'profilePicture': profilePicture,
      'description': description,
      'followers': followers,
      'following': following,
      'savedRecipes': savedRecipes,
      'puplishedRecipes': puplishedRecipes,
      'shoppingListRecipes': shoppingListRecipes,
    };
  }
}
