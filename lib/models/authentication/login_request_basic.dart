class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, String> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}