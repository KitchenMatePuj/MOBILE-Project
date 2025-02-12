class UserModel {
  final String fullName;
  final String email;
  final String alias;
  final String password;

  UserModel({
    required this.fullName,
    required this.email,
    required this.alias,
    required this.password,
  });

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
}