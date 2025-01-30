import 'package:flutter/material.dart'; 

class NutritionFormScreen extends StatefulWidget {
  const NutritionFormScreen({super.key});

  @override
  _NutritionFormScreenState createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  // Variables to save the selected options
  String? selectedDiet;
  String? selectedAllergy;
  String? selectedIntolerance;
  String? selectedEatingHabit;
  String? selectedCookingPreference;
  String? selectedHealthGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Nutrición'), backgroundColor: const Color(0xFF129575)),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(30, 14, 30, 8), 
        margin: EdgeInsets.zero, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            const Text(
              "Personaliza tus recomendaciones",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(flex: 15),
            const Text(
              "Proporciona tu información nutricional para recibir recetas y consejos adaptados a tus necesidades",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF121212),
              ),
            ),
            const Spacer(flex: 20),
            _buildDietInput(),
            _buildAllergiesInput(),
            _buildFoodIntoleranceInput(),
            _buildEatingHabitsInput(),
            _buildLikesCookingInput(),
            _buildHealthGoalsInput(),
            _buildConfirmButton(context),
            const SizedBox(height: 30),
            const Spacer(flex: 50),
            Center(
              child: Container(
                width: 135,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Builds the Diets input field with a dropdown
  Widget _buildDietInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Qué tipo de dieta sigues?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF121212)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    hint: const Text("   Selecciona tu tipo de dieta"),
                    value: selectedDiet,
                    isExpanded: true,
                    items: [
                      "Vegetariana",
                      "Vegana",
                      "Omnívora",
                      "Keto",
                      "Paleo",
                      "No tengo preferencias"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDiet = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space
      ],
    );
  }

  // Builds the Allergies input field with a dropdown
  Widget _buildAllergiesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Tienes alguna alergia alimenticia?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF121212)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    hint: const Text("   Selecciona tus alergias"),
                    value: selectedAllergy,
                    isExpanded: true,
                    items: [
                      "Frutos Secos",
                      "Gluten",
                      "Lácteos",
                      "Mariscos",
                      "Ninguna"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAllergy = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space
      ],
    );
  }

  // Builds the Food Intolerance input field with a dropdown
  Widget _buildFoodIntoleranceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Tienes alguna intolerancia alimenticia?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF121212)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    hint: const Text("   Selecciona tus intolerancias"),
                    value: selectedIntolerance,
                    isExpanded: true,
                    items: [
                      "Lactosa",
                      "Gluten",
                      "Ninguna"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedIntolerance = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space
      ],
    );
  }

  // Builds the Eating Habits input field with a dropdown
  Widget _buildEatingHabitsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Cuáles son tus hábitos alimenticios?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF121212)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    hint: const Text("   Selecciona tus hábitos alimenticios"),
                    value: selectedEatingHabit,
                    isExpanded: true,
                    items: [
                      "Desayuno Diario",
                      "Comida Rápida Ocasional",
                      "Ninguno en específico"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedEatingHabit = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space
      ],
    );
  }

  // Builds the Cooking's likes input field with a dropdown
  Widget _buildLikesCookingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Qué tipo de cocina prefieres?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF121212)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    hint: const Text("   Selecciona tu tipo de cocina"),
                    value: selectedCookingPreference,
                    isExpanded: true,
                    items: [
                      "Mediterránea",
                      "Asiática",
                      "Mexicana",
                      "Italiana",
                      "Ninguna en específico"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCookingPreference = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space
      ],
    );
  }

  // Builds the Health Goals input field with a dropdown
  Widget _buildHealthGoalsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Cuáles son tus objetivos de salud?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF121212)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    hint: const Text("   Selecciona tus objetivos de salud"),
                    value: selectedHealthGoal,
                    isExpanded: true,
                    items: [
                      "Pérdida de Peso",
                      "Ganancia Muscular",
                      "Ninguno"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHealthGoal = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Space
      ],
    );
  }

   // Builds the confirm button
  Widget _buildConfirmButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575), // Custom color
        ),
        onPressed: () {
          // Redirects to the main screen (Dashboard)
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
            Icon(  // Uses an Icon instead of an asset
              Icons.arrow_forward,  // Forward arrow
              size: 20,  // Icon size
              color: Colors.white,  // Icon color (adjustable)
            ),
          ],
        ),
      ),
    );
  }
}