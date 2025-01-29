import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Usuario'),
        backgroundColor: const Color(0xFF129575),
      ),
      body: const Center(
        child: Text('Perfil del Usuario'),
      ),
    );
  }
}
