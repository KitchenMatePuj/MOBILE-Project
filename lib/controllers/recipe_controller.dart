import '/models/recipe_model.dart';

class RecipeController {
  final List<Recipe> allRecipes = [
    Recipe(title: "Lasagna Original Italiana", chef: "kitchenMate", duration: "35 mins", imageUrl: "assets/recipes/recipe12.jpg", rating: 4, hashtags: "Cena, Pasta, Italiana", steps: ["Paso 1: Cocinar la pasta", "Paso 2: Preparar la salsa", "Paso 3: Armar la lasagna", "Paso 4: Hornear"], recipeId: "1", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Pasta", typeFood: "Cena", typeCuisine: "Italiana"),
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg", rating: 4, hashtags: "Proteina, Cena, Navidad", steps: ["Paso 1: Preparar el relleno", "Paso 2: Rellenar el pavo", "Paso 3: Hornear"], recipeId: "2", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Cena", typeCuisine: "Navidad"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg", rating: 5, hashtags: "Frutas, Postre", steps: ["Paso 1: Cortar las frutas", "Paso 2: Armar el plato", "Paso 3: Servir"], recipeId: "3", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Frutas", typeFood: "Postre", typeCuisine: "Internacional"),
    Recipe(title: "Torta de Patatas", chef: "kitchenMate", duration: "40 mins", imageUrl: "assets/recipes/recipe10.jpg", rating: 5, hashtags: "Cena, Vegetariana, Española", steps: ["Paso 1: Cocinar las papas", "Paso 2: Preparar la mezcla", "Paso 3: Hornear"], recipeId: "4", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Vegetariana", typeFood: "Cena", typeCuisine: "Española"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg", rating: 4, hashtags: "Cereal, Desayuno, Colombiana", steps: ["Paso 1: Preparar la masa", "Paso 2: Freír los buñuelos"], recipeId: "5", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Cereal", typeFood: "Desayuno", typeCuisine: "Colombiana"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg", rating: 4, hashtags: "Frutas, Bebida", steps: ["Paso 1: Exprimir las naranjas", "Paso 2: Mezclar con hielo"], recipeId: "6", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Frutas", typeFood: "Bebida", typeCuisine: "Internacional"),
    Recipe(title: "Desayuno: Arepa Colombo Venezolana con Huevo", chef: "kitchenMate", duration: "15 mins", imageUrl: "assets/recipes/recipe11.jpg", rating: 4, hashtags: "Desayuno, Proteina, Colombiana, Venezolana", steps: ["Paso 1: Cocinar la arepa", "Paso 2: Freír el huevo", "Paso 3: Servir"], recipeId: "7", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Desayuno", typeCuisine: "Colombiana"),
  ];

  final List<Recipe> allRecipes2 = [
    Recipe(title: "Pavo Relleno XXS", chef: "XxSportacusXx", duration: "125 mins", imageUrl: "assets/recipes/recipe8.jpg", rating: 4, hashtags: "Proteina, Cena, Navidad", steps: ["Paso 1: Preparar el relleno", "Paso 2: Rellenar el pavo", "Paso 3: Hornear"], recipeId: "2", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Cena", typeCuisine: "Navidad"),
    Recipe(title: "Banana Split Casera", chef: "Rihannita", duration: "20 mins", imageUrl: "assets/recipes/recipe9.jpg", rating: 5, hashtags: "Frutas, Postre", steps: ["Paso 1: Cortar las frutas", "Paso 2: Armar el plato", "Paso 3: Servir"], recipeId: "3", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Frutas", typeFood: "Postre", typeCuisine: "Internacional"),
    Recipe(title: "Paella Sencilla", chef: "Chilindrinita99", duration: "80 mins", imageUrl: "assets/recipes/recipe7.jpg", rating: 3, hashtags: "Cena, Arroz, Mariscos", steps: ["Paso 1: Preparar los ingredientes", "Paso 2: Cocinar el arroz", "Paso 3: Hornear"], recipeId: "8", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Arroz", typeFood: "Cena", typeCuisine: "Española"),
    Recipe(title: "Buñuelos Paisa", chef: "Voldi_Feliz", duration: "25 mins", imageUrl: "assets/recipes/recipe4.jpg", rating: 4, hashtags: "Cereal, Desayuno, Colombiana", steps: ["Paso 1: Preparar la masa", "Paso 2: Freír los buñuelos"], recipeId: "5", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Cereal", typeFood: "Desayuno", typeCuisine: "Colombiana"),
    Recipe(title: "Mariscos Caleños", chef: "Dora_Explora", duration: "35 mins", imageUrl: "assets/recipes/recipe6.jpg", rating: 5, hashtags: "Cena, Mariscos, Colombiana", steps: ["Paso 1: Preparar los mariscos", "Paso 2: Cocinar los mariscos"], recipeId: "9", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Mariscos", typeFood: "Cena", typeCuisine: "Colombiana"),
    Recipe(title: "Cóctel de Naranja", chef: "Calypso66", duration: "10 mins", imageUrl: "assets/recipes/recipe5.jpg", rating: 4, hashtags: "Frutas, Bebida", steps: ["Paso 1: Exprimir las naranjas", "Paso 2: Mezclar con hielo"], recipeId: "6", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Frutas", typeFood: "Bebida", typeCuisine: "Internacional"),
    Recipe(title: "Perro Caliente Colombiano", chef: "Tia_Piedad", duration: "15 mins", imageUrl: "assets/recipes/recipe2.jpg", rating: 3, hashtags: "Proteina, Almuerzo, Colombiana", steps: ["Paso 1: Cocinar las salchichas", "Paso 2: Armar el perro caliente"], recipeId: "10", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Almuerzo", typeCuisine: "Colombiana"),
    Recipe(title: "Salchipapa Venezolana XXL", chef: "Laura_Bozzo", duration: "35 mins", imageUrl: "assets/recipes/recipe1.jpg", rating: 5, hashtags: "Proteina, Cena, Venezolana", steps: ["Paso 1: Cocinar las salchichas", "Paso 2: Freír las papas"], recipeId: "11", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Proteina", typeFood: "Cena", typeCuisine: "Venezolana"),
    Recipe(title: "Pasta Alfredo", chef: "Machis", duration: "30 mins", imageUrl: "assets/recipes/recipe3.jpg", rating: 4, hashtags: "Cena, Pasta, Italiana", steps: ["Paso 1: Cocinar la pasta", "Paso 2: Preparar la salsa", "Paso 3: Servir"], recipeId: "12", creationDate: DateTime.now(), updateDate: DateTime.now(), category: "Pasta", typeFood: "Cena", typeCuisine: "Italiana"),
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