class Comment {
  final int comentario_id;
  final int receta_id;
  final int usuario_que_comento_id;
  final String texto_comentario;
  final DateTime fecha_creacion;

  Comment({
    required this.comentario_id,
    required this.receta_id,
    required this.usuario_que_comento_id,
    required this.texto_comentario,
    required this.fecha_creacion,
  });
}