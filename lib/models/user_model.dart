class UserModel {
  late int keycloakUserId;
  late int roleId;
  late String firstName;
  late String lastName;
  late String email;
  late List<String> forbiddenFoods;
  late String imageUrl;
  late String description;
  late String password;
  late DateTime creationDate;
  late DateTime updateDate;
  late List<int> followers;
  late List<int> following;
  late List<int> savedRecipes;
  late List<int> publishedRecipes;
  late List<int> shoppingListRecipes;

  UserModel({
    required this.keycloakUserId,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.forbiddenFoods,
    required this.imageUrl,
    required this.description,
    required this.password,
    required this.creationDate,
    required this.updateDate,
    required this.followers,
    required this.following,
    required this.savedRecipes,
    required this.publishedRecipes,
    required this.shoppingListRecipes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      keycloakUserId: json['keycloak_user_id'],
      roleId: json['role_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      forbiddenFoods: List<String>.from(json['forbidden_foods'] ?? []),
      imageUrl: json['profile_photo'] ?? '',
      description: json['description'] ?? '',
      password: json['password'] ?? '',
      creationDate: DateTime.parse(json['created_at']),
      updateDate: DateTime.parse(json['updated_at']),
      followers: List<int>.from(json['followers'] ?? []),
      following: List<int>.from(json['following'] ?? []),
      savedRecipes: List<int>.from(json['saved_recipes'] ?? []),
      publishedRecipes: List<int>.from(json['published_recipes'] ?? []),
      shoppingListRecipes: List<int>.from(json['shopping_list_recipes'] ?? []),
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

  bool validateFisrtName(String firstName) {
    return firstName.isNotEmpty;
  }

  bool validateLastName(String lastName) {
    return lastName.isNotEmpty;
  }
}