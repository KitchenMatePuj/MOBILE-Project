class FollowRequest {
  final int followerId;
  final int followedId;

  FollowRequest({
    required this.followerId,
    required this.followedId,
  });

  Map<String, dynamic> toJson() => {
        'follower_id': followerId,
        'followed_id': followedId,
      };
}
