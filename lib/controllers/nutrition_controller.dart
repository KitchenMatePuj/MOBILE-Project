import '/models/nutrition_model.dart';

class NutritionController {
  final NutritionModel model;

  NutritionController({required this.model});

  List<NutritionQuestion> getQuestions() {
    return model.questions;
  }

  void updateSelectedOptions(NutritionQuestion question, List<String> selectedOptions) {
    question.selected = selectedOptions;
  }
}