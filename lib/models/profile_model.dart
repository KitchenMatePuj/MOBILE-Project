class Profile {
  final int keycloak_user_id;
  final int roleId;
  final String first_name;
  final String last_name;
  final String email;
  final List<String> forbidden_foods;
  final String imageUrl;
  final String password;
  final DateTime creation_date;
  final DateTime update_date;
  final String description;
  final List<int> followers;
  final List<int> following;
  final List<int> saved_recipes;
  final List<int> published_recipes;
  final List<int> shopping_list_recipes;

  Profile({
    required this.keycloak_user_id,
    required this.roleId,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.forbidden_foods,
    required this.imageUrl,
    required this.password,
    required this.creation_date,
    required this.update_date,
    required this.description,
    required this.followers,
    required this.following,
    required this.saved_recipes,
    required this.published_recipes,
    required this.shopping_list_recipes,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      keycloak_user_id: int.parse(json['keycloak_user_id'].toString()),
      roleId: json['role_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      forbidden_foods: List<String>.from(json['forbidden_foods'] ?? []),
      imageUrl: json['profile_photo'] ?? '',
      description: json['description'] ?? '',
      password: json['password'] ?? '',
      creation_date: DateTime.parse(json['created_at']),
      update_date: DateTime.parse(json['updated_at']),
      followers: List<int>.from(json['followers'] ?? []),
      following: List<int>.from(json['following'] ?? []),
      saved_recipes: List<int>.from(json['saved_recipes'] ?? []),
      published_recipes: List<int>.from(json['published_recipes'] ?? []),
      shopping_list_recipes: List<int>.from(json['shopping_list_recipes'] ?? []),
    );
  }
}