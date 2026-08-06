import 'package:flutter/material.dart';
import '../../themes/theme_controller.dart';
import '../../widgets/muscle_map_painter.dart';
import '../nutrition/nutrition_screen.dart';
import '../profile/profile_screen.dart';
import 'graphs_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final colors = _ProgressColors(isDark);

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false, // bottomNavigationBar handles its own SafeArea
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen title only — theme toggle lives on Dashboard.
                  _ProgressHeader(colors: colors),
                  const SizedBox(height: 20),
                  _MuscleMapCard(colors: colors),
                  const SizedBox(height: 16),
                  _FrequencyHeatmap(colors: colors),
                  const SizedBox(height: 16),
                  _StreakCard(colors: colors),
                  const SizedBox(height: 16),
                  _InsightRow(colors: colors),
                  const SizedBox(height: 16),
                  _PersonalBestCard(colors: colors),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _ProgressBottomNav(colors: colors),
        );
      },
    );
  }
}

/// Centralizes light/dark values so widgets below don't each
/// re-derive colors from `isDark` — one source of truth per build.
class _ProgressColors {
  final bool isDark;
  _ProgressColors(this.isDark);

  Color get background => isDark ? const Color(0xFF090909) : Colors.white;
  Color get cardSurface =>
      isDark ? const Color(0xFF151515) : const Color(0xFFF5FBF7);
  Color get accent => isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF14532D);
  Color get textSecondary =>
      isDark ? const Color(0xFF8A8A8A) : const Color(0xFF5B7A66);
  Color get ringTrack => isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE3F2E9);
  Color get downColor => isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935);
}

// ---------------------------------------------------------------------
// 0. Header — title + rotating punchline
// ---------------------------------------------------------------------

const List<String> _progressPunchlines = [
  "Consistency is your superpower.",
  "Every session moves the needle.",
  "Look how far you've come.",
];

String get _progressPunchline {
  final dayOfYear = DateTime.now().day + DateTime.now().month * 31;
  return _progressPunchlines[dayOfYear % _progressPunchlines.length];
}

class _ProgressHeader extends StatelessWidget {
  final _ProgressColors colors;
  const _ProgressHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.insights_rounded, color: colors.accent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _progressPunchline,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: colors.accent,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// 1. Muscle-group mannequin
// ---------------------------------------------------------------------

class _MuscleMapCard extends StatefulWidget {
  final _ProgressColors colors;
  const _MuscleMapCard({required this.colors});

  @override
  State<_MuscleMapCard> createState() => _MuscleMapCardState();
}

class _MuscleMapCardState extends State<_MuscleMapCard> {
  MuscleMapView _view = MuscleMapView.front;

  // Placeholder training-volume intensity per muscle group (0 = untargeted
  // → gray, 1 = heavily trained → red). Swap for real workout history
  // once there's a backend.
  static const Map<String, double> _intensities = {
    'Chest': 0.9,
    'Shoulders': 0.5,
    'Biceps': 0.4,
    'Triceps': 0.35,
    'Abs': 0.7,
    'Quads': 0.85,
    'Lats': 0.6,
    'Lower Back': 0.0,
    'Glutes': 0.75,
    'Hamstrings': 0.55,
    'Calves': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Muscles Trained',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.ringTrack,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _viewToggle('Front', MuscleMapView.front, colors),
                    _viewToggle('Back', MuscleMapView.back, colors),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: Center(
              child: MuscleMapWidget(
                view: _view,
                intensities: _intensities,
                neutralColor: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _legendDot(colors.textSecondary, 'Untargeted', colors),
              _legendDot(const Color(0xFF3B82F6), 'Least', colors),
              _legendDot(const Color(0xFFFB923C), 'Moderate', colors),
              _legendDot(const Color(0xFFEF4444), 'Most', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _viewToggle(String label, MuscleMapView view, _ProgressColors colors) {
    final selected = _view == view;
    return GestureDetector(
      onTap: () => setState(() => _view = view),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label, _ProgressColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// 2. Frequency heatmap — GitHub-contributions style
// ---------------------------------------------------------------------

class _FrequencyHeatmap extends StatelessWidget {
  final _ProgressColors colors;
  const _FrequencyHeatmap({required this.colors});

  static const int weeks = 14;
  static const int daysPerWeek = 7;

  // Deterministic placeholder activity levels, 0 (none) to 4 (heaviest).
  static const List<int> _pattern = [0, 2, 3, 1, 4, 0, 3, 2, 1, 0, 4, 3, 2, 1];

  int _levelFor(int index) => _pattern[index % _pattern.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Frequency',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last ${weeks * daysPerWeek} days',
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            "Each column is one week, each square is one day you trained. "
            "Darker green means a heavier training day — scan left to right "
            "to see how consistent you've been.",
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 4.0;
              final cellSize =
                  (constraints.maxWidth - gap * (weeks - 1)) / weeks;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(weeks, (week) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: week == weeks - 1 ? 0 : gap,
                    ),
                    child: Column(
                      children: List.generate(daysPerWeek, (day) {
                        final level = _levelFor(week * daysPerWeek + day);
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: EdgeInsets.only(
                            bottom: day == daysPerWeek - 1 ? 0 : gap,
                          ),
                          decoration: BoxDecoration(
                            color: level == 0
                                ? colors.textSecondary.withValues(alpha: 0.14)
                                : colors.accent.withValues(alpha: 0.2 + level * 0.2),
                            borderRadius: BorderRadius.circular(cellSize * 0.25),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Less', style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              const SizedBox(width: 6),
              ...List.generate(5, (i) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? colors.textSecondary.withValues(alpha: 0.14)
                        : colors.accent.withValues(alpha: 0.2 + i * 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text('More', style: TextStyle(fontSize: 11, color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 3. Streak card
// ---------------------------------------------------------------------

class _StreakCard extends StatelessWidget {
  final _ProgressColors colors;
  const _StreakCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    const streakDays = 12; // placeholder — same concept as the dashboard tile
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_fire_department_rounded, color: colors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays-Day Streak',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Keep it going — don't break the chain.",
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 4. Insight cards — today vs. yesterday deltas, tap → Graphs screen
// ---------------------------------------------------------------------

class _InsightRow extends StatelessWidget {
  final _ProgressColors colors;
  const _InsightRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GraphsScreen()),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InsightCard(
              colors: colors,
              label: 'Volume',
              value: '▲12%',
              sublabel: 'vs. yesterday',
              isPositive: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InsightCard(
              colors: colors,
              label: 'Calories',
              value: '▼5%',
              sublabel: 'vs. yesterday',
              isPositive: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final _ProgressColors colors;
  final String label;
  final String value;
  final String sublabel;
  final bool isPositive;

  const _InsightCard({
    required this.colors,
    required this.label,
    required this.value,
    required this.sublabel,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isPositive ? colors.accent : colors.downColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(sublabel, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 5. Personal Best card
// ---------------------------------------------------------------------

class _PersonalBestCard extends StatelessWidget {
  final _ProgressColors colors;
  const _PersonalBestCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    const records = [
      ('Best Volume', '8,940 kg', Icons.fitness_center_rounded),
      ('Best Duration', '1h 12m', Icons.timer_rounded),
      ('Most Calories Burnt', '612 kcal', Icons.local_fire_department_rounded),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.emoji_events_rounded, color: colors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Best',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Your strongest sessions yet.',
                      style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...records.map((r) {
            final (label, value, icon) = r;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: colors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Bottom nav bar for the Progress screen — visually matches Dashboard's
/// nav bar. "Progress" is shown pre-selected since that's this screen.
/// Tapping "Home" pops back to Dashboard; Nutrition/Friends replace this
/// screen in place, matching the other screens' bottom nav behavior.
class _ProgressBottomNav extends StatelessWidget {
  final _ProgressColors colors;
  const _ProgressBottomNav({required this.colors});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.restaurant_menu_rounded, label: 'Nutrition'),
    (icon: Icons.show_chart_rounded, label: 'Progress'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  static const int _progressIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final selected = index == _progressIndex;
            final item = _items[index];

            return GestureDetector(
              onTap: () {
                if (selected) return; // already here, no-op
                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  return;
                }
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const NutritionScreen()),
                  );
                  return;
                }
                if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  return;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? colors.accent.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: selected ? colors.accent : colors.textSecondary,
                    ),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
