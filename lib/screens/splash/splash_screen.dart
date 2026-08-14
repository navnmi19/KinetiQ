import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gym_app/screens/onboarding/basic_info_screen.dart';
import 'package:gym_app/widgets/background_decoration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color orange = Color(0xFFFF8A00);
  static const Color darkBackground = Color(0xFF080808);
  static const Color blackBackground = Colors.black;

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
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
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
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              blackBackground,
              darkBackground,
              blackBackground,
            ],
            stops: [
              0.0,
              0.5,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Orange workout silhouettes
            const BackgroundDecorations(),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ------------------------------------------------
                    // WELCOME TEXT
                    // ------------------------------------------------

                    Text(
                      "WELCOME TO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // KINETIQ BRAND
                    // ------------------------------------------------

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        // White dumbbell
                        Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 34,
                        ),

                        SizedBox(width: 10),

                        // Orange KinetiQ
                        Text(
                          "KinetiQ",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: orange,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------------
                    // TAGLINE
                    // ------------------------------------------------

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: "Stronger ",
                            style: TextStyle(
                              color: orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: "every day.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ------------------------------------------------
                    // KQ LOGO
                    // ------------------------------------------------

                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: SvgPicture.asset(
                          'assets/kinetiq_logo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ------------------------------------------------
                    // PROGRESS BAR
                    // ------------------------------------------------

                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor:
                              orange.withValues(alpha: 0.15),
                          valueColor:
                              const AlwaysStoppedAnimation(orange),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // LOADING TEXT
                    // ------------------------------------------------

                    Text(
                      "Preparing your experience...",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
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