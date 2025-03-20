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
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    final model = NutritionModel();
    _controller = NutritionController(model: model);
  }

  @override
  Widget build(BuildContext context) {
    final questions = _controller.getQuestions();
    final currentQuestion = questions[_currentQuestionIndex];

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
                    _buildCheckboxList(currentQuestion),
                    const SizedBox(height: 20),
                    _buildNavigationButtons(context, questions.length),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckboxList(NutritionQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        ...question.options.map((option) {
          final isSelected = question.selected.contains(option);
          return CheckboxListTile(
            title: Text(option),
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  question.selected.add(option);
                } else {
                  question.selected.remove(option);
                }
                _controller.updateSelectedOptions(question, question.selected);
              });
            },
            activeColor: const Color(0xFF129575),
            checkColor: Colors.white,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, int totalQuestions) {
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    final isFirstQuestion = _currentQuestionIndex == 0;

    return LayoutBuilder(
  builder: (context, constraints) {
    // Ancho máximo disponible para los botones
    double availableWidth = constraints.maxWidth;

    // Definición los anchos base de los botones
    double mainButtonWidth = isLastQuestion ? 180 : 150;
    double backButtonWidth = 150;
    double spacing = 40;

    // Calcular si hay suficiente espacio para ambos botones con el espaciado
    double totalRequiredWidth = mainButtonWidth + backButtonWidth + spacing;
    if (totalRequiredWidth > availableWidth) {
      // Ajustar el ancho del botón "Atrás" si es necesario
      double excess = totalRequiredWidth - availableWidth;
      backButtonWidth = (backButtonWidth - excess).clamp(80, 150); // No menor de 80
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isFirstQuestion) ...[
            SizedBox(
              width: backButtonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex--;
                  });
                },
                child: const Text(
                  "Atrás",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
          ] else ...[
            // Espacio vacío simula la posición del botón "Atrás"
            SizedBox(width: backButtonWidth + spacing),
          ],
          SizedBox(
            width: mainButtonWidth,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: const Color(0xFF129575),
              ),
              onPressed: () {
                if (isLastQuestion) {
                  Navigator.pushNamed(context, '/dashboard');
                } else {
                  setState(() {
                    _currentQuestionIndex++;
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastQuestion ? "Crear Cuenta" : "Siguiente",
                    style: const TextStyle(
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
                  )
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
  }
}