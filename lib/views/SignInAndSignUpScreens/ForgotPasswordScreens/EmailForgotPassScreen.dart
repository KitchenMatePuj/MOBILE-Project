// import 'package:flutter/material.dart';
// import '/controllers/password_reset_controller.dart';
// import '/models/password_reset_model.dart';

// class EmailForgotPassScreen extends StatefulWidget {
//   const EmailForgotPassScreen({super.key});

//   @override
//   _EmailForgotPassScreenState createState() => _EmailForgotPassScreenState();
// }

// class _EmailForgotPassScreenState extends State<EmailForgotPassScreen> {
//   final _emailController = TextEditingController();
//   String? _emailError;
//   bool _canSendCode = false;

//   late PasswordResetController _controller;

//   @override
//   void initState() {
//     super.initState();
//     final model = PasswordResetModel();
//     _controller = PasswordResetController(model: model);
//   }

//   void _validateEmail() {
//     final email = _emailController.text;

//     setState(() {
//       _emailError = _controller.validateEmail(email);
//       _canSendCode = _controller.canSendCode(email);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Restaurar Contraseña'),
//         backgroundColor: const Color(0xFF129575),
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//           color: Colors.white,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         margin: EdgeInsets.all(0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Spacer(flex: 2),
//             const Text(
//               "¿Olvidaste tu\nContraseña?,",
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "Restablecela rápidamente\nsin preocupaciones",
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Color(0xFF121212),
//               ),
//             ),
//             const Spacer(flex: 2),
//             _buildEmailInput(),
//             _buildConfirmButton(context),
//             const SizedBox(height: 30),
//             const Spacer(flex: 50),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmailInput() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Escriba su Correo Electrónico para enviarle un código de recuperación",
//           style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
//         ),
//         const SizedBox(height: 5),
//         TextField(
//           controller: _emailController,
//           decoration: InputDecoration(
//             hintText: "Ingrese su correo electrónico por favor",
//             errorText: _emailError,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: Color(0xFFD9D9D9),
//                 width: 1.5,
//               ),
//             ),
//             contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
//           ),
//           onChanged: (value) => _validateEmail(),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildConfirmButton(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           backgroundColor: const Color(0xFF129575),
//         ),
//         onPressed: _canSendCode
//             ? () {
//                 Navigator.pushNamed(context, '/forgot_password');
//               }
//             : null,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Enviar Código",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 11),
//             const Icon(
//               Icons.arrow_forward,
//               size: 20,
//               color: Colors.white,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }