// social/screens/friend_profile_screen.dart
//
// Friend Profile Screen — a single friend's activity at a glance.
//
// Layout, top to bottom:
//   1. Profile hero (avatar, name, mutual friends, primary actions)
//   2. Weekly pulse card (reuses the pulse-ring language from the
//      home screen, scoped to this friend's week)
//   3. "You vs {name}" detailed comparison rows
//   4. Recent activity list
//
// NOTE ON STRUCTURE: same staging approach as the other screens.
// _SocialTokens and the pulse-ring painter are duplicated here for
// now (Dart privates are file-scoped); once widgets/pulse_ring.dart
// and theme/app_theme.dart are approved, these collapse into shared
// imports with no logic changes.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // add to pubspec.yaml: google_fonts: ^6.2.1

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = _SocialTokens.of(context);
    const profile = _mockProfile;

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(child: _ScreenHeader(tokens: tokens)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _ProfileHero(tokens: tokens, profile: profile),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _WeeklyPulseCard(tokens: tokens, profile: profile),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                tokens: tokens,
                title: 'You vs ${profile.firstName}',
                subtitle: 'This week, side by side',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (int i = 0; i < profile.comparisons.length; i++) ...[
                      _ComparisonBarRow(
                        tokens: tokens,
                        entry: profile.comparisons[i],
                        friendInitials: profile.initials,
                      ),
                      if (i != profile.comparisons.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                tokens: tokens,
                title: 'Recent activity',
                subtitle: '${profile.firstName}\'s latest workouts',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (int i = 0; i < profile.recentActivity.length; i++) ...[
                      _ActivityRow(tokens: tokens, activity: profile.recentActivity[i]),
                      if (i != profile.recentActivity.length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DESIGN TOKENS (duplicated staging copy — see file header note)
// ============================================================

class _SocialTokens {
  final Brightness brightness;

  const _SocialTokens(this.brightness);

  static _SocialTokens of(BuildContext context) =>
      _SocialTokens(Theme.of(context).brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get surface => isDark ? const Color(0xFF14171C) : const Color(0xFFF7F7F4);
  Color get surfaceElevated =>
      isDark ? const Color(0xFF1D2129) : const Color(0xFFFFFFFF);
  Color get surfaceSunken =>
      isDark ? const Color(0xFF0F1114) : const Color(0xFFEFEFEB);

  Color get ink => isDark ? const Color(0xFFF2F3F1) : const Color(0xFF14171C);
  Color get inkMuted =>
      isDark ? const Color(0xFF9AA1AC) : const Color(0xFF6B7280);
  Color get inkFaint =>
      isDark ? const Color(0xFF5B6270) : const Color(0xFFAEB2B8);

  Color get ember => const Color(0xFFFF5A36);
  Color get signal => const Color(0xFF0EA5A8);
  Color get emberTrack =>
      isDark ? const Color(0xFF3A2A24) : const Color(0xFFF0DCD5);

  Color get hairline =>
      isDark ? const Color(0xFF2A2E36) : const Color(0xFFE4E3DD);

  TextStyle display({double size = 28, Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? ink,
        letterSpacing: -0.4,
        height: 1.1,
      );

  TextStyle body({double size = 15, Color? color, FontWeight? weight}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? ink,
        height: 1.35,
      );

  TextStyle mono({double size = 20, Color? color, FontWeight? weight}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? ink,
        letterSpacing: -0.2,
      );
}

// ============================================================
// PRIVATE MODELS (staging for models/)
// ============================================================

class _ComparisonEntry {
  final String metricLabel;
  final num userValue;
  final num friendValue;
  final String unit;

  const _ComparisonEntry({
    required this.metricLabel,
    required this.userValue,
    required this.friendValue,
    required this.unit,
  });
}

class _ActivityEntry {
  final String title;
  final String dayLabel;
  final int minutes;
  final IconData icon;

  const _ActivityEntry({
    required this.title,
    required this.dayLabel,
    required this.minutes,
    required this.icon,
  });
}

class _FriendProfile {
  final String name;
  final String handle;
  final String initials;
  final int mutualFriends;
  final int workoutsCompleted;
  final int workoutsTarget;
  final int totalMinutes;
  final int streakDays;
  final List<double> dailyIntensity;
  final List<_ComparisonEntry> comparisons;
  final List<_ActivityEntry> recentActivity;

  const _FriendProfile({
    required this.name,
    required this.handle,
    required this.initials,
    required this.mutualFriends,
    required this.workoutsCompleted,
    required this.workoutsTarget,
    required this.totalMinutes,
    required this.streakDays,
    required this.dailyIntensity,
    required this.comparisons,
    required this.recentActivity,
  });

  String get firstName => name.split(' ').first;
}

// ============================================================
// MOCK DATA (staging for data/mock_social_data.dart)
// ============================================================

const _mockProfile = _FriendProfile(
  name: 'Priya Nair',
  handle: '@priya.trains',
  initials: 'PN',
  mutualFriends: 6,
  workoutsCompleted: 3,
  workoutsTarget: 5,
  totalMinutes: 356,
  streakDays: 9,
  dailyIntensity: [1.0, 0.4, 0.0, 0.9, 0.7, 0.0, 0.5],
  comparisons: [
    _ComparisonEntry(metricLabel: 'Workouts', userValue: 4, friendValue: 3, unit: ''),
    _ComparisonEntry(metricLabel: 'Active minutes', userValue: 312, friendValue: 356, unit: 'min'),
    _ComparisonEntry(metricLabel: 'Day streak', userValue: 12, friendValue: 9, unit: 'd'),
  ],
  recentActivity: [
    _ActivityEntry(title: 'Morning run', dayLabel: 'Today', minutes: 42, icon: Icons.directions_run_rounded),
    _ActivityEntry(title: 'Strength · Upper body', dayLabel: 'Yesterday', minutes: 55, icon: Icons.fitness_center_rounded),
    _ActivityEntry(title: 'Yoga flow', dayLabel: 'Mon', minutes: 30, icon: Icons.self_improvement_rounded),
  ],
);

// ============================================================
// WIDGETS (staging for widgets/)
// ============================================================

class _ScreenHeader extends StatelessWidget {
  final _SocialTokens tokens;
  const _ScreenHeader({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          tokens: tokens,
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        _RoundIconButton(
          tokens: tokens,
          icon: Icons.more_horiz_rounded,
          onTap: () => _showMoreMenu(context, tokens),
        ),
      ],
    );
  }

  void _showMoreMenu(BuildContext context, _SocialTokens tokens) {
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: tokens.hairline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.notifications_off_outlined, color: tokens.ink),
                  title: Text('Mute updates', style: tokens.body(size: 14.5, weight: FontWeight.w600)),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_remove_outlined, color: Color(0xFFFF5A36)),
                  title: Text(
                    'Unfriend',
                    style: tokens.body(size: 14.5, weight: FontWeight.w600, color: const Color(0xFFFF5A36)),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final _SocialTokens tokens;
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.tokens, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: tokens.hairline),
          ),
          child: Icon(icon, size: 18, color: tokens.ink),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final _SocialTokens tokens;
  final _FriendProfile profile;
  const _ProfileHero({required this.tokens, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: tokens.signal.withValues(alpha: 0.14),
          child: Text(
            profile.initials,
            style: tokens.display(size: 26, color: tokens.signal),
          ),
        ),
        const SizedBox(height: 14),
        Text(profile.name, style: tokens.display(size: 20)),
        const SizedBox(height: 2),
        Text(profile.handle, style: tokens.body(size: 13, color: tokens.inkMuted)),
        const SizedBox(height: 6),
        Text(
          '${profile.mutualFriends} mutual friends',
          style: tokens.mono(size: 12, color: tokens.inkFaint),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PrimaryActionButton(tokens: tokens, label: 'Message', icon: Icons.chat_bubble_outline_rounded),
            const SizedBox(width: 10),
            _SecondaryActionButton(tokens: tokens, label: 'Friends', icon: Icons.check_rounded),
          ],
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final _SocialTokens tokens;
  final String label;
  final IconData icon;
  const _PrimaryActionButton({required this.tokens, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.ember,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: tokens.body(size: 13.5, color: Colors.white, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final _SocialTokens tokens;
  final String label;
  final IconData icon;
  const _SecondaryActionButton({required this.tokens, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.signal),
          const SizedBox(width: 6),
          Text(label, style: tokens.body(size: 13.5, color: tokens.inkMuted, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final _SocialTokens tokens;
  final String title;
  final String subtitle;
  const _SectionHeader({required this.tokens, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tokens.display(size: 18)),
          const SizedBox(height: 2),
          Text(subtitle, style: tokens.body(size: 13, color: tokens.inkMuted)),
        ],
      ),
    );
  }
}

class _WeeklyPulseCard extends StatefulWidget {
  final _SocialTokens tokens;
  final _FriendProfile profile;
  const _WeeklyPulseCard({required this.tokens, required this.profile});

  @override
  State<_WeeklyPulseCard> createState() => _WeeklyPulseCardState();
}

class _WeeklyPulseCardState extends State<_WeeklyPulseCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _reveal = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final profile = widget.profile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: tokens.isDark ? 0.24 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _reveal,
            builder: (context, _) => SizedBox(
              width: 96,
              height: 96,
              child: CustomPaint(
                painter: _PulseRingPainter(
                  intensities: profile.dailyIntensity,
                  progress: _reveal.value,
                  trackColor: tokens.emberTrack,
                  activeColor: tokens.ember,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${profile.streakDays}', style: tokens.mono(size: 20)),
                      Text('days', style: tokens.body(size: 9, color: tokens.inkMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatLine(
                  tokens: tokens,
                  label: 'Workouts',
                  value: '${profile.workoutsCompleted}',
                  suffix: '/${profile.workoutsTarget}',
                ),
                const SizedBox(height: 8),
                _StatLine(
                  tokens: tokens,
                  label: 'Active minutes',
                  value: '${profile.totalMinutes}',
                  suffix: ' min',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final _SocialTokens tokens;
  final String label;
  final String value;
  final String suffix;
  const _StatLine({required this.tokens, required this.label, required this.value, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: tokens.body(size: 10.5, color: tokens.inkFaint, weight: FontWeight.w600).copyWith(letterSpacing: 0.8),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: tokens.mono(size: 18)),
            Text(suffix, style: tokens.mono(size: 12, color: tokens.inkMuted)),
          ],
        ),
      ],
    );
  }
}

/// Full-width detailed comparison row — same "you vs them" visual
/// grammar as the home screen's carousel card, expanded for a
/// dedicated profile context.
class _ComparisonBarRow extends StatelessWidget {
  final _SocialTokens tokens;
  final _ComparisonEntry entry;
  final String friendInitials;

  const _ComparisonBarRow({
    required this.tokens,
    required this.entry,
    required this.friendInitials,
  });

  @override
  Widget build(BuildContext context) {
    final total = (entry.userValue + entry.friendValue).toDouble();
    final userFraction = total == 0 ? 0.5 : entry.userValue / total;
    final userIsAhead = entry.userValue >= entry.friendValue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entry.metricLabel, style: tokens.body(size: 13, weight: FontWeight.w600)),
              ),
              Icon(
                userIsAhead ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 16,
                color: userIsAhead ? tokens.ember : tokens.inkFaint,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('You', style: tokens.body(size: 11, color: tokens.inkFaint)),
              const Spacer(),
              Text(friendInitials, style: tokens.body(size: 11, color: tokens.inkFaint)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (userFraction * 1000).round().clamp(1, 999),
                    child: Container(color: tokens.ember),
                  ),
                  Expanded(
                    flex: ((1 - userFraction) * 1000).round().clamp(1, 999),
                    child: Container(color: tokens.signal.withValues(alpha: 0.35)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${entry.userValue}${entry.unit}', style: tokens.mono(size: 14, color: tokens.ember)),
              const Spacer(),
              Text('${entry.friendValue}${entry.unit}', style: tokens.mono(size: 14, color: tokens.inkMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _SocialTokens tokens;
  final _ActivityEntry activity;
  const _ActivityRow({required this.tokens, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tokens.ember.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, size: 18, color: tokens.ember),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: tokens.body(size: 13.5, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(activity.dayLabel, style: tokens.body(size: 12, color: tokens.inkMuted)),
              ],
            ),
          ),
          Text('${activity.minutes} min', style: tokens.mono(size: 13, color: tokens.inkFaint)),
        ],
      ),
    );
  }
}

// ============================================================
// SIGNATURE ELEMENT (duplicated staging copy of the pulse ring
// painter from social_home_screen.dart — see file header note)
// ============================================================

class _PulseRingPainter extends CustomPainter {
  final List<double> intensities;
  final double progress;
  final Color trackColor;
  final Color activeColor;

  _PulseRingPainter({
    required this.intensities,
    required this.progress,
    required this.trackColor,
    required this.activeColor,
  });

  static const double _strokeWidth = 8;
  static const double _gapRadians = 0.10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _strokeWidth) / 2;
    final segmentCount = intensities.length;
    final segmentAngle = (2 * math.pi) / segmentCount;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < segmentCount; i++) {
      final segStart = startAngle + i * segmentAngle + _gapRadians / 2;
      final segSweep = segmentAngle - _gapRadians;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segStart,
        segSweep,
        false,
        trackPaint,
      );

      final intensity = intensities[i].clamp(0.0, 1.0);
      final activeSweep = segSweep * intensity * progress;
      if (activeSweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segStart,
          activeSweep,
          false,
          activePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.intensities != intensities ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.activeColor != activeColor;
  }
}