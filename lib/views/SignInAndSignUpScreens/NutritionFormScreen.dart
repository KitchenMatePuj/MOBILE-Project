import 'package:flutter/material.dart';
import '/controllers/nutrition_controller.dart';
import '/models/nutrition_model.dart';

class NutritionFormScreen extends StatefulWidget {
  const NutritionFormScreen({super.key});

  @override
  _NutritionFormScreenState createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  late NutritionController _controller;

  @override
  void initState() {
    super.initState();
    final model = NutritionModel();
    _controller = NutritionController(model: model);
  }

  @override
  Widget build(BuildContext context) {
    final questions = _controller.getQuestions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Nutrición'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white, 
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personaliza tus recomendaciones",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Proporciona tu información nutricional para recibir recetas y consejos adaptados a tus necesidades",
                      style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
                    ),
                    const SizedBox(height: 20),
                    ...questions.map((q) => _buildMultiSelect(q)).toList(),
                    const SizedBox(height: 20),
                    _buildConfirmButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMultiSelect(NutritionQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0, 
          children: question.options.map((option) {
            final isSelected = question.selected.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    question.selected.add(option);
                  } else {
                    question.selected.remove(option);
                  }
                  _controller.updateSelectedOptions(question, question.selected);
                });
              },
              selectedColor: Color(0xFF129575),
              backgroundColor: isSelected ? Color(0xFF129575) : Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/dashboard');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Crear Cuenta",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 11),
            const Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}