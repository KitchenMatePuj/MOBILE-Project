class RecipeStepRequest {
  final int stepNumber;
  final String title;
  final String description;

  RecipeStepRequest({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'title': title,
      'description': description,
    };
  }
}
