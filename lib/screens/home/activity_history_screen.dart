import 'package:flutter/material.dart';
import 'package:gym_app/themes/theme_controller.dart';
import 'package:gym_app/widgets/background_decoration.dart';
import 'package:gym_app/widgets/step_ring_painter.dart';

/// Day-by-day activity log, reached by tapping the ring on
/// [ActivityDetailScreen]. Placeholder data only — no backend yet.
class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  static const int _days = 14;
  static const int _stepTarget = 8000;

  // Deterministic placeholder daily totals for the last 14 days (today last).
  static const List<int> _dailySteps = [
    5200, 8900, 6100, 9400, 4300, 7600, 8800,
    5900, 6412, 7100, 9950, 3800, 6700, 8100,
  ];

  static const List<double> _dailyDistanceKm = [
    3.6, 6.2, 4.3, 6.6, 3.0, 5.3, 6.1,
    4.1, 4.7, 5.0, 7.0, 2.7, 4.7, 5.7,
  ];

  static const List<String> _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  late final List<DateTime> _dates;
  late int _selectedIndex;
  final ScrollController _stripController = ScrollController();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(
      _days,
      (i) => today.subtract(Duration(days: _days - 1 - i)),
    );
    _selectedIndex = _days - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stripController.hasClients) {
        _stripController.jumpTo(_stripController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _stripController.dispose();
    super.dispose();
  }

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

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: IconThemeData(color: textPrimary),
            title: Text(
              'Activity History',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          body: Stack(
            children: [
              const BackgroundDecorations(),
              SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Last $_days Days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Tap a day to see its ring.',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ),
                const SizedBox(height: 14),
                _buildDayStrip(cardColor, accent, textPrimary, textSecondary, isDark),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSelectedDayCard(
                    cardColor,
                    accent,
                    divider,
                    textPrimary,
                    textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Daily Steps Frequency',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'One bar per day — taller bars mean more steps that day.',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FrequencyBarChart(
                    values: _dailySteps,
                    dates: _dates,
                    accent: accent,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayStrip(
    Color cardColor,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return SizedBox(
      height: 78,
      width: double.infinity,
      child: ListView.builder(
        controller: _stripController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final selected = index == _selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: selected ? accent : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.38),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayShort[date.weekday - 1],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white70 : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: selected ? 16 : 15,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayCard(
    Color cardColor,
    Color accent,
    Color divider,
    Color textPrimary,
    Color textSecondary,
  ) {
    final steps = _dailySteps[_selectedIndex];
    final distance = _dailyDistanceKm[_selectedIndex];
    final progress = (steps / _stepTarget).clamp(0.0, 1.0);
    final date = _dates[_selectedIndex];
    final isToday = _selectedIndex == _days - 1;

    return Container(
      key: ValueKey(_selectedIndex),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            isToday
                ? 'Today'
                : '${_weekdayShort[date.weekday - 1]}, ${date.day}/${date.month}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(140, 140),
                  painter: StepRingPainter(
                    progress: progress,
                    ringColor: accent,
                    trackColor: divider,
                    strokeWidth: 12,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$steps',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'of $_stepTarget',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statPill('Steps', '$steps', textPrimary, textSecondary),
              _statPill(
                'Distance',
                '${distance.toStringAsFixed(1)} km',
                textPrimary,
                textSecondary,
              ),
              _statPill(
                'Goal',
                '${(progress * 100).round()}%',
                textPrimary,
                textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
      ],
    );
  }
}

class _FrequencyBarChart extends StatelessWidget {
  final List<int> values;
  final List<DateTime> dates;
  final Color accent;
  final Color textSecondary;

  const _FrequencyBarChart({
    required this.values,
    required this.dates,
    required this.accent,
    required this.textSecondary,
  });

  static const double _maxBarHeight = 110;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return SizedBox(
      height: _maxBarHeight + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final barHeight = (values[i] / safeMax) * _maxBarHeight;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barHeight < 3 ? 3 : barHeight,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.75),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dates[i].day}',
                    style: TextStyle(fontSize: 9, color: textSecondary),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
