import 'package:flutter/material.dart';

/// Front/back muscle-group body diagram. Each muscle group is its own
/// non-overlapping shape (deliberately spaced with gaps in the coordinate
/// layout below) so it can be colored independently with zero risk of one
/// region's color bleeding into a neighbor's — the requirement this widget
/// was built to satisfy precisely.
///
/// Design canvas is a fixed 140x300 unit space; the widget scales it to
/// whatever size it's given via [AspectRatio], so the hand-placed
/// coordinates below always stay proportionally correct.
enum MuscleMapView { front, back }

class MuscleMapWidget extends StatelessWidget {
  final MuscleMapView view;
  final Map<String, double> intensities;
  final Color neutralColor;

  const MuscleMapWidget({
    super.key,
    required this.view,
    required this.intensities,
    required this.neutralColor,
  });

  static const double designWidth = 140;
  static const double designHeight = 300;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: designWidth / designHeight,
      child: CustomPaint(
        size: const Size(designWidth, designHeight),
        painter: _MuscleMapPainter(
          view: view,
          intensities: intensities,
          neutralColor: neutralColor,
        ),
      ),
    );
  }
}

/// Heat scale: gray (untargeted) then Blue → Violet → Orange → Red as
/// training intensity rises from low to high.
Color muscleHeatColor(double intensity, Color neutralColor) {
  if (intensity <= 0.001) return neutralColor;
  const stops = [
    Color(0xFF3B82F6), // blue — least
    Color(0xFF8B5CF6), // violet
    Color(0xFFFB923C), // orange
    Color(0xFFEF4444), // red — most
  ];
  final scaled = intensity.clamp(0.0, 1.0) * (stops.length - 1);
  final index = scaled.floor().clamp(0, stops.length - 2);
  final localT = scaled - index;
  return Color.lerp(stops[index], stops[index + 1], localT)!;
}

class _MuscleShape {
  final String group;
  final Rect rect;
  final double radius;

  const _MuscleShape({
    required this.group,
    required this.rect,
    this.radius = 8,
  });
}

// ---------------------------------------------------------------------
// Layout — every shape below was placed with an explicit gap from its
// neighbors (verified by hand): adjacent regions never share both an x
// and a y range, so no two shapes can paint the same pixel.
// ---------------------------------------------------------------------

const List<_MuscleShape> _frontShapes = [
  _MuscleShape(group: 'Shoulders', rect: Rect.fromLTWH(16, 48, 30, 18), radius: 10),
  _MuscleShape(group: 'Shoulders', rect: Rect.fromLTWH(94, 48, 30, 18), radius: 10),
  _MuscleShape(group: 'Chest', rect: Rect.fromLTWH(50, 48, 40, 42), radius: 10),
  _MuscleShape(group: 'Biceps', rect: Rect.fromLTWH(14, 68, 20, 102), radius: 8),
  _MuscleShape(group: 'Biceps', rect: Rect.fromLTWH(106, 68, 20, 102), radius: 8),
  _MuscleShape(group: 'Abs', rect: Rect.fromLTWH(50, 92, 40, 68), radius: 10),
  _MuscleShape(group: 'Quads', rect: Rect.fromLTWH(42, 172, 24, 56), radius: 8),
  _MuscleShape(group: 'Quads', rect: Rect.fromLTWH(74, 172, 24, 56), radius: 8),
  _MuscleShape(group: 'Calves', rect: Rect.fromLTWH(44, 232, 20, 58), radius: 8),
  _MuscleShape(group: 'Calves', rect: Rect.fromLTWH(76, 232, 20, 58), radius: 8),
];

const List<_MuscleShape> _backShapes = [
  _MuscleShape(group: 'Shoulders', rect: Rect.fromLTWH(16, 48, 30, 18), radius: 10),
  _MuscleShape(group: 'Shoulders', rect: Rect.fromLTWH(94, 48, 30, 18), radius: 10),
  _MuscleShape(group: 'Traps', rect: Rect.fromLTWH(50, 48, 40, 20), radius: 10),
  _MuscleShape(group: 'Triceps', rect: Rect.fromLTWH(14, 68, 20, 102), radius: 8),
  _MuscleShape(group: 'Triceps', rect: Rect.fromLTWH(106, 68, 20, 102), radius: 8),
  _MuscleShape(group: 'Lats', rect: Rect.fromLTWH(36, 70, 14, 56), radius: 8),
  _MuscleShape(group: 'Lats', rect: Rect.fromLTWH(90, 70, 14, 56), radius: 8),
  _MuscleShape(group: 'Lower Back', rect: Rect.fromLTWH(52, 128, 36, 32), radius: 8),
  _MuscleShape(group: 'Glutes', rect: Rect.fromLTWH(44, 162, 22, 34), radius: 8),
  _MuscleShape(group: 'Glutes', rect: Rect.fromLTWH(74, 162, 22, 34), radius: 8),
  _MuscleShape(group: 'Hamstrings', rect: Rect.fromLTWH(44, 198, 22, 30), radius: 8),
  _MuscleShape(group: 'Hamstrings', rect: Rect.fromLTWH(74, 198, 22, 30), radius: 8),
  _MuscleShape(group: 'Calves', rect: Rect.fromLTWH(44, 232, 20, 58), radius: 8),
  _MuscleShape(group: 'Calves', rect: Rect.fromLTWH(76, 232, 20, 58), radius: 8),
];

class _MuscleMapPainter extends CustomPainter {
  final MuscleMapView view;
  final Map<String, double> intensities;
  final Color neutralColor;

  const _MuscleMapPainter({
    required this.view,
    required this.intensities,
    required this.neutralColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Head + neck — plain body silhouette, always neutral.
    final silhouettePaint = Paint()..color = neutralColor.withValues(alpha: 0.55);
    canvas.drawCircle(const Offset(70, 22), 16, silhouettePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(62, 39, 16, 7), const Radius.circular(3)),
      silhouettePaint,
    );

    final shapes = view == MuscleMapView.front ? _frontShapes : _backShapes;
    for (final shape in shapes) {
      final intensity = intensities[shape.group] ?? 0.0;
      final paint = Paint()..color = muscleHeatColor(intensity, neutralColor);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shape.rect, Radius.circular(shape.radius)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MuscleMapPainter oldDelegate) {
    return oldDelegate.view != view ||
        oldDelegate.intensities != intensities ||
        oldDelegate.neutralColor != neutralColor;
  }
}
