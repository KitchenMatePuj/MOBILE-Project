import '/models/password_reset_model.dart';

class PasswordResetController {
  final PasswordResetModel model;

  PasswordResetController({required this.model});

  String? validateEmail(String email) {
    if (model.validateEmail(email)) {
      return null;
    } else {
      return 'Introduce un correo electrónico válido.';
    }
  }

  String? validatePassword(String password) {
    if (model.validatePassword(password)) {
      return null;
    } else {
      return 'La contraseña debe tener más de 8 caracteres, un número y un símbolo.';
    }
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (model.passwordsMatch(password, confirmPassword)) {
      return null;
    } else {
      return 'Las contraseñas no coinciden.';
    }
  }

  bool canSendCode(String email) {
    return validateEmail(email) == null;
  }

  bool canResetPassword(String code, String newPassword, String confirmNewPassword) {
    return code.isNotEmpty &&
           validatePassword(newPassword) == null &&
           validateConfirmPassword(newPassword, confirmNewPassword) == null;
  }
}