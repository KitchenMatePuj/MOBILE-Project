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
  final List<NutritionQuestion> questions;

  NutritionModel(List<String> restrictedFoods)
      : questions = [
          NutritionQuestion(
            question: "Alimentos Restringidos",
            options: restrictedFoods,
            selected: [],
          ),
        ];
}