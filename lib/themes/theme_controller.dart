import 'package:flutter/material.dart';

/// Simple global dark mode switch.
/// Add `themeMode: ThemeController.mode.value` to your MaterialApp,
/// wrapped in a ValueListenableBuilder (see snippet below), so the
/// whole app rebuilds when this changes.
///
/// If you already have a theme toggle on the Dashboard, point it at
/// ThemeController.toggle() too, so there's only one source of truth.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

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