import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws an Apple-Fitness-style progress ring, optionally with a thinner
/// secondary ring nested inside it (used to show a second metric, e.g.
/// calories, alongside the primary one, e.g. steps).
class StepRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;
  final double? secondaryProgress;

  const StepRingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
    this.secondaryProgress,
  });

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double stroke,
    double value,
    Color color,
  ) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * math.pi * value.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = (size.shortestSide - strokeWidth) / 2;
    _drawRing(canvas, center, outerRadius, strokeWidth, progress, ringColor);

    if (secondaryProgress != null) {
      final innerStroke = strokeWidth * 0.55;
      final innerRadius = outerRadius - strokeWidth / 2 - innerStroke / 2 - 6;
      _drawRing(
        canvas,
        center,
        innerRadius,
        innerStroke,
        secondaryProgress!,
        ringColor.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StepRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.secondaryProgress != secondaryProgress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}
