class NutritionQuestion {
  final String question;
  final List<String> options;
  List<String> selected;

  NutritionQuestion({
    required this.question,
    required this.options,
    required this.selected,
  });
}

class NutritionModel {
  final List<NutritionQuestion> questions = [
    NutritionQuestion(
      question: "¿Cuáles son tus hábitos alimenticios?",
      options: ["Desayuno Diario", "Comida rápida Ocasional", "Balanceado", "Ninguno en específico"],
      selected: [],
    ),
    NutritionQuestion(
      question: "¿Qué tipo de cocina prefieres?",
      options: ["Meditarránea", "Asiática", "Mexicana", "Italiana", "Ninguna en específico"],
      selected: [],
    ),
    NutritionQuestion(
      question: "¿Qué tipo de dieta sigues?",
      options: ["Vegetariana", "Vegana", "Omnívora", "Keto", "Paleo", "No tengo preferencias"],
      selected: [],
    ),
    NutritionQuestion(
      question: "¿Cuáles son tus objetivos de salud?",
      options: ["Pérdida peso", "Ganancia Muscular", "Mantenerme saludable", "Ninguno en específico"],
      selected: [],
    ),
    NutritionQuestion(
      question: "¿Tienes alguna alergia alimenticia?",
      options: ["Frutos Secos", "Gluten", "Lácteos", "Mariscos", "Ninguna"],
      selected: [],
    ),
    NutritionQuestion(
      question: "¿Tienes alguna intolerancia alimentaria?",
      options: ["Lactosa", "Gluten", "Ninguna"],
      selected: [],
    ),
  ];
}