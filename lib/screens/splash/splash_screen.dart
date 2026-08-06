import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gym_app/screens/onboarding/basic_info_screen.dart';
import 'package:gym_app/widgets/background_decoration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color mint50 = Color(0xFFD1FAE5);
  static const Color mint25 = Color(0xFFECFDF5);
  static const Color green = Color(0xFF22C55E);
  static const Color darkText = Color(0xFF14532D);

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;
        _goToBasicInfo();
      },
    );
  }

  void _goToBasicInfo() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BasicInfoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mint50, mint25, Colors.white],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const BackgroundDecorations(),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "WELCOME TO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: darkText.withValues(alpha: 0.5),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.fitness_center, color: green, size: 34),
                        SizedBox(width: 10),
                        Text(
                          "GYMIN",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: "Stronger ",
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: "every day."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Lottie.asset(
                      'assets/animations/pushup.lottie',
                      width: 150,
                      height: 150,
                      repeat: true,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: green.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Preparing your experience...",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: darkText.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}