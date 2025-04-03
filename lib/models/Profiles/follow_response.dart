class FollowResponse {
  final int followerId;
  final int followedId;

  FollowResponse({
    required this.followerId,
    required this.followedId,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      followerId: json['follower_id'],
      followedId: json['followed_id'],
    );
  }
}
