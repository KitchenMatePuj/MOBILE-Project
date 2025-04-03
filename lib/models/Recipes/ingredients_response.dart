class IngredientResponse {
  final int ingredientId;
  final String name;
  final String measurementUnit;

  IngredientResponse({
    required this.ingredientId,
    required this.name,
    required this.measurementUnit,
  });

  factory IngredientResponse.fromJson(Map<String, dynamic> json) {
    return IngredientResponse(
      ingredientId: json['ingredient_id'],
      name: json['name'],
      measurementUnit: json['measurement_unit'],
    );
  }
}
