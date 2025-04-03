class ProfileResponse {
  final int profileId;
  final String keycloakUserId;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final String? accountStatus;
  final int? cookingTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileResponse({
    required this.profileId,
    required this.keycloakUserId,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.profilePhoto,
    this.accountStatus,
    this.cookingTime,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      profileId: json['profile_id'],
      keycloakUserId: json['keycloak_user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      profilePhoto: json['profile_photo'],
      accountStatus: json['account_status'],
      cookingTime: json['cooking_time'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
