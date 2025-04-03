class IngredientAllergyResponse {
  final int allergyId;
  final int profileId;
  final String allergyName;

  IngredientAllergyResponse({
    required this.allergyId,
    required this.profileId,
    required this.allergyName,
  });

  factory IngredientAllergyResponse.fromJson(Map<String, dynamic> json) {
    return IngredientAllergyResponse(
      allergyId: json['allergy_id'],
      profileId: json['profile_id'],
      allergyName: json['allergy_name'],
    );
  }
}
