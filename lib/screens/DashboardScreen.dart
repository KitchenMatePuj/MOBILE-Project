import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('¡Bienvenido de Nuevo!'), backgroundColor: const Color(0xFF129575)),
      body: const Center(
        child: Text('Dashboard Screen'),
      ),
    );
  }
}
