import '/models/recipe_model.dart';

class RecipeController {
  final List<Recipe> allRecipes = [
    Recipe(title: "Lasagna Original Italiana", chef: "kitchenMate", duration: "35 mins", imageUrl: "assets/recipes/recipe12.jpg", rating: 4, hashtags: "Cena, Pasta, Italiana", steps: ["Cocinar la pasta", "Preparar la salsa", "Armar la lasagna", "Hornear"], recipeId: "1", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Pasta", typeFood: "Cena", typeCuisine: "Italiana"),
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg", rating: 4, hashtags: "Proteina, Cena, Navidad", steps: ["Preparar el relleno", "Rellenar el pavo", "Hornear"], recipeId: "2", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Cena", typeCuisine: "Navidad"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg", rating: 5, hashtags: "Frutas, Postre", steps: ["Cortar las frutas", "Armar el plato", "Servir"], recipeId: "3", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Frutas", typeFood: "Postre", typeCuisine: "Internacional"),
    Recipe(title: "Torta de Patatas", chef: "kitchenMate", duration: "40 mins", imageUrl: "assets/recipes/recipe10.jpg", rating: 5, hashtags: "Cena, Vegetariana, Española", steps: ["Cocinar las papas", "Preparar la mezcla", "Hornear"], recipeId: "4", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Vegetariana", typeFood: "Cena", typeCuisine: "Española"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg", rating: 4, hashtags: "Cereal, Desayuno, Colombiana", steps: ["Preparar la masa", "Freír los buñuelos"], recipeId: "5", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Cereal", typeFood: "Desayuno", typeCuisine: "Colombiana"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg", rating: 4, hashtags: "Frutas, Bebida", steps: ["Exprimir las naranjas", "Mezclar con hielo"], recipeId: "6", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Frutas", typeFood: "Bebida", typeCuisine: "Internacional"),
    Recipe(title: "Desayuno: Arepa Colombo Venezolana con Huevo", chef: "kitchenMate", duration: "15 mins", imageUrl: "assets/recipes/recipe11.jpg", rating: 4, hashtags: "Desayuno, Proteina, Colombiana, Venezolana", steps: ["Cocinar la arepa", "Freír el huevo", "Servir"], recipeId: "7", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Desayuno", typeCuisine: "Colombiana"),
    Recipe(title: "Paella Sencilla", chef: "Chilindrinita99", duration: "80 mins", imageUrl: "assets/recipes/recipe7.jpg", rating: 3, hashtags: "Cena, Arroz, Mariscos", steps: ["Preparar los ingredientes", "Cocinar el arroz", "Hornear"], recipeId: "8", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Arroz", typeFood: "Cena", typeCuisine: "Española"),
    Recipe(title: "Mariscos Caleños", chef: "Dora_Explora", duration: "35 mins", imageUrl: "assets/recipes/recipe6.jpg", rating: 5, hashtags: "Cena, Mariscos, Colombiana", steps: ["Preparar los mariscos", "Cocinar los mariscos"], recipeId: "9", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Mariscos", typeFood: "Cena", typeCuisine: "Colombiana"),
    Recipe(title: "Perro Caliente Colombiano", chef: "Tia_Piedad", duration: "15 mins", imageUrl: "assets/recipes/recipe2.jpg", rating: 3, hashtags: "Proteina, Almuerzo, Colombiana", steps: ["Cocinar las salchichas", "Armar el perro caliente"], recipeId: "10", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Almuerzo", typeCuisine: "Colombiana"),
    Recipe(title: "Salchipapa Venezolana XXL", chef: "Laura_Bozzo", duration: "35 mins", imageUrl: "assets/recipes/recipe1.jpg", rating: 5, hashtags: "Proteina, Cena, Venezolana", steps: ["Cocinar las salchichas", "Freír las papas"], recipeId: "11", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Cena", typeCuisine: "Venezolana"),
    Recipe(title: "Pasta Alfredo", chef: "Machis", duration: "30 mins", imageUrl: "assets/recipes/recipe3.jpg", rating: 4, hashtags: "Cena, Pasta, Italiana", steps: ["Cocinar la pasta", "Preparar la salsa", "Servir"], recipeId: "12", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Pasta", typeFood: "Cena", typeCuisine: "Italiana"),
  ];

  List<Recipe> getFilteredRecipes(String query, int recipesToShow) {
    return allRecipes
        .where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase()))
        .take(recipesToShow)
        .toList();
  }

  String getImageUrl(String recipeId) {
    return allRecipes.firstWhere((recipe) => recipe.recipeId == recipeId).imageUrl;
  }

  String getTitle(String recipeId) {
    return allRecipes.firstWhere((recipe) => recipe.recipeId == recipeId).title;
  }

  List<String> getSteps(String recipeId) {
    return allRecipes.firstWhere((recipe) => recipe.recipeId == recipeId).steps;
  }
}