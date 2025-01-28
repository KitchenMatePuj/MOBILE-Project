import 'package:flutter/material.dart';

class NutritionFormScreen extends StatelessWidget {
  const NutritionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Form')),
      body: const Center(
        child: Text('Nutrition Form Screen'),
      ),
    );
  }
}
