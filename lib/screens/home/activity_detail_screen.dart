import 'package:flutter/material.dart';
import 'package:gym_app/themes/theme_controller.dart';
import 'package:gym_app/widgets/background_decoration.dart';
import 'package:gym_app/widgets/step_ring_painter.dart';
import 'activity_history_screen.dart';

/// Full-screen activity breakdown, reached by tapping the "Steps Today"
/// card on the dashboard. Tapping the ring itself drills further into
/// [ActivityHistoryScreen]. All data below is placeholder — there's no
/// backend/device sensor feed yet (see CLAUDE.md).
class ActivityDetailScreen extends StatelessWidget {
  final int stepsCompleted;
  final int stepTarget;
  final int caloriesBurned;
  final int calorieGoal;

  const ActivityDetailScreen({
    super.key,
    required this.stepsCompleted,
    required this.stepTarget,
    required this.caloriesBurned,
    required this.calorieGoal,
  });

  static const List<String> _timeBlocks = [
    '12-2 AM',
    '2-4 AM',
    '4-6 AM',
    '6-8 AM',
    '8-10 AM',
    '10-12 PM',
    '12-2 PM',
    '2-4 PM',
    '4-6 PM',
    '6-8 PM',
    '8-10 PM',
    '10 PM-12 AM',
  ];

  // Placeholder per-block breakdown — sums to stepsCompleted (6,412).
  static const List<int> _stepsByBlock = [
    0, 0, 120, 850, 640, 780, 2040, 460, 610, 700, 190, 22,
  ];

  static const List<double> _distanceByBlockKm = [
    0.0, 0.0, 0.1, 0.6, 0.5, 0.6, 1.5, 0.3, 0.5, 0.5, 0.1, 0.0,
  ];

  static const double _avgCaloriesPerDay = 480;
  static const double _avgDistancePerDayKm = 5.2;
  static const String _walkingPace = '12:30 /km';
  static const String _runningPace = '6:15 /km';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bg = isDark ? Colors.black : Colors.white;
        final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final accent = isDark
            ? const Color(0xFFFF7A1A)
            : const Color(0xFF22C55E);
        final textPrimary = isDark ? Colors.white : const Color(0xFF15181D);
        final textSecondary = isDark
            ? Colors.white60
            : const Color(0xFF6B7280);
        final divider = isDark ? Colors.white12 : const Color(0xFFEFEFEF);

        final stepProgress = (stepsCompleted / stepTarget).clamp(0.0, 1.0);
        final calorieProgress = (caloriesBurned / calorieGoal).clamp(
          0.0,
          1.0,
        );

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: IconThemeData(color: textPrimary),
            title: Text(
              'Activity Detail',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          body: Stack(
            children: [
              const BackgroundDecorations(),
              SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivityHistoryScreen(),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(200, 200),
                                  painter: StepRingPainter(
                                    progress: stepProgress,
                                    ringColor: accent,
                                    trackColor: divider,
                                    strokeWidth: 16,
                                    secondaryProgress: calorieProgress,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$stepsCompleted',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'of $stepTarget steps',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap the ring to see your activity history',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _legendItem(
                        color: accent,
                        label: 'Steps',
                        value: '$stepsCompleted / $stepTarget',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _legendItem(
                        color: accent.withValues(alpha: 0.5),
                        label: 'Calories',
                        value: '$caloriesBurned / $calorieGoal kcal',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Steps by Time of Day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StepsBarChart(
                    values: _stepsByBlock,
                    labels: _timeBlocks,
                    accent: accent,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Distance by Time of Day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DistanceLineChart(
                    values: _distanceByBlockKm,
                    labels: _timeBlocks,
                    accent: accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Averages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _statGrid(cardColor, textPrimary, textSecondary),
                ],
              ),
            ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _statGrid(Color cardColor, Color textPrimary, Color textSecondary) {
    final stats = [
      MapEntry('Avg Calories / Day', '${_avgCaloriesPerDay.toInt()} kcal'),
      const MapEntry(
        'Avg Distance / Day',
        '$_avgDistancePerDayKm km',
      ),
      const MapEntry('Walking Pace', _walkingPace),
      const MapEntry('Running Pace', _runningPace),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: stats
          .map(
            (s) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.key,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StepsBarChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final Color accent;
  final Color textSecondary;

  const _StepsBarChart({
    required this.values,
    required this.labels,
    required this.accent,
    required this.textSecondary,
  });

  static const double _maxBarHeight = 120;
  static const int _highlightThreshold = 2000;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Darker bars are windows where you walked more than '
          '$_highlightThreshold steps.',
          style: TextStyle(fontSize: 11.5, color: textSecondary, height: 1.3),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final v = values[i];
              final barHeight = (v / safeMax) * _maxBarHeight;
              final highlighted = v > _highlightThreshold;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$v',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: highlighted ? accent : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 26,
                      height: barHeight < 3 ? 3 : barHeight,
                      decoration: BoxDecoration(
                        color: highlighted
                            ? accent
                            : accent.withValues(alpha: 0.35),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 46,
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(fontSize: 9, color: textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DistanceLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  const _DistanceLineChart({
    required this.values,
    required this.labels,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const double _pointSpacing = 50;

  @override
  Widget build(BuildContext context) {
    final width = _pointSpacing * (values.length - 1) + 40;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: width,
        height: 170,
        child: CustomPaint(
          painter: _DistanceLinePainter(
            values: values,
            labels: labels,
            lineColor: accent,
            valueColor: textPrimary,
            labelColor: textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DistanceLinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final Color valueColor;
  final Color labelColor;

  _DistanceLinePainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const topPadding = 26.0;
    const bottomPadding = 34.0;
    const sidePadding = 20.0;
    final plotHeight = size.height - topPadding - bottomPadding;
    final plotWidth = size.width - sidePadding * 2;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;
    final n = values.length;

    Offset pointAt(int i) {
      final x = sidePadding + (n == 1 ? 0 : plotWidth * i / (n - 1));
      final y = topPadding + plotHeight * (1 - values[i] / safeMax);
      return Offset(x, y);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < n; i++) {
      final p = pointAt(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
        fillPath.moveTo(p.dx, size.height - bottomPadding);
        fillPath.lineTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
        fillPath.lineTo(p.dx, p.dy);
      }
    }
    fillPath.lineTo(pointAt(n - 1).dx, size.height - bottomPadding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < n; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 4, Paint()..color = lineColor);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final valueText = TextPainter(
        text: TextSpan(
          text: '${values[i].toStringAsFixed(1)} km',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valueText.paint(canvas, Offset(p.dx - valueText.width / 2, p.dy - 18));

      final labelText = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(fontSize: 8.5, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 46);
      labelText.paint(
        canvas,
        Offset(p.dx - labelText.width / 2, size.height - bottomPadding + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DistanceLinePainter oldDelegate) => true;
}
