import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gym_app/themes/gymin_theme.dart';

/// Static build for now — every number here is dummy data matching
/// the original design mock. Wire real data in later the same way
/// dashboard_screen.dart's Today's Workout card wires into
/// WorkoutService: swap the hardcoded values below for a
/// ListenableBuilder over whatever service ends up owning progress
/// stats (XP, streak, heatmap, PRs).
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 112),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProgressHeader(),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: const [
                        _WeeklyConsistency(),
                        SizedBox(height: 20),
                        _TrainingHeatmap(),
                        SizedBox(height: 20),
                        _PrCarousel(),
                        SizedBox(height: 20),
                        _MuscleBalance(),
                        SizedBox(height: 20),
                        _MonthlyReport(),
                        SizedBox(height: 20),
                        _ProgressAiInsight(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(left: 16, right: 16, bottom: 16, child: _ProgressBottomNav()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header + XP/Level hero card
// ---------------------------------------------------------------------------

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: c.heroGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Evolution',
                        style: c.body(size: 14, weight: FontWeight.w600, color: c.accent)),
                    Text('Progress', style: c.heading(size: 30)),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.isDark ? c.chip : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: c.isDark
                      ? null
                      : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.emoji_events_rounded, size: 20, color: c.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _XpHeroCard(
            level: 14,
            tier: 'Gold II',
            streakDays: 12,
            currentXp: 2340,
            targetXp: 3000,
            nextTier: 'Gold III',
            xpThisWeek: 180,
          ),
        ],
      ),
    );
  }
}

class _XpHeroCard extends StatelessWidget {
  final int level;
  final String tier;
  final int streakDays;
  final int currentXp;
  final int targetXp;
  final String nextTier;
  final int xpThisWeek;

  const _XpHeroCard({
    required this.level,
    required this.tier,
    required this.streakDays,
    required this.currentXp,
    required this.targetXp,
    required this.nextTier,
    required this.xpThisWeek,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final progress = (currentXp / targetXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: c.heroCardBg, borderRadius: BorderRadius.circular(28)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(92, 92),
                  painter: _RingPainter(progress: progress, track: c.heroCardTrack, accent: c.accent),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$level',
                        style: c.heading(size: 24, weight: FontWeight.w800).copyWith(color: Colors.white, height: 1)),
                    const SizedBox(height: 2),
                    Text('LEVEL',
                        style: c.body(size: 10, weight: FontWeight.w600, color: const Color(0xFF8A8A8A))
                            .copyWith(letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(tier, style: c.heading(size: 19).copyWith(color: Colors.white)),
                    const SizedBox(width: 6),
                    Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF4A4A4A), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF8A00)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('$streakDays-day streak',
                          overflow: TextOverflow.ellipsis,
                          style: c.body(size: 13, weight: FontWeight.w600, color: const Color(0xFFB7B7B7))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$currentXp / $targetXp XP to $nextTier',
                    style: c.body(size: 13, color: const Color(0xFF8A8A8A))),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: c.heroCardTrack,
                    valueColor: AlwaysStoppedAnimation(c.accent),
                  ),
                ),
                const SizedBox(height: 6),
                Text('+$xpThisWeek XP this week',
                    style: c.body(size: 12, weight: FontWeight.w500, color: c.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color accent;
  const _RingPainter({required this.progress, required this.track, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fgPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// Weekly consistency
// ---------------------------------------------------------------------------

enum _DayStatus { done, missed, rest, future }

class _WeeklyConsistency extends StatelessWidget {
  const _WeeklyConsistency();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _statuses = [
    _DayStatus.done,
    _DayStatus.done,
    _DayStatus.rest,
    _DayStatus.done,
    _DayStatus.missed,
    _DayStatus.done,
    _DayStatus.future,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final doneCount = _statuses.where((s) => s == _DayStatus.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weekly Consistency', style: c.heading()),
            Text('$doneCount / 7 goal', style: c.body(size: 13, weight: FontWeight.w600, color: c.accent)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (i) {
            final status = _statuses[i];
            final (bg, dot) = switch (status) {
              _DayStatus.done => (c.accent, null),
              _DayStatus.missed => (c.danger.withOpacity(0.12), c.danger),
              _DayStatus.rest => (const Color(0xFFFF8A00).withOpacity(0.14), const Color(0xFFFF8A00)),
              _DayStatus.future => (c.chip, c.border),
            };
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: status == _DayStatus.done
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                  ),
                  const SizedBox(height: 6),
                  Text(_days[i], style: c.body(size: 11, color: c.textTertiary)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Training heatmap (5 weeks x 7 days)
// ---------------------------------------------------------------------------

class _TrainingHeatmap extends StatelessWidget {
  const _TrainingHeatmap();

  // 0 = no session .. 4 = highest volume day.
  static const _levels = [
    0, 0, 1, 0, 0, 2, 0,
    1, 0, 2, 3, 0, 1, 0,
    0, 2, 1, 0, 3, 2, 0,
    1, 0, 0, 2, 1, 0, 2,
    0, 1, 2, 0, 1, 0, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final colors = c.isDark
        ? [c.chip, const Color(0xFF1F3A28), const Color(0xFF1E5A38), const Color(0xFF22C55E), const Color(0xFFFF8A00)]
        : [const Color(0xFFEAFBF1), const Color(0xFFA8EEC1), const Color(0xFF5AD98A), const Color(0xFF22C55E), const Color(0xFF0F9142)];

    return GyminCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Training Heatmap', style: c.heading()),
              Text('July', style: c.body(size: 13, weight: FontWeight.w600, color: c.textTertiary)),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _levels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemBuilder: (_, i) => AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: colors[_levels[i]], borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PR carousel
// ---------------------------------------------------------------------------

class _PrCarousel extends StatelessWidget {
  const _PrCarousel();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final prs = const [
      ('Deadlift', '175 kg', 'Jun 29'),
      ('Back Squat', '140 kg', 'Jun 20'),
      ('Bench Press', '105 kg', 'Jun 12'),
    ];

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final (name, weight, date) = prs[i];
          return Container(
            width: 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: c.textPrimary, borderRadius: BorderRadius.circular(9)),
                  child: Icon(Icons.emoji_events_rounded, size: 14, color: c.bg),
                ),
                const Spacer(),
                Text(name, style: c.body(size: 13, weight: FontWeight.w600)),
                Text(weight, style: c.heading(size: 20, weight: FontWeight.w800)),
                Text(date, style: c.body(size: 11, color: c.textTertiary)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Muscle balance
// ---------------------------------------------------------------------------

class _MuscleBalance extends StatelessWidget {
  const _MuscleBalance();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final rows = [
      ('Push', 0.52, c.accent),
      ('Pull', 0.38, c.accent),
      ('Legs', 0.10, c.danger),
    ];

    return GyminCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Muscle Balance', style: c.heading()),
          const SizedBox(height: 14),
          Column(
            children: rows
                .map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r.$1, style: c.body(size: 12, weight: FontWeight.w600)),
                              Text('${(r.$2 * 100).round()}%', style: c.body(size: 12, weight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: r.$2,
                              minHeight: 8,
                              backgroundColor: c.divider,
                              valueColor: AlwaysStoppedAnimation(r.$3),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          Text('Legs are under-trained relative to upper body — consider adding a session.',
              style: c.body(size: 12, color: c.textTertiary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly report
// ---------------------------------------------------------------------------

class _MonthlyReport extends StatelessWidget {
  const _MonthlyReport();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final stats = [
      ('14', 'Workouts', c.textPrimary),
      ('38.2t', 'Total Volume', c.textPrimary),
      ('52m', 'Avg Duration', c.textPrimary),
      ('+12%', 'vs June', c.accent),
    ];

    return GyminCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('July Report', style: c.heading()),
              Text('18 days in', style: c.body(size: 13, weight: FontWeight.w600, color: c.textTertiary)),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
            children: stats
                .map((s) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: c.heading(size: 22, weight: FontWeight.w800).copyWith(color: s.$3)),
                        Text(s.$2, style: c.body(size: 12, color: c.textTertiary)),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI insight (Progress variant)
// ---------------------------------------------------------------------------

class _ProgressAiInsight extends StatelessWidget {
  const _ProgressAiInsight();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.heroCardBg, borderRadius: BorderRadius.circular(22)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.auto_awesome_rounded, size: 18, color: c.heroCardBg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI INSIGHT',
                    style: c.body(size: 13, weight: FontWeight.w700, color: c.accent).copyWith(letterSpacing: 0.3)),
                const SizedBox(height: 5),
                Text(
                  'Your squat volume is up 22% this month with recovery trending down — a lighter deload week could protect your streak.',
                  style: c.body(size: 14, weight: FontWeight.w500, color: c.heroCardText).copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom nav (Progress tab active)
// ---------------------------------------------------------------------------

class _ProgressBottomNav extends StatelessWidget {
  const _ProgressBottomNav();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final icons = [
      Icons.home_rounded,
      Icons.fitness_center_rounded,
      Icons.show_chart_rounded,
      Icons.person_outline_rounded,
    ];
    const activeIndex = 2;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: c.isDark ? c.chip : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(c.isDark ? 0.4 : 0.10), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final selected = i == activeIndex;
          if (selected) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(color: c.accentSoftBg, borderRadius: BorderRadius.circular(99)),
              child: Row(
                children: [
                  Icon(icons[i], size: 19, color: c.accent),
                  const SizedBox(width: 6),
                  Text('Progress', style: c.body(size: 12, weight: FontWeight.w700, color: c.accent)),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Icon(icons[i], size: 19, color: c.textTertiary),
          );
        }),
      ),
    );
  }
}