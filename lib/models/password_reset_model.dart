class PasswordResetModel {
  String? email;
  String? code;
  String? newPassword;
  String? confirmNewPassword;

  PasswordResetModel({
    this.email,
    this.code,
    this.newPassword,
    this.confirmNewPassword,
  });

  // Validar que el correo sea válido
  bool validateEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  // Validar que la contraseña cumpla con los requisitos
  bool validatePassword(String password) {
    final hasMinLength = password.length > 8;
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    return hasMinLength && hasNumber && hasSymbol;
  }

  // Validar que las contraseñas coincidan
  bool passwordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}