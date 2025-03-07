class Profile {
  final int keycloak_user_id;
  final int roleId;
  final String name;
  final String last_name;
  final String email;
  final List<String> forbidden_foods;
  final String imageUrl;
  final String password;
  final DateTime creation_date;
  final DateTime update_date;

// Los siguientes datyos los necesito dentro y no tengo el phone (no lo vi necesario).
  final String description;
  final List<int> followers;
  final List<int> following;
  final List<int> saved_recipes;
  final List<int> published_recipes;
  final List<int> shopping_list_recipes;

  Profile({
    required this.keycloak_user_id,
    required this.roleId,
    required this.name,
    required this.last_name,
    required this.email,
    required this.forbidden_foods,
    required this.imageUrl,
    required this.description,
    required this.password,
    required this.creation_date,
    required this.update_date,
    required this.followers,
    required this.following,
    required this.saved_recipes,
    required this.published_recipes,
    required this.shopping_list_recipes,
  });
}