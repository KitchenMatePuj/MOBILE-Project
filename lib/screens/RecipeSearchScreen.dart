import 'package:flutter/material.dart';

class RecipeSearchScreen extends StatelessWidget {
  const RecipeSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Search')),
      body: const Center(
        child: Text('Recipe Search Screen'),
      ),
    );
  }
}
