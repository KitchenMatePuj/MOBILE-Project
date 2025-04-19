class LoginRequest {
  final String username;
  final String password;
  final String grantType;
  final String clientId;
  final String clientSecret;

  LoginRequest({
    required this.username,
    required this.password,
    this.grantType = 'password',
    this.clientId = 'fastapi-client',
    this.clientSecret = 'YOUR_SECRET_HERE',
  });


  Map<String, String> toJson() {
    return {
      'grant_type': grantType,
      'username': username,
      'password': password,
      'client_id': clientId,
      'client_secret': clientSecret,
    };
  }
}