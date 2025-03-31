class UserModel {
  late int keycloak_user_id;
  late int roleId;
  late String first_name;
  late String last_name;
  late String email;
  late List<String> forbidden_foods;
  late String imageUrl;
  late String description;
  late String password;
  late DateTime creation_date;
  late DateTime update_date;
  late List<int> followers;
  late List<int> following;
  late List<int> saved_recipes;
  late List<int> published_recipes;
  late List<int> shopping_list_recipes;

  UserModel({
    required this.keycloak_user_id,
    required this.roleId,
    required this.first_name,
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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

  bool validatePassword(String password) {
    final hasMinLength = password.length > 8;
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    return hasMinLength && hasNumber && hasSymbol;
  }

  bool validateEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  bool validateFirstName(String first_name) {
    return first_name.isNotEmpty;
  }

  bool validateLastName(String last_name) {
    return last_name.isNotEmpty;
  }
}