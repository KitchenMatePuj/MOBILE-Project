class ProfileRequest {
  final String? keycloakUserId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final String? accountStatus;
  final int? cookingTime;
  final String? description;

  ProfileRequest({
    this.keycloakUserId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profilePhoto,
    this.accountStatus,
    this.cookingTime,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'keycloak_user_id': keycloakUserId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'profile_photo': profilePhoto,
        'account_status': accountStatus,
        'cooking_time': cookingTime,
        'description': description,
      };
}
