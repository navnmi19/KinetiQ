import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gym_app/screens/onboarding/basic_info_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BasicInfoScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1FAE5),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.fitness_center,
                size: 90,
                color: Color(0xFF22C55E),
              ),

              const SizedBox(height: 20),

              const Text(
                "WORKOUT",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Discipline today, strength tomorrow.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 50),

              Lottie.asset(
                'assets/animations/pushup.lottie',
                width: 150,
                height: 150,
                repeat: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}