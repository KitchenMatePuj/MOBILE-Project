import '/models/user_model.dart';
import '/models/profile_model.dart';
import '/controllers/profile_controller.dart';

class LoginController {
  final ProfileController profileController = ProfileController();

  Future<Profile?> login(String email, String password) async {
    // await Future.delayed(Duration(seconds: 1)); // Simula una llamada a una API
    for (Profile profile in profileController.recommendedProfiles) {
      if (profile.email == email && profile.password == password) {
        return profile;
      }
    }
    return null;
  }
}