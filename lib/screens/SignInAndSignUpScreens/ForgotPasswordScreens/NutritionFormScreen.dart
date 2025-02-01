import 'package:flutter/material.dart';

class NutritionFormScreen extends StatefulWidget {
  const NutritionFormScreen({super.key});

  @override
  _NutritionFormScreenState createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  // Lista de preguntas y opciones
  final List<Map<String, dynamic>> questions = [
    {
      "question": "¿Qué tipo de dieta sigues?",
      "options": ["Vegetariana", "Vegana", "Omnívora", "Keto", "Paleo", "No tengo preferencias"],
      "selected": null,
    },
    {
      "question": "¿Tienes alguna alergia alimenticia?",
      "options": ["Frutos Secos", "Gluten", "Lácteos", "Mariscos", "Ninguna"],
      "selected": null,
    },
    {
      "question": "¿Tienes alguna intolerancia alimentaria?",
      "options": ["Lactosa", "Gluten", "Ninguna"],
      "selected": null,
    },
    {
      "question": "¿Cuáles son tus hábitos alimenticios?",
      "options": ["Desayuno Diario", "Comida rápida Ocasional", "Balanceado", "Ninguno en específico"],
      "selected": null,
    },
    {
      "question": "¿Qué tipo de cocina prefieres?",
      "options": ["Meditarránea", "Asiática", "Mexicana", "Italiana", "Ninguna en específico"],
      "selected": null,
    },
    {
      "question": "¿Cuáles son tus objetivos de salud?",
      "options": ["Pérdida peso", "Ganancia Muscular", "Mantenerme saludable", "Ninguno en específico"],
      "selected": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    ...questions.map((q) => _buildDropdown(q)).toList(),
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

  Widget _buildDropdown(Map<String, dynamic> questionData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionData["question"],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: questionData["selected"],
          hint: const Text("Selecciona una opción"),
          isExpanded: true,
          items: (questionData["options"] as List<String>).map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              questionData["selected"] = value;
            });
          },
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
