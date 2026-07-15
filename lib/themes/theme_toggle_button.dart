import 'package:flutter/material.dart';
import 'theme_controller.dart';
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDarkMode = mode == ThemeMode.dark;
        final accent = isDarkMode ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);

        return GestureDetector(
          onTap: () => ThemeController.toggle(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            width: 60,
            height: 32,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              // NOTE: light-mode color was cut off in your screenshot —
              // double check this hex matches your original exactly.
              color: isDarkMode ? const Color(0xFF2A2A2D) : const Color(0xfffeff6f0),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                  alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Opacity(
                          opacity: isDarkMode ? 1 : 0,
                          child: const Text('☀️', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Opacity(
                          opacity: isDarkMode ? 0 : 1,
                          child: const Text('🌙', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}