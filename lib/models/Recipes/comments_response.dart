class CommentResponse {
  final int commentId;
  final int recipeId;
  final String authorUserId;
  final double? rating;
  final String text;
  final DateTime createdAt;

  CommentResponse({
    required this.commentId,
    required this.recipeId,
    required this.authorUserId,
    this.rating,
    required this.text,
    required this.createdAt,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      commentId: json['comment_id'],
      recipeId: json['recipe_id'],
      authorUserId: json['author_user_id'],
      rating: (json['rating'] != null) ? json['rating'].toDouble() : null,
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
