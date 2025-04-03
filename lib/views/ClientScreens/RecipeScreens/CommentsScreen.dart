// import 'package:flutter/material.dart';
// import '/models/comment_model.dart';
// import '/controllers/comment_controller.dart';
// import '/controllers/profile_controller.dart';

// class CommentsScreen extends StatelessWidget {
//   final int recipeId;

//   const CommentsScreen({required this.recipeId, super.key});

//   @override
//   Widget build(BuildContext context) {
//     final CommentController commentController = CommentController();
//     final ProfileController profileController = ProfileController();

//     final List<Comment> comments = commentController.getCommentsByRecipeId(recipeId);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Comentarios'),
//         backgroundColor: const Color(0xFF129575),
//         foregroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 '${comments.length} Comentarios',
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Publica un Comentario',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Comparte tu opinión',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.send, color: Color(0xFF129575)),
//                   onPressed: () {
//                     // Lógica para enviar el comentario
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             comments.isEmpty
//                 ? Expanded(
//                     child: Center(
//                       child: Text(
//                         '¡Se el primero en Comentar!',
//                         style: TextStyle(color: Colors.grey, fontSize: 16),
//                       ),
//                     ),
//                   )
//                 : Expanded(
//                     child: ListView.builder(
//                       itemCount: comments.length,
//                       itemBuilder: (context, index) {
//                         final comment = comments[index];
//                         final profile = profileController.recommendedProfiles.firstWhere(
//                           (profile) => profile.keycloak_user_id == comment.usuario_que_comento_id,
//                         );

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.pushNamed(
//                                         context,
//                                         '/public_profile',
//                                         arguments: {'keycloak_user_id': profile.keycloak_user_id},
//                                       );
//                                     },
//                                     child: Row(
//                                       children: [
//                                         CircleAvatar(
//                                           backgroundImage: AssetImage(profile.imageUrl),
//                                           radius: 20,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               profile.first_name,
//                                               style: TextStyle(fontWeight: FontWeight.bold),
//                                             ),
//                                             Text(
//                                               '${comment.fecha_creacion.toLocal()}'.split(' ')[0],
//                                               style: TextStyle(color: Colors.grey, fontSize: 12),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   IconButton(
//                                     icon: const Icon(Icons.report, color: const Color.fromARGB(255, 181, 108, 106)),
//                                     onPressed: () {
//                                       // Lógica para reportar el comentario
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(comment.texto_comentario),
//                               const Divider(),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color.fromARGB(255, 83, 83, 83),
//         unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
//         onTap: (int index) {
//           switch (index) {
//             case 0:
//               Navigator.pushNamed(context, '/dashboard');
//               break;
//             case 1:
//               Navigator.pushNamed(context, '/recipe_search');
//               break;
//             case 2:
//               Navigator.pushNamed(context, '/create');
//               break;
//             case 3:
//               Navigator.pushNamed(context, '/shopping_list');
//               break;
//             case 4:
//               Navigator.pushNamed(context, '/profile');
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
//           BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Publicar'),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Compras'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
//         ],
//       ),
//     );
//   }
// }