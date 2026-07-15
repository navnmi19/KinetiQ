// social/screens/activity_feed_screen.dart
//
// Activity Feed Screen — a running log of friends' workouts.
//
// Posts are grouped under day dividers (Today / Yesterday / date).
// Each post carries a "cheer" toggle (optimistic like) and a comment
// count. Pull-to-refresh is wired to a mock delay.
//
// NOTE ON STRUCTURE: same staging approach as the other screens.
// _SocialTokens is duplicated here for now (Dart privates are
// file-scoped); it collapses into a shared theme import once
// theme/app_theme.dart is approved.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // add to pubspec.yaml: google_fonts: ^6.2.1

import 'friend_profile_screen.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  late List<_FeedPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List.of(_mockFeed);
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _posts = List.of(_mockFeed));
  }

  void _toggleCheer(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        cheered: !post.cheered,
        cheerCount: post.cheered ? post.cheerCount - 1 : post.cheerCount + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _SocialTokens.of(context);
    final grouped = _groupByDay(_posts);

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _ScreenHeader(tokens: tokens),
            ),
            Expanded(
              child: RefreshIndicator(
                color: tokens.ember,
                backgroundColor: tokens.surfaceElevated,
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final entry = grouped[i];
                    if (entry.isHeader) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, i == 0 ? 4 : 20, 0, 10),
                        child: _DayDivider(tokens: tokens, label: entry.dayLabel!),
                      );
                    }
                    final postIndex = _posts.indexOf(entry.post!);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FeedPostCard(
                        tokens: tokens,
                        post: entry.post!,
                        onCheer: () => _toggleCheer(postIndex),
                      ),
                    );
                  },
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
// PRIVATE MODELS (staging for models/feed_post.dart)
// ============================================================

class _FeedPost {
  final String friendName;
  final String initials;
  final String timeLabel;
  final String dayLabel; // "Today", "Yesterday", "Mon, Jul 13"
  final String workoutTitle;
  final IconData workoutIcon;
  final int durationMin;
  final String statValue;
  final String statUnit;
  final int cheerCount;
  final bool cheered;
  final int commentCount;

  const _FeedPost({
    required this.friendName,
    required this.initials,
    required this.timeLabel,
    required this.dayLabel,
    required this.workoutTitle,
    required this.workoutIcon,
    required this.durationMin,
    required this.statValue,
    required this.statUnit,
    required this.cheerCount,
    required this.cheered,
    required this.commentCount,
  });

  _FeedPost copyWith({int? cheerCount, bool? cheered}) {
    return _FeedPost(
      friendName: friendName,
      initials: initials,
      timeLabel: timeLabel,
      dayLabel: dayLabel,
      workoutTitle: workoutTitle,
      workoutIcon: workoutIcon,
      durationMin: durationMin,
      statValue: statValue,
      statUnit: statUnit,
      cheerCount: cheerCount ?? this.cheerCount,
      cheered: cheered ?? this.cheered,
      commentCount: commentCount,
    );
  }
}

class _FeedListEntry {
  final bool isHeader;
  final String? dayLabel;
  final _FeedPost? post;

  const _FeedListEntry.header(this.dayLabel)
      : isHeader = true,
        post = null;

  const _FeedListEntry.post(this.post)
      : isHeader = false,
        dayLabel = null;
}

List<_FeedListEntry> _groupByDay(List<_FeedPost> posts) {
  final entries = <_FeedListEntry>[];
  String? lastDay;
  for (final post in posts) {
    if (post.dayLabel != lastDay) {
      entries.add(_FeedListEntry.header(post.dayLabel));
      lastDay = post.dayLabel;
    }
    entries.add(_FeedListEntry.post(post));
  }
  return entries;
}

// ============================================================
// MOCK DATA (staging for data/mock_social_data.dart)
// ============================================================

const _mockFeed = [
  _FeedPost(
    friendName: 'Priya Nair',
    initials: 'PN',
    timeLabel: '8:12 AM',
    dayLabel: 'Today',
    workoutTitle: 'Morning run',
    workoutIcon: Icons.directions_run_rounded,
    durationMin: 42,
    statValue: '6.4',
    statUnit: 'km',
    cheerCount: 5,
    cheered: false,
    commentCount: 2,
  ),
  _FeedPost(
    friendName: 'Marcus Cole',
    initials: 'MC',
    timeLabel: '7:03 AM',
    dayLabel: 'Today',
    workoutTitle: 'Strength · Push day',
    workoutIcon: Icons.fitness_center_rounded,
    durationMin: 58,
    statValue: '5,120',
    statUnit: 'kg lifted',
    cheerCount: 9,
    cheered: true,
    commentCount: 4,
  ),
  _FeedPost(
    friendName: 'Sara Kim',
    initials: 'SK',
    timeLabel: '6:45 PM',
    dayLabel: 'Yesterday',
    workoutTitle: 'Evening ride',
    workoutIcon: Icons.directions_bike_rounded,
    durationMin: 71,
    statValue: '24.8',
    statUnit: 'km',
    cheerCount: 3,
    cheered: false,
    commentCount: 0,
  ),
  _FeedPost(
    friendName: 'Diego Alvarez',
    initials: 'DA',
    timeLabel: '9:30 AM',
    dayLabel: 'Yesterday',
    workoutTitle: 'Yoga flow',
    workoutIcon: Icons.self_improvement_rounded,
    durationMin: 30,
    statValue: '210',
    statUnit: 'kcal',
    cheerCount: 6,
    cheered: false,
    commentCount: 1,
  ),
  _FeedPost(
    friendName: 'Naomi Chen',
    initials: 'NC',
    timeLabel: '5:15 PM',
    dayLabel: 'Mon, Jul 13',
    workoutTitle: 'Swim · Intervals',
    workoutIcon: Icons.pool_rounded,
    durationMin: 45,
    statValue: '1.8',
    statUnit: 'km',
    cheerCount: 2,
    cheered: false,
    commentCount: 0,
  ),
];

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
        const SizedBox(width: 12),
        Text('Activity', style: tokens.display(size: 20)),
      ],
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

class _DayDivider extends StatelessWidget {
  final _SocialTokens tokens;
  final String label;
  const _DayDivider({required this.tokens, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: tokens.body(size: 11, color: tokens.inkFaint, weight: FontWeight.w700).copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: tokens.hairline, height: 1)),
      ],
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  final _SocialTokens tokens;
  final _FeedPost post;
  final VoidCallback onCheer;

  const _FeedPostCard({required this.tokens, required this.post, required this.onCheer});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FriendProfileScreen()),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: tokens.signal.withValues(alpha: 0.14),
                          child: Text(
                            post.initials,
                            style: tokens.body(size: 12.5, color: tokens.signal, weight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.friendName, style: tokens.body(size: 14, weight: FontWeight.w600)),
                              Text(post.timeLabel, style: tokens.body(size: 11.5, color: tokens.inkMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tokens.ember.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(post.workoutIcon, size: 16, color: tokens.ember),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(post.workoutTitle, style: tokens.body(size: 15, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatPair(tokens: tokens, value: '${post.durationMin}', unit: 'min'),
              const SizedBox(width: 16),
              _StatPair(tokens: tokens, value: post.statValue, unit: post.statUnit),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _CheerButton(tokens: tokens, cheered: post.cheered, count: post.cheerCount, onTap: onCheer),
              const SizedBox(width: 16),
              Icon(Icons.mode_comment_outlined, size: 16, color: tokens.inkFaint),
              const SizedBox(width: 4),
              Text('${post.commentCount}', style: tokens.mono(size: 12, color: tokens.inkFaint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPair extends StatelessWidget {
  final _SocialTokens tokens;
  final String value;
  final String unit;
  const _StatPair({required this.tokens, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: tokens.mono(size: 15)),
        const SizedBox(width: 3),
        Text(unit, style: tokens.body(size: 11.5, color: tokens.inkMuted)),
      ],
    );
  }
}

/// Optimistic "cheer" toggle — a subtle scale pop on tap.
class _CheerButton extends StatefulWidget {
  final _SocialTokens tokens;
  final bool cheered;
  final int count;
  final VoidCallback onTap;

  const _CheerButton({
    required this.tokens,
    required this.cheered,
    required this.count,
    required this.onTap,
  });

  @override
  State<_CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<_CheerButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Icon(
                widget.cheered ? Icons.bolt_rounded : Icons.bolt_outlined,
                size: 18,
                color: widget.cheered ? tokens.ember : tokens.inkFaint,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.count}',
              style: tokens.mono(size: 12, color: widget.cheered ? tokens.ember : tokens.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}