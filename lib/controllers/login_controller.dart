import '/models/user_model.dart';

class LoginController {
  final UserModel userModel;

  LoginController({required this.userModel});

  Future<bool> login(String email, String password) async {
    // Aquí se podrá agregar la lógica para autenticar al usuario.
    // Por simplicidad, aquí hice una comparación sencilla.
    await Future.delayed(Duration(seconds: 1)); // Simula una llamada a una API
    return email == userModel.email && password == userModel.password;
  }
}