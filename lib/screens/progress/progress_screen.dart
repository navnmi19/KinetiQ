import 'package:flutter/material.dart';
import '../../themes/theme_controller.dart';


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
                  // This screen still reacts to ThemeController.mode via
                  // the ValueListenableBuilder above, it just doesn't
                  // render its own switch.
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _HeaderCard(colors: colors),
                  const SizedBox(height: 16),
                  _ComparisonRow(colors: colors),
                  const SizedBox(height: 16),
                  _QuestCard(colors: colors),
                  const SizedBox(height: 16),
                  _AchievementsGrid(colors: colors),
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
  Color get cardSurface => isDark ? const Color(0xFF151515) : const Color(0xFFF5FBF7); // placeholder mint tint, swap to your real hex
  Color get accent => isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF14532D);
  Color get textSecondary => isDark ? const Color(0xFF8A8A8A) : const Color(0xFF5B7A66);
  Color get ringTrack => isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE3F2E9);
}

class _HeaderCard extends StatelessWidget {
  final _ProgressColors colors;
  const _HeaderCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    // Hardcoded values for now — wire to your XP model when ready.
    const currentLevel = 7;
    const currentXp = 1240;
    const xpToNextLevel = 2000;
    const levelTitle = 'Grinder'; // pulled from your level→title map
    final progress = currentXp / xpToNextLevel;

    return Row(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colors.ringTrack,
                  valueColor: AlwaysStoppedAnimation(colors.accent),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentLevel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'lvl',
                    style: TextStyle(fontSize: 8, color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Navneet', // wire to actual user name
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                levelTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currentXp / $xpToNextLevel xp to lvl ${currentLevel + 1}',
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final _ProgressColors colors;
  const _ComparisonRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            colors: colors,
            label: 'vs. avg lifter',
            value: '+18%',
            sublabel: 'weekly volume',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightCard(
            colors: colors,
            label: 'consistency',
            value: 'top 22%',
            sublabel: 'of gymin users',
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final _ProgressColors colors;
  final String label;
  final String value;
  final String sublabel;

  const _InsightCard({
    required this.colors,
    required this.label,
    required this.value,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
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
              fontWeight: FontWeight.w500,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(sublabel, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final _ProgressColors colors;
  const _QuestCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    // Wire to DailyQuestSelector.selectForDay(...) + QuestProgress later.
    final quests = [
      ('Log push day', true),
      ('Hit protein target', true),
      ('8k steps', false),
    ];
    final completedCount = quests.where((q) => q.$2).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "today's quest",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '$completedCount/${quests.length}',
                style: TextStyle(fontSize: 12, color: colors.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...quests.map((q) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      q.$2 ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: q.$2 ? colors.accent : colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      q.$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: q.$2 ? colors.textPrimary : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Bottom nav bar for the Progress screen — visually matches Dashboard's
/// nav bar. "Progress" is shown pre-selected since that's this screen.
/// Tapping "Home" pops back to Dashboard (this screen was pushed on top
/// of it). Nutrition/Profile are inert for now, same as on Dashboard,
/// until those screens exist.
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
                  Navigator.pop(context); // back to Dashboard
                }
                // Nutrition/Profile: no-op until those screens exist,
                // same placeholder behavior as Dashboard's nav for now.
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

class _AchievementsGrid extends StatelessWidget {
  final _ProgressColors colors;
  const _AchievementsGrid({required this.colors});

  @override
  Widget build(BuildContext context) {
    // Fixed 4 slots for MVP — no scrolling. Locked ones rendered at reduced opacity.
    final achievements = [
      (Icons.local_fire_department, '4 day streak', true),
      (Icons.military_tech, 'pushup tier 2', true),
      (Icons.military_tech, 'squat tier 2', false),
      (Icons.local_fire_department, '7 day streak', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'achievements',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: achievements.map((a) {
            final (icon, label, unlocked) = a;
            return Opacity(
              opacity: unlocked ? 1.0 : 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: unlocked ? colors.accent : colors.textSecondary),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(fontSize: 11, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}