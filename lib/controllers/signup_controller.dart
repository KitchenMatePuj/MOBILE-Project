import '/models/user_model.dart';

class SignUpController {
  final UserModel userModel;

  SignUpController({required this.userModel});

  String? validatePassword(String password) {
    if (userModel.validatePassword(password)) {
      return null;
    } else {
      return 'La contraseña debe tener más de 8 caracteres, un número y un símbolo.';
    }
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (password == confirmPassword) {
      return null;
    } else {
      return 'Las contraseñas no coinciden.';
    }
  }

  String? validateEmail(String email) {
    if (userModel.validateEmail(email)) {
      return null;
    } else {
      return 'Introduce un correo electrónico válido.';
    }
  }

  String? validateFullName(String fullName) {
    if (userModel.validateFisrtName(fullName)) {
      return null;
    } else {
      return 'Introduce tu nombre completo.';
    }
  }

  String? validate(String alias) {
    if (userModel.validateLastName(alias)) {
      return null;
    } else {
      return 'Introduce tu apellido completo.';
    }
  }

  bool canContinue(String fullName, String email, String alias, String password, String confirmPassword) {
    return fullName.isNotEmpty &&
           email.isNotEmpty &&
           alias.isNotEmpty &&
           validateEmail(email) == null &&
           validatePassword(password) == null &&
           validateConfirmPassword(password, confirmPassword) == null;
  }
}