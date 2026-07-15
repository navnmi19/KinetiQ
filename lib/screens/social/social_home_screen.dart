// social/screens/social_home_screen.dart
//
// Social Home Screen — entry point into the Social module.
//
// REDESIGN NOTES (v2 — decluttering pass):
//   The original version stacked five visually-distinct blocks (banner,
//   hero card, section header + carousel, a buried text-link to the
//   feed, and two full-width "coming soon" cards). That's a lot of
//   competing containers for a first screen.
//
//   This pass keeps the same data/tokens but changes the *composition*:
//     1. Greeting header — friend-request count is now a small inline
//        chip instead of a full-width banner (one less "block").
//     2. Weekly Snapshot hero card — unchanged, it's the strongest
//        visual and earns the top slot.
//     3. Recent activity — NEW. Instead of a link that takes you away
//        from the screen, the top 3 real feed items are rendered
//        inline, with "See all" tucked into the section header. This
//        is the retention lever: there's always something to scroll
//        into on open, rather than a dead-end teaser link.
//     4. How you compare — same carousel, tighter header.
//     5. Coming soon — the two AI placeholders are merged into a
//        single compact card (two rows, one border) instead of two
//        full cards, since it's non-functional content and shouldn't
//        take as much visual weight as real data.
//
//   Net effect: same number of "ideas" on screen, fewer boxes, and the
//   feed — the thing people actually come back for — is front and
//   center instead of one tap away.
//
// NOTE ON STRUCTURE: this file is intentionally self-contained so it
// compiles and runs on its own. The private models, mock data, and
// private widgets below are staging areas — when models/, widgets/,
// and data/ are delivered in later steps, these are lifted out
// verbatim into their own files and this screen will simply import
// them instead. No logic changes at that point, just relocation.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // add to pubspec.yaml: google_fonts: ^6.2.1

import 'activity_feed_screen.dart';
import 'friend_profile_screen.dart';
import 'friend_requests_screen.dart';
import 'notifications_screen.dart';
import 'search_people_screen.dart';

class SocialHomeScreen extends StatelessWidget {
  const SocialHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = _SocialTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---- Header ------------------------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _GreetingHeader(
                  tokens: tokens,
                  pendingRequests: _mockPendingRequestsCount,
                ),
              ),
            ),

            // ---- Hero: weekly snapshot ----------------------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _WeeklySnapshotCard(
                  tokens: tokens,
                  stats: _mockWeeklyStats,
                ),
              ),
            ),

            // ---- Recent activity (real feed, not a link) -----------------
            SliverToBoxAdapter(
              child: _SectionHeader(
                tokens: tokens,
                title: 'Recent activity',
                subtitle: 'From people you train with',
                trailing: _SeeAllLink(
                  tokens: tokens,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ActivityFeedScreen()),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _FeedPreviewCard(
                  tokens: tokens,
                  items: _mockFeedItems.take(3).toList(),
                  onOpenFeed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ActivityFeedScreen()),
                  ),
                ),
              ),
            ),

            // ---- How you compare -----------------------------------------
            SliverToBoxAdapter(
              child: _SectionHeader(
                tokens: tokens,
                title: 'How you compare',
                subtitle: 'Against the friends you train with',
              ),
            ),
            SliverToBoxAdapter(
              child: _ComparisonCarousel(
                tokens: tokens,
                entries: _mockComparisons,
              ),
            ),

            // ---- Coming soon (condensed, de-emphasized) -------------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              sliver: SliverToBoxAdapter(
                child: _ComingSoonCard(
                  tokens: tokens,
                  items: _mockAIPlaceholders,
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
// DESIGN TOKENS
// (staging area for a future theme/app_theme.dart)
// ============================================================

class _SocialTokens {
  final Brightness brightness;

  const _SocialTokens(this.brightness);

  static _SocialTokens of(BuildContext context) =>
      _SocialTokens(Theme.of(context).brightness);

  bool get isDark => brightness == Brightness.dark;

  // Surfaces
  Color get surface => isDark ? const Color(0xFF14171C) : const Color(0xFFF7F7F4);
  Color get surfaceElevated =>
      isDark ? const Color(0xFF1D2129) : const Color(0xFFFFFFFF);
  Color get surfaceSunken =>
      isDark ? const Color(0xFF0F1114) : const Color(0xFFEFEFEB);

  // Text
  Color get ink => isDark ? const Color(0xFFF2F3F1) : const Color(0xFF14171C);
  Color get inkMuted =>
      isDark ? const Color(0xFF9AA1AC) : const Color(0xFF6B7280);
  Color get inkFaint =>
      isDark ? const Color(0xFF5B6270) : const Color(0xFFAEB2B8);

  // Accents
  Color get ember => const Color(0xFFFF5A36); // personal effort
  Color get signal => const Color(0xFF0EA5A8); // social / comparison
  Color get emberTrack =>
      isDark ? const Color(0xFF3A2A24) : const Color(0xFFF0DCD5);

  // Borders
  Color get hairline =>
      isDark ? const Color(0xFF2A2E36) : const Color(0xFFE4E3DD);

  // Type
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
// PRIVATE MODELS
// (staging area for a future models/ folder)
// ============================================================

class _WeeklyStats {
  final int workoutsCompleted;
  final int workoutsTarget;
  final int totalMinutes;
  final int streakDays;
  final List<double> dailyIntensity; // 7 values, 0..1, Mon..Sun

  const _WeeklyStats({
    required this.workoutsCompleted,
    required this.workoutsTarget,
    required this.totalMinutes,
    required this.streakDays,
    required this.dailyIntensity,
  });
}

class _ComparisonEntry {
  final String friendName;
  final String friendInitials;
  final String metricLabel;
  final num userValue;
  final num friendValue;
  final String unit;

  const _ComparisonEntry({
    required this.friendName,
    required this.friendInitials,
    required this.metricLabel,
    required this.userValue,
    required this.friendValue,
    required this.unit,
  });

  bool get userIsAhead => userValue >= friendValue;
}

enum _AIPlaceholderKind { coach, accountability }

class _AIPlaceholder {
  final _AIPlaceholderKind kind;
  final String title;
  final String description;

  const _AIPlaceholder({
    required this.kind,
    required this.title,
    required this.description,
  });

  IconData get icon => switch (kind) {
        _AIPlaceholderKind.coach => Icons.auto_awesome_outlined,
        _AIPlaceholderKind.accountability => Icons.handshake_outlined,
      };
}

enum _FeedKind { completedWorkout, personalRecord, streakMilestone, joinedChallenge }

class _FeedItem {
  final String name;
  final String initials;
  final _FeedKind kind;
  final String detail; // e.g. "Leg Day · 52 min" or "New 5k PR: 24:18"
  final String timeAgo;

  const _FeedItem({
    required this.name,
    required this.initials,
    required this.kind,
    required this.detail,
    required this.timeAgo,
  });

  IconData get icon => switch (kind) {
        _FeedKind.completedWorkout => Icons.check_circle_outline_rounded,
        _FeedKind.personalRecord => Icons.emoji_events_outlined,
        _FeedKind.streakMilestone => Icons.local_fire_department_outlined,
        _FeedKind.joinedChallenge => Icons.flag_outlined,
      };

  String get verb => switch (kind) {
        _FeedKind.completedWorkout => 'completed a workout',
        _FeedKind.personalRecord => 'set a new PR',
        _FeedKind.streakMilestone => 'hit a streak milestone',
        _FeedKind.joinedChallenge => 'joined a challenge',
      };
}

// ============================================================
// MOCK DATA
// (staging area for a future data/mock_social_data.dart)
// ============================================================

const _mockPendingRequestsCount = 3;

const _mockWeeklyStats = _WeeklyStats(
  workoutsCompleted: 4,
  workoutsTarget: 5,
  totalMinutes: 312,
  streakDays: 12,
  dailyIntensity: [0.8, 0.0, 0.6, 1.0, 0.3, 0.9, 0.0],
);

const _mockComparisons = [
  _ComparisonEntry(
    friendName: 'Priya Nair',
    friendInitials: 'PN',
    metricLabel: 'Workouts this week',
    userValue: 4,
    friendValue: 3,
    unit: '',
  ),
  _ComparisonEntry(
    friendName: 'Marcus Cole',
    friendInitials: 'MC',
    metricLabel: 'Active minutes',
    userValue: 312,
    friendValue: 356,
    unit: 'min',
  ),
  _ComparisonEntry(
    friendName: 'Sara Kim',
    friendInitials: 'SK',
    metricLabel: 'Day streak',
    userValue: 12,
    friendValue: 9,
    unit: 'd',
  ),
];

const _mockAIPlaceholders = [
  _AIPlaceholder(
    kind: _AIPlaceholderKind.coach,
    title: 'AI Coach suggestions',
    description: 'Personalized nudges on pacing, recovery, and what\'s next.',
  ),
  _AIPlaceholder(
    kind: _AIPlaceholderKind.accountability,
    title: 'Accountability suggestions',
    description: 'Smart prompts to check in with partners who need a push.',
  ),
];

const _mockFeedItems = [
  _FeedItem(
    name: 'Priya Nair',
    initials: 'PN',
    kind: _FeedKind.personalRecord,
    detail: 'New 5k PR — 24:18',
    timeAgo: '18m ago',
  ),
  _FeedItem(
    name: 'Marcus Cole',
    initials: 'MC',
    kind: _FeedKind.completedWorkout,
    detail: 'Leg Day · 52 min',
    timeAgo: '1h ago',
  ),
  _FeedItem(
    name: 'Sara Kim',
    initials: 'SK',
    kind: _FeedKind.streakMilestone,
    detail: '10-day streak',
    timeAgo: '3h ago',
  ),
  _FeedItem(
    name: 'Devon Wallace',
    initials: 'DW',
    kind: _FeedKind.joinedChallenge,
    detail: 'August Mileage Challenge',
    timeAgo: '5h ago',
  ),
  _FeedItem(
    name: 'Aisha Khan',
    initials: 'AK',
    kind: _FeedKind.completedWorkout,
    detail: 'Upper Body · 41 min',
    timeAgo: 'Yesterday',
  ),
];

// ============================================================
// WIDGETS
// (staging area for a future widgets/ folder)
// ============================================================

/// Greeting row. Pending friend requests, if any, show as a small
/// inline chip beneath the title rather than a full-width banner —
/// keeps the header to one visual block instead of two.
class _GreetingHeader extends StatelessWidget {
  final _SocialTokens tokens;
  final int pendingRequests;
  const _GreetingHeader({required this.tokens, required this.pendingRequests});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your week, mapped out', style: tokens.display(size: 24)),
              const SizedBox(height: 6),
              if (pendingRequests > 0)
                _RequestsChip(tokens: tokens, count: pendingRequests)
              else
                Text(
                  'Monday – Sunday',
                  style: tokens.body(size: 13, color: tokens.inkMuted),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconBadge(
          tokens: tokens,
          icon: Icons.search_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchPeopleScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _IconBadge(
          tokens: tokens,
          icon: Icons.notifications_none_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }
}

/// Compact, inline pending-requests indicator — no background block,
/// just colored text + icon so it reads as metadata, not a card.
class _RequestsChip extends StatelessWidget {
  final _SocialTokens tokens;
  final int count;
  const _RequestsChip({required this.tokens, required this.count});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded, size: 14, color: tokens.signal),
            const SizedBox(width: 5),
            Text(
              '$count friend request${count == 1 ? '' : 's'} waiting',
              style: tokens.body(size: 13, color: tokens.signal, weight: FontWeight.w600),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 15, color: tokens.signal),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final _SocialTokens tokens;
  final IconData icon;
  final VoidCallback? onTap;
  const _IconBadge({required this.tokens, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: tokens.hairline),
          ),
          child: Icon(icon, size: 20, color: tokens.ink),
        ),
      ),
    );
  }
}

/// Section header with an optional trailing action (e.g. "See all"),
/// so a link never needs its own separate row below the section.
class _SectionHeader extends StatelessWidget {
  final _SocialTokens tokens;
  final String title;
  final String subtitle;
  final Widget? trailing;
  const _SectionHeader({
    required this.tokens,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tokens.display(size: 18)),
                const SizedBox(height: 2),
                Text(subtitle, style: tokens.body(size: 13, color: tokens.inkMuted)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  final _SocialTokens tokens;
  final VoidCallback onTap;
  const _SeeAllLink({required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: tokens.ember,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('See all', style: tokens.body(size: 13, color: tokens.ember, weight: FontWeight.w600)),
          Icon(Icons.chevron_right_rounded, size: 16, color: tokens.ember),
        ],
      ),
    );
  }
}

/// Hero card: pulse ring + key stat chips for the current week.
class _WeeklySnapshotCard extends StatelessWidget {
  final _SocialTokens tokens;
  final _WeeklyStats stats;
  const _WeeklySnapshotCard({required this.tokens, required this.stats});

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PulseRing(
            tokens: tokens,
            intensities: stats.dailyIntensity,
            centerLabel: '${stats.streakDays}',
            centerCaption: 'day streak',
            size: 118,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(
                  tokens: tokens,
                  label: 'Workouts',
                  value: '${stats.workoutsCompleted}',
                  suffix: '/${stats.workoutsTarget}',
                ),
                const SizedBox(height: 10),
                _StatRow(
                  tokens: tokens,
                  label: 'Active minutes',
                  value: '${stats.totalMinutes}',
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

class _StatRow extends StatelessWidget {
  final _SocialTokens tokens;
  final String label;
  final String value;
  final String suffix;
  const _StatRow({
    required this.tokens,
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: tokens.body(
            size: 11,
            color: tokens.inkFaint,
            weight: FontWeight.w600,
          ).copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: tokens.mono(size: 22)),
            Text(suffix, style: tokens.mono(size: 14, color: tokens.inkMuted)),
          ],
        ),
      ],
    );
  }
}

/// Signature element: a 7-segment radial ring, one arc per day of the
/// week, sweep proportional to that day's activity intensity. Draws
/// itself in with a light reveal animation on first build.
class _PulseRing extends StatefulWidget {
  final _SocialTokens tokens;
  final List<double> intensities; // exactly 7 values, 0..1
  final String centerLabel;
  final String centerCaption;
  final double size;

  const _PulseRing({
    required this.tokens,
    required this.intensities,
    required this.centerLabel,
    required this.centerCaption,
    required this.size,
  });

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
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
    return AnimatedBuilder(
      animation: _reveal,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(widget.size),
                painter: _PulseRingPainter(
                  intensities: widget.intensities,
                  progress: _reveal.value,
                  trackColor: widget.tokens.emberTrack,
                  activeColor: widget.tokens.ember,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerLabel,
                    style: widget.tokens.mono(size: 26),
                  ),
                  Text(
                    widget.centerCaption,
                    textAlign: TextAlign.center,
                    style: widget.tokens.body(
                      size: 10,
                      color: widget.tokens.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

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

  static const double _strokeWidth = 9;
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

      // Track (always fully visible).
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segStart,
        segSweep,
        false,
        trackPaint,
      );

      // Active portion, scaled by this day's intensity and the
      // entrance-reveal progress.
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

/// Real feed content, inline on the home screen. This is the
/// retention surface: every time the screen opens there's something
/// fresh to read, and scrolling into it should feel like the natural
/// next move after glancing at the weekly snapshot.
class _FeedPreviewCard extends StatelessWidget {
  final _SocialTokens tokens;
  final List<_FeedItem> items;
  final VoidCallback onOpenFeed;
  const _FeedPreviewCard({
    required this.tokens,
    required this.items,
    required this.onOpenFeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.hairline),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _FeedPreviewTile(tokens: tokens, item: items[i]),
            if (i != items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: tokens.hairline),
              ),
          ],
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenFeed,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'View full activity feed',
                    style: tokens.body(size: 12.5, color: tokens.inkMuted, weight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPreviewTile extends StatelessWidget {
  final _SocialTokens tokens;
  final _FeedItem item;
  const _FeedPreviewTile({required this.tokens, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FriendProfileScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: tokens.signal.withValues(alpha: 0.14),
                child: Text(
                  item.initials,
                  style: tokens.body(size: 12, color: tokens.signal, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.name,
                            style: tokens.body(size: 13.5, weight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: ' ${item.verb}',
                            style: tokens.body(size: 13.5, color: tokens.inkMuted),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.detail,
                      style: tokens.body(size: 12, color: tokens.inkFaint),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(item.icon, size: 16, color: tokens.ember),
                  const SizedBox(height: 4),
                  Text(item.timeAgo, style: tokens.body(size: 10.5, color: tokens.inkFaint)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of comparison cards.
class _ComparisonCarousel extends StatelessWidget {
  final _SocialTokens tokens;
  final List<_ComparisonEntry> entries;
  const _ComparisonCarousel({required this.tokens, required this.entries});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FriendProfileScreen()),
            ),
            child: _ComparisonCard(tokens: tokens, entry: entries[index]),
          );
        },
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final _SocialTokens tokens;
  final _ComparisonEntry entry;
  const _ComparisonCard({required this.tokens, required this.entry});

  @override
  Widget build(BuildContext context) {
    final total = (entry.userValue + entry.friendValue).toDouble();
    final userFraction = total == 0 ? 0.5 : entry.userValue / total;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: tokens.signal.withValues(alpha: 0.16),
                child: Text(
                  entry.friendInitials,
                  style: tokens.body(
                    size: 11,
                    color: tokens.signal,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.friendName,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.body(size: 13, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.metricLabel,
            style: tokens.body(size: 12, color: tokens.inkMuted),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${entry.userValue}${entry.unit}',
                style: tokens.mono(size: 18, color: tokens.ember),
              ),
              const SizedBox(width: 6),
              Text('vs', style: tokens.body(size: 11, color: tokens.inkFaint)),
              const SizedBox(width: 6),
              Text(
                '${entry.friendValue}${entry.unit}',
                style: tokens.mono(size: 18, color: tokens.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
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
        ],
      ),
    );
  }
}

/// Both AI placeholders collapsed into a single quiet card — two
/// compact rows separated by a hairline, instead of two full cards.
/// It's non-functional preview content, so it shouldn't compete
/// visually with the real data above it.
class _ComingSoonCard extends StatelessWidget {
  final _SocialTokens tokens;
  final List<_AIPlaceholder> items;
  const _ComingSoonCard({required this.tokens, required this.items});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: tokens.hairline, radius: 20),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surfaceSunken.withValues(alpha: tokens.isDark ? 0.5 : 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Text(
                    'Your AI companions',
                    style: tokens.body(size: 13, weight: FontWeight.w600, color: tokens.inkMuted),
                  ),
                  const SizedBox(width: 8),
                  _ComingSoonPill(tokens: tokens),
                ],
              ),
            ),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tokens.signal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, size: 17, color: tokens.signal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: tokens.body(size: 13, weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: tokens.body(size: 11.5, color: tokens.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  final _SocialTokens tokens;
  const _ComingSoonPill({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.hairline),
      ),
      child: Text(
        'SOON',
        style: tokens.body(
          size: 9,
          color: tokens.inkFaint,
          weight: FontWeight.w700,
        ).copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

/// Hand-painted dashed rounded-rect border — no extra package needed.
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedRRectPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 5,
    this.dashGap = 4,
    this.strokeWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, math.min(next, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}