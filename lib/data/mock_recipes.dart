import '../models/recipe.dart';

List<Recipe> allRecipes = [
  Recipe(
    id: "recipe1",
    title: "Pavo Relleno XXS",
    chef: "XxSportacusXx",
    duration: "125 mins",
    rating: 4,
    filters: ["Proteina", "Cena", "Navidad"],
    ingredients: ["Pavo", "Manzana", "Ciruela", "Pimiento", "Cebolla"],
    steps: [
      "Precalentar el horno a 180°C.",
      "Lavar el pavo y secarlo con papel absorbente.",
      "Rellenar el pavo con las manzanas, ciruelas, pimientos y cebollas.",
      "Colocar el pavo en una bandeja para horno y hornear por 2 horas.",
      "Servir caliente."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_pavo.jpg",
  ),
  Recipe(
    id: "recipe2",
    title: "Banana Split Casera",
    chef: "Rihannita",
    duration: "20 mins",
    rating: 5,
    filters: ["Frutas", "Postre"],
    ingredients: ["Banana", "Helado", "Crema", "Cereza", "Chocolate"],
    steps: [
      "Pelar la banana y cortarla por la mitad.",
      "Colocar las mitades de banana en un plato.",
      "Agregar una bola de helado a cada mitad.",
      "Decorar con crema, cereza y chocolate."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_banana.jpg",
  ),
  Recipe(
    id: "recipe3",
    title: "Paella Sencilla",
    chef: "Chilindrinita99",
    duration: "80 mins",
    rating: 3,
    filters: ["Cena", "Arroz", "Mariscos"],
    ingredients: ["Arroz", "Mariscos", "Pimiento", "Cebolla", "Ajo"],
    steps: [
      "En una paellera, sofreír el ajo y la cebolla.",
      "Agregar el arroz y sofreír por 5 minutos.",
      "Incorporar los mariscos y el pimiento.",
      "Cubrir con agua y cocinar por 20 minutos.",
      "Servir caliente."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_paella.jpg",
  ),
  Recipe(
    id: "recipe4",
    title: "Buñuelos Paisa",
    chef: "Voldi_Feliz",
    duration: "25 mins",
    rating: 4,
    filters: ["Cereal", "Desayuno", "Colombiana"],
    ingredients: ["Harina", "Queso", "Huevo", "Sal", "Aceite"],
    steps: [
      "En un bowl, mezclar la harina, el queso y la sal.",
      "Agregar los huevos y mezclar hasta obtener una masa homogénea.",
      "Formar bolitas y freír en aceite caliente.",
      "Escurrir sobre papel absorbente y servir caliente."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_bunuelos.jpg",
  ),
  Recipe(
    id: "recipe5",
    title: "Mariscos Caleños",
    chef: "Dora_Explora",
    duration: "35 mins",
    rating: 5,
    filters: ["Cena", "Mariscos", "Colombiana"],
    ingredients: ["Camarón", "Pescado", "Calamar", "Coco", "Tomate"],
    steps: [
      "En una olla, sofreír el tomate y el coco.",
      "Agregar los mariscos y cocinar por 20 minutos.",
      "Servir caliente."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_mariscos.jpg",
  ),
  Recipe(
    id: "recipe6",
    title: "Cóctel de Naranja",
    chef: "Calypso66",
    duration: "10 mins",
    rating: 4,
    filters: ["Frutas", "Bebida"],
    ingredients: ["Naranja", "Azúcar", "Hielo", "Ron", "Menta"],
    steps: [
      "En una licuadora, mezclar la naranja, el azúcar y el hielo.",
      "Servir en un vaso y añadir el ron.",
      "Decorar con hojas de menta."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_naranja.jpg",
  ),
  Recipe(
    id: "recipe7",
    title: "Perro Caliente Colombiano",
    chef: "Tia_Piedad",
    duration: "15 mins",
    rating: 3,
    filters: ["Proteina", "Almuerzo", "Colombiana"],
    ingredients: ["Pan", "Salchicha", "Salsa", "Queso", "Papa"],
    steps: [
      "Cocinar la salchicha y la papa.",
      "Armas el perro caliente con el pan, la salchicha, la papa, la salsa y el queso."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_perro.jpg",
  ),
  Recipe(
    id: "recipe8",
    title: "Salchipapa Venezolana XXL",
    chef: "Laura_Bozzo",
    duration: "35 mins",
    rating: 5,
    filters: ["Proteina", "Cena", "Venezolana"],
    ingredients: ["Salchicha", "Papa", "Queso", "Salsa", "Cebolla"],
    steps: [
      "Freír las salchichas y las papas por separado.",
      "Servir en un plato y añadir queso, salsa y cebolla."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_salchipapa.jpg",
  ),
  Recipe(
    id: "recipe9",
    title: "Pasta Alfredo",
    chef: "Machis",
    duration: "30 mins",
    rating: 4,
    filters: ["Cena", "Pasta", "Italiana"],
    ingredients: ["Pasta", "Crema", "Queso", "Pollo", "Ajo"],
    steps: [
      "Cocinar la pasta en agua hirviendo con sal.",
      "En una sartén, sofreír el ajo y el pollo.",
      "Agregar la crema y el queso.",
      "Incorporar la pasta y mezclar bien."
    ],
    RecipeImageUrl: "assets/recipes/ingredient_pasta.jpg",
  ),
];
