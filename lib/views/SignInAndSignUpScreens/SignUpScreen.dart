import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../controllers/signup_controller.dart';
import '../../controllers/nutrition_controller.dart';
import '../../controllers/ingredient_controller.dart';
import '../../models/user_model.dart';
import '../../models/nutrition_model.dart';
import '../../services/api_service_profile.dart'; // Import the ApiService

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isFirstNameValid = true;
  bool _isLastNameValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isEmailValid = true;
  bool _canContinue = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _emailError;

  bool _isSignUpScreen = true; // Flag to switch between screens
  late SignUpController _signUpController;
  late NutritionController _nutritionController;
  int _currentQuestionIndex = 0;
  String _searchQuery = '';
  int _ingredientsToShow = 10;

  @override
  void initState() {
    super.initState();
    final userModel = UserModel(
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      roleId: 0,
      keycloakUserId: 0,
      forbiddenFoods: [],
      imageUrl: '',
      description: '',
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
      followers: [],
      following: [],
      savedRecipes: [],
      publishedRecipes: [],
      shoppingListRecipes: [],
    );
    _signUpController = SignUpController(userModel: userModel, apiService: ApiService()); // Pass the ApiService instance

    final ingredientController = IngredientController();
    final sortedIngredients = ingredientController.getAllIngredientNames()..sort();
    final nutritionModel = NutritionModel(sortedIngredients);
    _nutritionController = NutritionController(model: nutritionModel);
  }

  void _validateForm() {
    final fullName = _firstNameController.text;
    final alias = _lastNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _firstNameError = _signUpController.validateFullName(fullName);
      _isFirstNameValid = _firstNameError == null;

      _lastNameError = _signUpController.validate(alias);
      _isLastNameValid = _lastNameError == null;

      _emailError = _signUpController.validateEmail(email);
      _isEmailValid = _emailError == null;

      _passwordError = _signUpController.validatePassword(password);
      _isPasswordValid = _passwordError == null;

      _confirmPasswordError = _signUpController.validateConfirmPassword(password, confirmPassword);
      _isConfirmPasswordValid = _confirmPasswordError == null;

      _canContinue = _signUpController.canContinue(fullName, email, alias, password, confirmPassword);
    });
  }

Future<void> _createAccount() async {
    // Update user model with values from the form
    _signUpController.userModel.firstName = _firstNameController.text;
    _signUpController.userModel.lastName = _lastNameController.text;
    _signUpController.userModel.email = _emailController.text;

    final success = await _signUpController.registerUser();
    if (success) {
      // Navigate to the next screen or show success message
      Navigator.pushNamed(context, '/login');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create account')),
      );
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUpScreen ? 'Creación de Cuenta' : 'Formulario de Nutrición'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isSignUpScreen ? _buildSignUpScreen(context) : _buildNutritionFormScreen(context),
    );
  }

  Widget _buildSignUpScreen(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Crear una Cuenta",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Permítanos ayudarle con la creación de su cuenta, no le llevará mucho tiempo.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 20),
              _buildUsersFirstNameInput(),
              _buildUsersLastNameInput(),
              _buildEmailInput(),
              _buildPasswordInput(),
              _buildConfirmPasswordInput(),
              _buildLoginButton(context),
              const SizedBox(height: 30),
              _buildSignUpWith(context),
              _buildRegisterPrompt(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersFirstNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nombres Completo",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(
            hintText: "Escribe tus nombres completos",
            errorText: _firstNameError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateForm(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildUsersLastNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Escribe tus apellidos completos",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _lastNameController,
          decoration: InputDecoration(
            hintText: "Escribe tu apellido",
            errorText: _lastNameError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateForm(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Correo Electrónico",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Escribe tu correo electrónico",
            errorText: _emailError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
          onChanged: (value) => _validateForm(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contraseña",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _passwordController,
          obscureText: true,
          onChanged: (value) => _validateForm(),
          decoration: InputDecoration(
            hintText: "Escribe tu contraseña",
            errorText: _passwordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildConfirmPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirma Contraseña",
          style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          onChanged: (value) => _validateForm(),
          decoration: InputDecoration(
            hintText: "Escribe nuevamente tu contraseña",
            errorText: _confirmPasswordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD9D9D9),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: _canContinue
            ? () {
                setState(() {
                  _isSignUpScreen = false; // Switch to the nutrition form screen
                });
              }
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Continuar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 11),
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

  // Builds the "Sign Up with" section
  Widget _buildSignUpWith(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Flexible(
                child: Divider(
                  color: Color(0xFFD9D9D9),
                  thickness: 1,
                  endIndent: 12,
                ),
              ),
              Text(
                "O crear cuenta mediante",
                style: TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Flexible(
                child: Divider(
                  color: Color(0xFFD9D9D9),
                  thickness: 1,
                  indent: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(  // Row to display icons together
            mainAxisSize: MainAxisSize.min,
            children: [
              // Google Icon with GestureDetector
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUpScreen = false; // Switch to the nutrition form screen
                  });
                },
                child: Image.asset(
                  'assets/icons/googleIcon.png',
                  width: 55,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20),  // Space between the icons
              // Facebook Icon with GestureDetector
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUpScreen = false; // Switch to the nutrition form screen
                  });
                },
                child: Image.asset(
                  'assets/icons/facebookIcon.png', 
                  width: 55,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15), // Space between email field and next widget
        ],
      ),
    );
  }

  // Builds the register prompt text
  Widget _buildRegisterPrompt(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "¿Ya estás registrado? ",
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: "Inicia Sesión aquí",
              style: const TextStyle(color: Color(0xFFFF9C00)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Redirects to the "create account" screen
                  Navigator.pushNamed(context, '/login');
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionFormScreen(BuildContext context) {
    final questions = _nutritionController.getQuestions();
    final currentQuestion = questions[_currentQuestionIndex];

    return Container(
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
                    "Los alimentos restringidos son aquellos alimentos que por temas de alergias, intolerancia, temas de dieta, el usuario no puede comer.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF121212)),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildCheckboxList(currentQuestion),
                  const SizedBox(height: 20),
                  _buildLoadMoreButton(currentQuestion),
                  const SizedBox(height: 20),
                  _buildNavigationButtons(context, questions.length),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _ingredientsToShow = 10;
        });
      },
      decoration: InputDecoration(
        labelText: 'Buscar alimentos',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildCheckboxList(NutritionQuestion question) {
    final filteredOptions = question.options
        .where((option) => option.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
        .take(_ingredientsToShow)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
        ),
        const SizedBox(height: 5),
        ...filteredOptions.map((option) {
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
                _nutritionController.updateSelectedOptions(question, question.selected);
              });
            },
            activeColor: const Color(0xFF129575),
            checkColor: Colors.white,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoadMoreButton(NutritionQuestion question) {
    final filteredOptions = question.options
        .where((option) => option.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
    if (_ingredientsToShow >= filteredOptions.length) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF129575),
        ),
        onPressed: () {
          setState(() {
            _ingredientsToShow += 10;
          });
        },
        child: const Text(
          'Cargar más',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
                    _createAccount(); // Call the function to create account
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