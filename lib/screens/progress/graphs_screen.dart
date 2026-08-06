import 'package:flutter/material.dart';
import 'package:gym_app/themes/theme_controller.dart';
import 'package:gym_app/models/friend_model.dart';
import 'package:gym_app/screens/social/friends_controller.dart';

/// Dedicated "only graphs" screen — reached by tapping an AI Insight card
/// on either the Dashboard or the Progress screen. Two modes: Personal
/// (metric + Daily/Weekly/Monthly) and Social (metric + granularity +
/// friend picker). Daily granularity always renders two comparison lines;
/// Weekly/Monthly are single-line aggregate views.
class GraphsScreen extends StatefulWidget {
  const GraphsScreen({super.key});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  bool get isDarkMode => ThemeController.mode.value == ThemeMode.dark;

  bool _isSocial = false;
  String _selectedMetric = "Workout Volume";
  String _selectedGranularity = "Daily";
  late Friend? _selectedFriend =
      FriendsController.myFriends.isNotEmpty ? FriendsController.myFriends.first : null;

  static const List<String> _metrics = [
    "Workout Volume",
    "Calories",
    "Strength",
    "Steps",
  ];
  static const List<String> _granularities = ["Daily", "Weekly", "Monthly"];

  static const List<String> _dailyLabels = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
  ];
  static const List<String> _weeklyLabels = ["Week 1", "Week 2", "Week 3", "Week 4"];
  static const List<String> _monthlyLabels = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  ];

  static const Map<String, List<double>> _myDaily = {
    "Workout Volume": [6200, 6800, 5200, 5900, 7120, 8450],
    "Calories": [2400, 2600, 2100, 2050, 2550, 2700],
    "Strength": [62, 64, 65, 63, 67, 70],
    "Steps": [8200, 9100, 6400, 5800, 9600, 10200],
  };

  List<double> get _myWeeklySeries {
    final daily = _myDaily[_selectedMetric]!;
    final avg = daily.reduce((a, b) => a + b) / daily.length;
    return [avg * 0.85, avg * 0.95, avg * 1.05, avg * 1.15];
  }

  List<double> get _myMonthlySeries {
    final daily = _myDaily[_selectedMetric]!;
    final avg = daily.reduce((a, b) => a + b) / daily.length;
    return List.generate(6, (i) => avg * (0.8 + i * 0.08));
  }

  List<double> get _primarySeries {
    switch (_selectedGranularity) {
      case "Weekly":
        return _myWeeklySeries;
      case "Monthly":
        return _myMonthlySeries;
      default:
        return _myDaily[_selectedMetric]!;
    }
  }

  List<String> get _currentLabels {
    switch (_selectedGranularity) {
      case "Weekly":
        return _weeklyLabels;
      case "Monthly":
        return _monthlyLabels;
      default:
        return _dailyLabels;
    }
  }

  /// Deterministic per-friend scale so each friend's placeholder series
  /// has a distinct, plausible shape instead of mirroring "me" exactly.
  double _friendFactor(Friend friend) {
    final base = friend.workoutsCount == 0 ? 40 : friend.workoutsCount;
    return (0.7 + (base % 40) / 100).clamp(0.6, 1.3);
  }

  List<double> get _secondarySeries {
    final primary = _primarySeries;
    if (_isSocial) {
      final friend = _selectedFriend;
      final factor = friend == null ? 0.9 : _friendFactor(friend);
      return primary.map((v) => v * factor).toList();
    }
    // Personal: "yesterday"-style comparison — distinct but plausible shape.
    return primary.map((v) => v * 0.88).toList();
  }

  String get _comparisonLabel {
    if (_isSocial) return _selectedFriend?.name ?? "Friend";
    return "Yesterday";
  }

  String get _primaryLabel => _isSocial ? "Me" : "Today";

  String _formatValue(double v) {
    if (_selectedMetric == "Strength") return v.round().toString();
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bg = isDark ? Colors.black : Colors.white;
        final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final chipBg = isDark ? Colors.white10 : const Color(0xFFF3F4F6);
        final textPrimary = isDark ? Colors.white : const Color(0xFF15181D);
        final textSecondary = isDark ? Colors.white60 : const Color(0xFF6B7280);
        final accent = isDark ? const Color(0xFFFF7A1A) : const Color(0xFF22C55E);
        final divider = isDark ? Colors.white12 : const Color(0xFFEFEFEF);

        final showDualLine = _selectedGranularity == "Daily";
        final series = _primarySeries;
        final labels = _currentLabels;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textPrimary),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          "Graphs",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal / Social mode toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _modeSegment(
                                  "Personal",
                                  !_isSocial,
                                  accent,
                                  textSecondary,
                                  () => setState(() => _isSocial = false),
                                ),
                              ),
                              Expanded(
                                child: _modeSegment(
                                  "Social",
                                  _isSocial,
                                  accent,
                                  textSecondary,
                                  () => setState(() => _isSocial = true),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _dropdownChip(
                              value: _selectedMetric,
                              options: _metrics,
                              chipBg: chipBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onChanged: (v) => setState(() => _selectedMetric = v),
                            ),
                            _dropdownChip(
                              value: _selectedGranularity,
                              options: _granularities,
                              chipBg: chipBg,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onChanged: (v) => setState(() => _selectedGranularity = v),
                            ),
                            if (_isSocial)
                              _friendChip(
                                chipBg: chipBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                accent: accent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDualLine)
                                Row(
                                  children: [
                                    _legendDash(accent, false, _primaryLabel, textPrimary),
                                    const SizedBox(width: 16),
                                    _legendDash(
                                      accent.withValues(alpha: 0.55),
                                      true,
                                      _comparisonLabel,
                                      textPrimary,
                                    ),
                                  ],
                                ),
                              if (showDualLine) const SizedBox(height: 14),
                              SizedBox(
                                height: 220,
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey(
                                    "$_selectedMetric-$_selectedGranularity-$_isSocial-${_selectedFriend?.id}",
                                  ),
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, progress, _) {
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        return CustomPaint(
                                          size: Size(constraints.maxWidth, constraints.maxHeight),
                                          painter: _GraphSplinePainter(
                                            values: series,
                                            secondaryValues: showDualLine ? _secondarySeries : null,
                                            valueLabels: series.map(_formatValue).toList(),
                                            progress: progress,
                                            lineColor: accent,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: labels
                                    .map(
                                      (l) => Expanded(
                                        child: Text(
                                          l,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11, color: textSecondary),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              if (!showDualLine) ...[
                                const SizedBox(height: 12),
                                Divider(color: divider, height: 1),
                                const SizedBox(height: 8),
                                Text(
                                  "Aggregate view — day-by-day comparison is only available on Daily.",
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ],
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
      },
    );
  }

  Widget _modeSegment(
    String label,
    bool selected,
    Color accent,
    Color textSecondary,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _dropdownChip({
    required String value,
    required List<String> options,
    required Color chipBg,
    required Color textPrimary,
    required Color textSecondary,
    required ValueChanged<String> onChanged,
  }) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: chipBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => options
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              child: Text(o, style: TextStyle(color: textPrimary, fontSize: 14)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textPrimary),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _friendChip({
    required Color chipBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
  }) {
    final friends = FriendsController.myFriends;
    if (friends.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(12)),
        child: Text("No friends yet", style: TextStyle(fontSize: 12.5, color: textSecondary)),
      );
    }
    return PopupMenuButton<Friend>(
      initialValue: _selectedFriend,
      onSelected: (f) => setState(() => _selectedFriend = f),
      color: chipBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => friends
          .map(
            (f) => PopupMenuItem<Friend>(
              value: f,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: f.color.withValues(alpha: 0.15),
                    child: Icon(f.icon, size: 13, color: f.color),
                  ),
                  const SizedBox(width: 8),
                  Text(f.name, style: TextStyle(color: textPrimary, fontSize: 14)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded, size: 14, color: accent),
            const SizedBox(width: 6),
            Text(
              _selectedFriend?.name ?? "Pick a friend",
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textPrimary),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _legendDash(Color color, bool dashed, String label, Color textPrimary) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 3,
          child: dashed
              ? CustomPaint(painter: _GraphDashPainter(color: color))
              : DecoratedBox(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ],
    );
  }
}

class _GraphDashPainter extends CustomPainter {
  final Color color;
  const _GraphDashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 3.5, size.height / 2), paint);
      x += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _GraphDashPainter oldDelegate) => false;
}

/// Standalone spline painter for this screen (dashboard's own painter is
/// private to dashboard_screen.dart) — same shared-scale two-line +
/// on-chart-label approach.
class _GraphSplinePainter extends CustomPainter {
  final List<double> values;
  final List<double>? secondaryValues;
  final List<String>? valueLabels;
  final double progress;
  final Color lineColor;

  _GraphSplinePainter({
    required this.values,
    required this.progress,
    required this.lineColor,
    this.secondaryValues,
    this.valueLabels,
  });

  Offset _point(int i, Size size, List<double> vals, double minVal, double range) {
    final dx = size.width / (vals.length - 1);
    final normalized = (vals[i] - minVal) / range;
    final y = size.height - (normalized * size.height * 0.75) - size.height * 0.12;
    return Offset(dx * i, y);
  }

  Path _spline(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i + 2 < points.length) ? points[i + 2] : p2;
      final cp1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final cp2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  Path _reveal(Path source) {
    final revealPath = Path();
    for (final metric in source.computeMetrics()) {
      revealPath.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
    }
    return revealPath;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final hasSecondary = secondaryValues != null && secondaryValues!.length == values.length;
    final allValues = [...values, if (hasSecondary) ...secondaryValues!];
    final maxVal = allValues.reduce((a, b) => a > b ? a : b);
    final minVal = allValues.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = List.generate(values.length, (i) => _point(i, size, values, minVal, range));
    final revealPath = _reveal(_spline(points));

    final fillMetrics = revealPath.computeMetrics().toList();
    if (fillMetrics.isNotEmpty) {
      final fillPath = Path.from(revealPath);
      final lastMetric = fillMetrics.last;
      final tangent = lastMetric.getTangentForOffset(lastMetric.length);
      final lastPoint = tangent?.position ?? points.last;
      fillPath.lineTo(lastPoint.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withValues(alpha: 0.22), lineColor.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(
      revealPath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (hasSecondary) {
      final secondaryPoints = List.generate(
        secondaryValues!.length,
        (i) => _point(i, size, secondaryValues!, minVal, range),
      );
      final secondaryReveal = _reveal(_spline(secondaryPoints));
      final dashPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.55)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (final metric in secondaryReveal.computeMetrics()) {
        double distance = 0;
        while (distance < metric.length) {
          final next = distance + 5;
          canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), dashPaint);
          distance = next + 6;
        }
      }
    }

    if (valueLabels != null && progress > 0.85) {
      for (int i = 0; i < points.length && i < valueLabels!.length; i++) {
        final tp = TextPainter(
          text: TextSpan(
            text: valueLabels![i],
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: lineColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final offset = Offset(
          (points[i].dx - tp.width / 2).clamp(0.0, size.width - tp.width),
          (points[i].dy - tp.height - 8).clamp(0.0, size.height - tp.height),
        );
        tp.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraphSplinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.progress != progress ||
        oldDelegate.secondaryValues != secondaryValues ||
        oldDelegate.valueLabels != valueLabels ||
        oldDelegate.lineColor != lineColor;
  }
}
