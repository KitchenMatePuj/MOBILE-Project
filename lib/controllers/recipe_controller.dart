import '/models/recipe_model.dart';

class RecipeController {
  final List<Recipe> allRecipes = [
    Recipe(title: "Lasagna Original Italiana", chef: "kitchenMate", duration: "35 mins", imageUrl: "assets/recipes/recipe12.jpg", rating: 4, filters: "Cena, Pasta, Italiana"),
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg", rating: 4, filters: "Proteina, Cena, Navidad"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg", rating: 5, filters: "Frutas, Postre"),
    Recipe(title: "Torta de Patatas", chef: "kitchenMate", duration: "40 mins", imageUrl: "assets/recipes/recipe10.jpg", rating: 5, filters: "Cena, Vegetariana, Española"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg", rating: 4, filters: "Cereal, Desayuno, Colombiana"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg", rating: 4, filters: "Frutas, Bebida"),
    Recipe(title: "Desayuno: Arepa Colombo Venezolana con Huevo", chef: "kitchenMate", duration: "15 mins", imageUrl: "assets/recipes/recipe11.jpg", rating: 4, filters: "Desayuno, Proteina, Colombiana, Venezolana"),
  ];

  final List<Recipe> allRecipes2 = [
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg", rating: 4, filters: "Proteina, Cena, Navidad"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg", rating: 5, filters: "Frutas, Postre"),
    Recipe(title: "Paella Sencilla", chef: "Chilindrinita99", duration: "80 mins", imageUrl: "assets/recipes/recipe7.jpg", rating: 3, filters: "Cena, Arroz, Mariscos"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg", rating: 4, filters: "Cereal, Desayuno, Colombiana"),
    Recipe(title: "Mariscos Caleños", chef: "Dora_Explora", duration: "35 mins", imageUrl: "assets/recipes/recipe6.jpg", rating: 5, filters: "Cena, Mariscos, Colombiana"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg", rating: 4, filters: "Frutas, Bebida"),
    Recipe(title: "Perro Caliente Colombiano", chef: "Tia_Piedad", duration: "15 mins", imageUrl: "assets/recipes/recipe2.jpg", rating: 3, filters: "Proteina, Almuerzo, Colombiana"),
    Recipe(title: "Salchipapa Venezolana XXL", chef: "Laura_Bozzo", duration: "35 mins", imageUrl: "assets/recipes/recipe1.jpg", rating: 5, filters: "Proteina, Cena, Venezolana"),
    Recipe(title: "Pasta Alfredo", chef: "Machis", duration: "30 mins", imageUrl: "assets/recipes/recipe3.jpg", rating: 4, filters: "Cena, Pasta, Italiana"),
  ];

  List<Recipe> getFilteredRecipes(String query, int recipesToShow) {
    return allRecipes
        .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
        .take(recipesToShow)
        .toList();
  }

  List<Recipe> getFilteredRecipes2(String query, int recipesToShow) {
    return allRecipes2
        .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
        .take(recipesToShow)
        .toList();
  }
}