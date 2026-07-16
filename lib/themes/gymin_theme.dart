import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GYMIN design tokens.
/// Light: white / mint green. Dark: black (#090909) / orange (#FF8A00).
/// Read colors through `context.gymin` so every screen stays theme-aware.
class GyminColors {
  final bool isDark;
  const GyminColors(this.isDark);

  Color get bg => isDark ? const Color(0xFF090909) : Colors.white;
  Color get card => isDark ? const Color(0xFF141414) : const Color(0xFFFAFAFA);
  Color get cardAlt => isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA);
  Color get chip => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);
  Color get divider => isDark ? const Color(0xFF232323) : const Color(0xFFF0F0F0);
  Color get border => isDark ? const Color(0xFF3A3A3A) : const Color(0xFFD1D5DB);

  Color get textPrimary => isDark ? const Color(0xFFF5F5F5) : const Color(0xFF0B0B0B);
  Color get textSecondary => isDark ? const Color(0xFF9A9A9A) : const Color(0xFF6B7280);
  Color get textTertiary => isDark ? const Color(0xFF7A7A7A) : const Color(0xFF9CA3AF);

  // Accent flips: mint/green in light mode, orange in dark mode.
  Color get accent => isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);
  Color get accentSoftBg => isDark ? const Color(0xFF241708) : const Color(0xFFEAFBF1);
  Color get accentOnAccent => isDark ? Colors.white : Colors.white;

  Color get danger => const Color(0xFFEF4444);

  // Header hero gradient (light only — dark keeps flat black).
  List<Color> get heroGradient => isDark
      ? [const Color(0xFF090909), const Color(0xFF090909)]
      : [const Color(0xFFE3FBEC), const Color(0xFFF6FEF9), Colors.white];

  // The XP/insight "hero" card is always near-black with light text,
  // regardless of theme, per the original design.
  Color get heroCardBg => isDark ? const Color(0xFF1A1A1A) : const Color(0xFF0B0B0B);
  Color get heroCardText => isDark ? const Color(0xFFD4D4D4) : const Color(0xFFEDEDED);
  Color get heroCardTrack => const Color(0xFF232323);

  TextStyle heading({double size = 17, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: textPrimary);

  TextStyle body({double size = 13, FontWeight weight = FontWeight.w500, Color? color}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? textSecondary);
}

extension GyminThemeX on BuildContext {
  GyminColors get gymin => GyminColors(Theme.of(this).brightness == Brightness.dark);
}

/// Reusable rounded card used across Dashboard + Progress.
class GyminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final double radius;
  const GyminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}