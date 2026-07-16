import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_app/themes/gymin_theme.dart';
import 'package:gym_app/themes/theme_toggle_button.dart';
import 'package:gym_app/models/workout_card_model.dart';
import 'package:gym_app/services/workout_service.dart';
import 'package:gym_app/models/workout_state.dart';
import 'package:gym_app/screens/data/sample_workout.dart';
import 'package:gym_app/screens/workout/workout_flow_controller.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, this.userName = 'Navneet'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _volumeTab = 0; // 0 = Community, 1 = Friends

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
                  _Header(userName: widget.userName),
                  _WeekStrip(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      children: [
                        _VolumeCard(
                          tab: _volumeTab,
                          onTabChanged: (t) => setState(() => _volumeTab = t),
                        ),
                        const SizedBox(height: 20),
                        const _TodaysWorkoutCard(),
                        const SizedBox(height: 16),
                        const _AiInsightCard(),
                        const SizedBox(height: 16),
                        const _StatGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _BottomNav(active: 0),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: c.heroGradient,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Morning', style: c.body(size: 14, weight: FontWeight.w700, color: c.accent)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('Hey, $userName ', style: c.heading(size: 26)),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Stay consistent.', style: c.body()),
              ],
            ),
          ),
          Column(
            children: [
              const ThemeToggleButton(),
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c.isDark ? c.chip : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: c.isDark
                      ? null
                      : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.notifications_none_rounded, size: 18, color: c.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week strip
// ---------------------------------------------------------------------------

enum DayStatus { done, missed, rest, future }

class _WeekStrip extends StatelessWidget {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dates = [5, 6, 7, 8, 9, 10, 11];
  static const _statuses = [
    DayStatus.done,
    DayStatus.done,
    DayStatus.rest,
    DayStatus.missed,
    DayStatus.done,
    DayStatus.done,
    DayStatus.future,
  ];
  static const _todayIndex = 5;

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Row(
        children: List.generate(7, (i) {
          final isToday = i == _todayIndex;
          final dotColor = switch (_statuses[i]) {
            DayStatus.done => c.accent,
            DayStatus.missed => c.danger,
            DayStatus.rest => const Color(0xFFFF8A00),
            DayStatus.future => c.border,
          };
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isToday ? c.accent : (c.isDark ? c.chip : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(_days[i],
                        style: c.body(
                            size: 11,
                            weight: FontWeight.w600,
                            color: isToday ? Colors.white : c.textSecondary)),
                    const SizedBox(height: 6),
                    Text('${_dates[i]}',
                        style: c.heading(size: 15, weight: FontWeight.w700)
                            .copyWith(color: isToday ? Colors.white : c.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? Colors.white : dotColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Workout Volume card (tab toggle + spline chart)
// ---------------------------------------------------------------------------

class _VolumeCard extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTabChanged;
  const _VolumeCard({required this.tab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return GyminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Workout Volume', style: c.heading(size: 18)),
              Row(
                children: [
                  _FilterChip(label: 'Weekly'),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'Volume', maxWidth: 100),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(99)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SegButton(label: 'Community', selected: tab == 0, onTap: () => onTabChanged(0)),
                _SegButton(label: 'Friends', selected: tab == 1, onTap: () => onTabChanged(1)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _LegendDash(color: c.accent, dashed: false, label: 'You'),
              const SizedBox(width: 16),
              _LegendDash(color: c.border, dashed: true, label: 'Community Avg'),
            ],
          ),
          SizedBox(
            height: 160,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _SplinePainter(accent: c.accent, avgLine: c.border),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Text(d, style: c.body(size: 11, color: c.textTertiary)))
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: c.accentSoftBg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("You're above your community average", style: c.body(size: 13))),
                Text('↑ 18.7%', style: c.heading(size: 15, weight: FontWeight.w700).copyWith(color: c.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final double? maxWidth;
  const _FilterChip({required this.label, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: c.body(size: 11, weight: FontWeight.w600, color: c.textPrimary)),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: c.textSecondary),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label,
            style: c.body(
                size: 12,
                weight: FontWeight.w600,
                color: selected ? c.bg : c.textSecondary)),
      ),
    );
  }
}

class _LegendDash extends StatelessWidget {
  final Color color;
  final bool dashed;
  final String label;
  const _LegendDash({required this.color, required this.dashed, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 3,
          child: dashed
              ? CustomPaint(painter: _DashPainter(color: color))
              : DecoratedBox(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(width: 6),
        Text(label, style: c.body(size: 12, weight: FontWeight.w600)),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SplinePainter extends CustomPainter {
  final Color accent;
  final Color avgLine;
  const _SplinePainter({required this.accent, required this.avgLine});

  @override
  void paint(Canvas canvas, Size size) {
    final youPts = [0.72, 0.86, 0.79, 0.62, 0.56, 0.83];
    final avgPts = [0.53, 0.56, 0.62, 0.46, 0.42, 0.60];

    Path buildPath(List<double> pts) {
      final path = Path();
      final stepX = size.width / (pts.length - 1);
      Offset p(int i) => Offset(i * stepX, size.height * (1 - pts[i]));
      path.moveTo(p(0).dx, p(0).dy);
      for (int i = 0; i < pts.length - 1; i++) {
        final c1 = Offset((p(i).dx + p(i + 1).dx) / 2, p(i).dy);
        final c2 = Offset((p(i).dx + p(i + 1).dx) / 2, p(i + 1).dy);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p(i + 1).dx, p(i + 1).dy);
      }
      return path;
    }

    final youPath = buildPath(youPts);

    final fillPath = Path.from(youPath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withOpacity(0.18), accent.withOpacity(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      youPath,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    final avgPath = buildPath(avgPts);
    final dashedPaint = Paint()
      ..color = avgLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (final metric in _dashPathMetrics(avgPath)) {
      canvas.drawPath(metric, dashedPaint);
    }

    final lastStepX = size.width / (youPts.length - 1);
    final lastPoint = Offset((youPts.length - 1) * lastStepX, size.height * (1 - youPts.last));
    canvas.drawCircle(lastPoint, 5, Paint()..color = Colors.white);
    canvas.drawCircle(lastPoint, 5, Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  Iterable<Path> _dashPathMetrics(Path source, {double dash = 5, double gap = 6}) sync* {
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        yield metric.extractPath(distance, next.clamp(0, metric.length));
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Today's Workout
// ---------------------------------------------------------------------------

class _TodaysWorkoutCard extends StatelessWidget {
  const _TodaysWorkoutCard();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final tint = c.isDark ? const Color(0xFF14202E) : const Color(0xFFDDEBFC);

    return ListenableBuilder(
      listenable: WorkoutService.instance,
      builder: (context, _) {
        final workout = WorkoutService.instance.workout;
        return GyminCard(
          color: tint,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(workout.state),
                child: switch (workout.state) {
                  WorkoutState.notStarted => _NotStartedCard(workout: workout, c: c),
                  WorkoutState.inProgress => _InProgressCard(workout: workout, c: c),
                  WorkoutState.completed => _CompletedCard(workout: workout, c: c),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// -- State 1: not started ----------------------------------------------

class _NotStartedCard extends StatelessWidget {
  final WorkoutCardModel workout;
  final GyminColors c;
  const _NotStartedCard({required this.workout, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Today's Workout", style: c.body(size: 12, weight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(workout.workoutName, style: c.heading(size: 23)),
        const SizedBox(height: 2),
        Text(
          '${workout.totalExercises} Exercises · ${workout.estimatedDuration.inMinutes} min',
          style: c.body(),
        ),
        const SizedBox(height: 18),
        _CtaButton(
          label: 'START WORKOUT',
          color: c.accent,
          textColor: Colors.white,
          // WorkoutService has no startWorkout() of its own — starting
          // a workout is WorkoutFlowController's job. This just opens
          // the real flow; WorkoutFlowController will report back to
          // WorkoutService.instance once the user actually presses
          // Start on the Overview screen.
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutFlowController(
                initialSession: sampleWorkoutSession,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -- State 2: in progress ------------------------------------------------

class _InProgressCard extends StatefulWidget {
  final WorkoutCardModel workout;
  final GyminColors c;
  const _InProgressCard({required this.workout, required this.c});

  @override
  State<_InProgressCard> createState() => _InProgressCardState();
}

class _InProgressCardState extends State<_InProgressCard> {
  Timer? _uiTicker;

  @override
  void initState() {
    super.initState();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final workout = widget.workout;
    final current = workout.currentExercise;
    final progressPct = (workout.progress * 100).round();
    final elapsed = WorkoutService.instance.elapsed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Continue Workout', style: c.body(size: 12, weight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'Exercise ${workout.currentExerciseNumber} of ${workout.totalExercises}',
          style: c.body(size: 13, weight: FontWeight.w600, color: c.accent),
        ),
        const SizedBox(height: 2),
        Text(current?.name ?? workout.workoutName, style: c.heading(size: 22)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: workout.progress,
            minHeight: 8,
            backgroundColor: c.textPrimary.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation(c.accent),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$progressPct% Complete', style: c.body(size: 12, weight: FontWeight.w600)),
            Text('Elapsed Time  ${_formatElapsed(elapsed)}', style: c.body(size: 12)),
          ],
        ),
        const SizedBox(height: 18),
        _CtaButton(
          label: 'RESUME',
          color: c.accent,
          textColor: Colors.white,
          // NOTE: this does NOT truly resume a mid-workout session —
          // WorkoutFlowController's progress lives only in its own
          // State object, which is gone once its route is popped.
          // This re-opens the flow from the Overview screen with the
          // same session. Real resume needs WorkoutFlowController kept
          // alive higher in the widget tree (e.g. never popped, or
          // state hoisted above the Dashboard route) — flagging this
          // as a known gap rather than faking it.
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutFlowController(
                initialSession: sampleWorkoutSession,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -- State 3: completed ---------------------------------------------------

class _CompletedCard extends StatelessWidget {
  final WorkoutCardModel workout;
  final GyminColors c;
  const _CompletedCard({required this.workout, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Workout Complete', style: c.body(size: 12, weight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(99)),
              child: Text('Completed Today',
                  style: c.body(size: 11, weight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(workout.workoutName, style: c.heading(size: 23)),
        const SizedBox(height: 18),
        _CtaButton(
          label: 'VIEW SUMMARY',
          color: c.accent,
          textColor: Colors.white,
          onTap: () {
            // Wire to your workout-summary route/screen.
          },
        ),
      ],
    );
  }
}

// -- Shared CTA button ------------------------------------------------------

class _CtaButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _CtaButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: Text(label,
            style: c.heading(size: 14, weight: FontWeight.w700).copyWith(color: textColor)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI Insight
// ---------------------------------------------------------------------------

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final rows = const [
      ('Chest Volume', '▲18%', 'Compared to last week'),
      ('Bench Press', '▲7%', 'New strength peak'),
      ('Recovery Score', '82%', 'Ready for heavy training'),
    ];
    return GyminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: c.accentSoftBg, borderRadius: BorderRadius.circular(11)),
                child: Icon(Icons.auto_awesome_rounded, size: 16, color: c.accent),
              ),
              const SizedBox(width: 10),
              Text('AI Insight', style: c.heading(size: 15)),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: rows
                .map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(r.$1, style: c.body(size: 13, weight: FontWeight.w600, color: c.textPrimary))),
                          Expanded(
                            flex: 2,
                            child: Text(r.$2,
                                style: c.heading(size: 13, weight: FontWeight.w700).copyWith(color: c.accent)),
                          ),
                          Expanded(
                              flex: 4,
                              child: Text(r.$3,
                                  textAlign: TextAlign.right,
                                  style: c.body(size: 11, weight: FontWeight.w500, color: c.textTertiary))),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat grid
// ---------------------------------------------------------------------------

class _StatGrid extends StatelessWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final stats = const [
      (Icons.trending_up_rounded, '+12%', 'Strength'),
      (Icons.bar_chart_rounded, '+18%', 'Volume'),
      (Icons.monitor_weight_outlined, '-1.3 kg', 'Weight'),
      (Icons.local_fire_department_rounded, '12 days', 'Streak'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: stats
          .map((s) => GyminCard(
                radius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: c.accentSoftBg, borderRadius: BorderRadius.circular(11)),
                      child: Icon(s.$1, size: 16, color: c.accent),
                    ),
                    const Spacer(),
                    Text(s.$2, style: c.heading(size: 20, weight: FontWeight.w800)),
                    Text(s.$3, style: c.body(size: 12, color: c.textTertiary)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom nav
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final int active;
  const _BottomNav({required this.active});

  @override
  Widget build(BuildContext context) {
    final c = context.gymin;
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.fitness_center_rounded, ''),
      (Icons.show_chart_rounded, ''),
      (Icons.person_outline_rounded, ''),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: c.isDark ? c.chip : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(c.isDark ? 0.4 : 0.10), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == active;
          final (icon, label) = items[i];
          if (selected) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(color: c.accentSoftBg, borderRadius: BorderRadius.circular(99)),
              child: Row(
                children: [
                  Icon(icon, size: 19, color: c.accent),
                  if (label.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(label, style: c.body(size: 12, weight: FontWeight.w700, color: c.accent)),
                  ],
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Icon(icon, size: 19, color: c.textTertiary),
          );
        }),
      ),
    );
  }
}