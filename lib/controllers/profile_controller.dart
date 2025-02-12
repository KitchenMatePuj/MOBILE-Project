import '/models/profile_model.dart';

class ProfileController {
  final List<Profile> recommendedProfiles = [
    Profile(name: "Laura_Bozzo", description: "Chef de comidas rápidas y cenas abundantes.", imageUrl: "assets/chefs/Laura_Bozzo.jpg"),
    Profile(name: "Tia_Piedad", description: "Cocinera de almuerzos rápidos y deliciosos.", imageUrl: "assets/chefs/Tia_Piedad.jpg"),
    Profile(name: "Machis", description: "Amante de la pasta y la cocina italiana.", imageUrl: "assets/chefs/Machis.jpg"),
    Profile(name: "Dora_Explora", description: "Chef de mariscos y cenas especiales.", imageUrl: "assets/chefs/Dora_Explora.jpg"),
    Profile(name: "Chilindrinita99", description: "Experta en cocina española y mariscos.", imageUrl: "assets/chefs/Chilindrinita99.jpg"),
  ];
}