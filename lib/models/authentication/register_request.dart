class RegisterRequest {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
