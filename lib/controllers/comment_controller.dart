import '/models/comment_model.dart';

class CommentController {
  final List<Comment> comments = [
    Comment(comentario_id: 1, receta_id: 13, usuario_que_comento_id: 2, texto_comentario: "¡Esta receta es increíble!", fecha_creacion: DateTime.now()),
    Comment(comentario_id: 2, receta_id: 13, usuario_que_comento_id: 3, texto_comentario: "Me encantó, gracias por compartir.", fecha_creacion: DateTime.now()),
    Comment(comentario_id: 3, receta_id: 13, usuario_que_comento_id: 4, texto_comentario: "¡Muy fácil de seguir!", fecha_creacion: DateTime.now()),
    Comment(comentario_id: 4, receta_id: 3, usuario_que_comento_id: 5, texto_comentario: "Perfecta para una cena rápida.", fecha_creacion: DateTime.now()),
    Comment(comentario_id: 5, receta_id: 2, usuario_que_comento_id: 6, texto_comentario: "¡Deliciosa receta!", fecha_creacion: DateTime.now()),
  ];

  List<Comment> getCommentsByRecipeId(int recipeId) {
    return comments.where((comment) => comment.receta_id == recipeId).toList();
  }

  List<Comment> getCommentsByUserId(int userId) {
    return comments.where((comment) => comment.usuario_que_comento_id == userId).toList();
  }

  void addComment(Comment comment) {
    comments.add(comment);
  }
}