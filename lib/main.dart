import 'package:flutter/material.dart';
import 'package:gym_app/screens/splash/splash_screen.dart';
import 'package:gym_app/themes/theme_controller.dart';

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Workout',
          themeMode: mode,
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          home: const SplashScreen(),
        );
      },
    );
  }
}