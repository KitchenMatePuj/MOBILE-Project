class IngredientAllergyRequest {
  final int profileId;
  final String allergyName;

  IngredientAllergyRequest({
    required this.profileId,
    required this.allergyName,
  });

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'allergy_name': allergyName,
      };
}
