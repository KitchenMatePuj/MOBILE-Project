class CommentRequest {
  final String authorUserId;
  final double? rating;
  final String text;

  CommentRequest({
    required this.authorUserId,
    this.rating,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'author_user_id': authorUserId,
      'rating': rating,
      'text': text,
    };
  }
}
