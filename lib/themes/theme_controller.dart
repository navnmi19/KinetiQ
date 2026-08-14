import 'package:flutter/material.dart';


class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static void toggle() {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/*
Wire it into your MaterialApp like this:

ValueListenableBuilder<ThemeMode>(
  valueListenable: ThemeController.mode,
  builder: (context, mode, _) {
    return MaterialApp(
      themeMode: mode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const DashboardScreen(),
    );
  },
)
*/