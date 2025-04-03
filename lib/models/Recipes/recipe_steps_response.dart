class RecipeStepResponse {
  final int recipeStepId;
  final int recipeId;
  final int stepNumber;
  final String title;
  final String description;

  RecipeStepResponse({
    required this.recipeStepId,
    required this.recipeId,
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  factory RecipeStepResponse.fromJson(Map<String, dynamic> json) {
    return RecipeStepResponse(
      recipeStepId: json['recipe_step_id'],
      recipeId: json['recipe_id'],
      stepNumber: json['step_number'],
      title: json['title'],
      description: json['description'],
    );
  }
}
