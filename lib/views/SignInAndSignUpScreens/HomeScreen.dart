import 'package:flutter/material.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final Stopwatch _stopwatch = Stopwatch();
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/icons/backgroundLanding2.png'), context);
    precacheImage(AssetImage('assets/icons/chefIcon.png'), context);
    precacheImage(AssetImage('assets/icons/arrow.png'), context);
    _stopwatch.start();
  }

  void _navigateToLogin() async {
    setState(() {
      _isLoading = true;
    });

    await Navigator.pushReplacementNamed(context, '/login');

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        print('⏱ HomeScreen: ${_stopwatch.elapsedMilliseconds} ms');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/backgroundLanding2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 292),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/chefIcon.png',
                            width: 110,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Amantes de la cocina y principiantes sean bienvenidos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 200),
                    const Text(
                      'KitchenMate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '¡Descubre el chef que llevas\ndentro!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _navigateToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isLoading ? Colors.grey : const Color(0xFF129575),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Empieza tus recetas',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Image.asset(
                                  'assets/icons/arrow.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: screenWidth / 2 - 67.5,
            child: Container(
              width: 135,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
