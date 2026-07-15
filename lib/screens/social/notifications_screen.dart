// social/screens/notifications_screen.dart
//
// Notifications Screen — friend requests, cheers, comments, streak
// milestones, and a muted AI-suggestion placeholder type.
//
// Rows are grouped under day dividers. Unread rows carry a small
// ember dot that fades out on tap (or all at once via "Mark all
// read"). The AI-suggestion type reuses the quiet, dashed / "SOON"
// treatment from the home screen's AI placeholder cards so it never
// competes with real, actionable notifications.
//
// NOTE ON STRUCTURE: same staging approach as the other five
// screens. _SocialTokens and the day-grouping helper are duplicated
// here for now (Dart privates are file-scoped); once theme/ and
// widgets/ are approved, these collapse into shared imports with no
// logic changes — this is the last of the six planned screens, so
// that consolidation pass is the natural next step after this file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // add to pubspec.yaml: google_fonts: ^6.2.1

import 'friend_profile_screen.dart';
import 'friend_requests_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(_mockNotifications);
  }

  bool get _hasUnread => _items.any((n) => !n.isRead);

  void _markAllRead() {
    setState(() {
      _items = [for (final n in _items) n.copyWith(isRead: true)];
    });
  }

  void _markRead(int index) {
    if (_items[index].isRead) return;
    setState(() {
      _items[index] = _items[index].copyWith(isRead: true);
    });
  }

  void _handleNavigate(BuildContext context, _NotificationItem item) {
    switch (item.kind) {
      case _NotificationKind.friendRequest:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
        );
      case _NotificationKind.friendAccepted:
      case _NotificationKind.cheer:
      case _NotificationKind.comment:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FriendProfileScreen()),
        );
      case _NotificationKind.streakMilestone:
      case _NotificationKind.aiSuggestion:
        break; // about the user's own activity / a placeholder — nowhere to go
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _SocialTokens.of(context);
    final grouped = _groupByDay(_items);

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _ScreenHeader(
                tokens: tokens,
                hasUnread: _hasUnread,
                onMarkAllRead: _markAllRead,
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? _EmptyState(tokens: tokens)
                  : ListView.builder(
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
                        final itemIndex = _items.indexOf(entry.item!);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotificationRow(
                            tokens: tokens,
                            item: entry.item!,
                            onTap: () {
                              _markRead(itemIndex);
                              _handleNavigate(context, entry.item!);
                            },
                          ),
                        );
                      },
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
// PRIVATE MODELS (staging for models/notification_item.dart)
// ============================================================

enum _NotificationKind {
  friendRequest,
  friendAccepted,
  cheer,
  comment,
  streakMilestone,
  aiSuggestion,
}

class _NotificationItem {
  final _NotificationKind kind;
  final String actorName;
  final String actorInitials;
  final String message;
  final String timeLabel;
  final String dayLabel;
  final bool isRead;

  const _NotificationItem({
    required this.kind,
    required this.actorName,
    required this.actorInitials,
    required this.message,
    required this.timeLabel,
    required this.dayLabel,
    required this.isRead,
  });

  _NotificationItem copyWith({bool? isRead}) {
    return _NotificationItem(
      kind: kind,
      actorName: actorName,
      actorInitials: actorInitials,
      message: message,
      timeLabel: timeLabel,
      dayLabel: dayLabel,
      isRead: isRead ?? this.isRead,
    );
  }

  bool get isAiPlaceholder => kind == _NotificationKind.aiSuggestion;

  IconData get icon => switch (kind) {
        _NotificationKind.friendRequest => Icons.person_add_outlined,
        _NotificationKind.friendAccepted => Icons.how_to_reg_outlined,
        _NotificationKind.cheer => Icons.bolt_rounded,
        _NotificationKind.comment => Icons.mode_comment_outlined,
        _NotificationKind.streakMilestone => Icons.local_fire_department_rounded,
        _NotificationKind.aiSuggestion => Icons.auto_awesome_outlined,
      };
}

// ============================================================
// DAY GROUPING HELPER (duplicated staging copy)
// ============================================================

class _ListEntry {
  final bool isHeader;
  final String? dayLabel;
  final _NotificationItem? item;

  const _ListEntry.header(this.dayLabel)
      : isHeader = true,
        item = null;

  const _ListEntry.item(this.item)
      : isHeader = false,
        dayLabel = null;
}

List<_ListEntry> _groupByDay(List<_NotificationItem> items) {
  final entries = <_ListEntry>[];
  String? lastDay;
  for (final item in items) {
    if (item.dayLabel != lastDay) {
      entries.add(_ListEntry.header(item.dayLabel));
      lastDay = item.dayLabel;
    }
    entries.add(_ListEntry.item(item));
  }
  return entries;
}

// ============================================================
// MOCK DATA (staging for data/mock_social_data.dart)
// ============================================================

const _mockNotifications = [
  _NotificationItem(
    kind: _NotificationKind.friendRequest,
    actorName: 'Elena Petrova',
    actorInitials: 'EP',
    message: 'sent you a friend request',
    timeLabel: '2h',
    dayLabel: 'Today',
    isRead: false,
  ),
  _NotificationItem(
    kind: _NotificationKind.cheer,
    actorName: 'Marcus Cole',
    actorInitials: 'MC',
    message: 'cheered your morning run',
    timeLabel: '3h',
    dayLabel: 'Today',
    isRead: false,
  ),
  _NotificationItem(
    kind: _NotificationKind.aiSuggestion,
    actorName: 'AI Coach',
    actorInitials: 'AI',
    message: 'has a new suggestion for your week',
    timeLabel: '5h',
    dayLabel: 'Today',
    isRead: false,
  ),
  _NotificationItem(
    kind: _NotificationKind.comment,
    actorName: 'Priya Nair',
    actorInitials: 'PN',
    message: 'commented on your strength session',
    timeLabel: '1d',
    dayLabel: 'Yesterday',
    isRead: true,
  ),
  _NotificationItem(
    kind: _NotificationKind.streakMilestone,
    actorName: 'You',
    actorInitials: 'YOU',
    message: 'hit a 12-day streak — keep it going',
    timeLabel: '1d',
    dayLabel: 'Yesterday',
    isRead: true,
  ),
  _NotificationItem(
    kind: _NotificationKind.friendAccepted,
    actorName: 'Sara Kim',
    actorInitials: 'SK',
    message: 'accepted your friend request',
    timeLabel: '3d',
    dayLabel: 'Mon, Jul 13',
    isRead: true,
  ),
];

// ============================================================
// WIDGETS (staging for widgets/)
// ============================================================

class _ScreenHeader extends StatelessWidget {
  final _SocialTokens tokens;
  final bool hasUnread;
  final VoidCallback onMarkAllRead;

  const _ScreenHeader({
    required this.tokens,
    required this.hasUnread,
    required this.onMarkAllRead,
  });

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
        Expanded(child: Text('Notifications', style: tokens.display(size: 20))),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: hasUnread ? 1 : 0,
          child: IgnorePointer(
            ignoring: !hasUnread,
            child: TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                foregroundColor: tokens.ember,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'Mark all read',
                style: tokens.body(size: 12.5, color: tokens.ember, weight: FontWeight.w600),
              ),
            ),
          ),
        ),
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

class _NotificationRow extends StatelessWidget {
  final _SocialTokens tokens;
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotificationRow({required this.tokens, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (item.isAiPlaceholder) {
      return _AiNotificationRow(tokens: tokens, item: item);
    }

    final iconColor = switch (item.kind) {
      _NotificationKind.friendRequest || _NotificationKind.friendAccepted => tokens.signal,
      _ => tokens.ember,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tokens.hairline),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: tokens.body(size: 13.5, color: tokens.ink),
                        children: [
                          TextSpan(
                            text: '${item.actorName} ',
                            style: tokens.body(size: 13.5, weight: FontWeight.w700),
                          ),
                          TextSpan(text: item.message),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(item.timeLabel, style: tokens.body(size: 11.5, color: tokens.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: item.isRead ? 0 : 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: tokens.ember, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quiet variant for AI-generated notifications — same dashed /
/// "SOON" language as the home screen's AI placeholder cards, so it
/// reads as a preview rather than a real, actionable item.
class _AiNotificationRow extends StatelessWidget {
  final _SocialTokens tokens;
  final _NotificationItem item;
  const _AiNotificationRow({required this.tokens, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.surfaceSunken.withValues(alpha: tokens.isDark ? 0.5 : 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.hairline, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tokens.signal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18, color: tokens.signal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: tokens.body(size: 13.5, color: tokens.inkMuted),
                          children: [
                            TextSpan(
                              text: '${item.actorName} ',
                              style: tokens.body(size: 13.5, color: tokens.inkMuted, weight: FontWeight.w700),
                            ),
                            TextSpan(text: item.message),
                          ],
                        ),
                      ),
                    ),
                    _ComingSoonPill(tokens: tokens),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.timeLabel, style: tokens.body(size: 11.5, color: tokens.inkFaint)),
              ],
            ),
          ),
        ],
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
        style: tokens.body(size: 9, color: tokens.inkFaint, weight: FontWeight.w700).copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _SocialTokens tokens;
  const _EmptyState({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded, size: 36, color: tokens.inkFaint),
          const SizedBox(height: 12),
          Text(
            'You\'re all caught up',
            style: tokens.body(size: 14, color: tokens.inkMuted, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}