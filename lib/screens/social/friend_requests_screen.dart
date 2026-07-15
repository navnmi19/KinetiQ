// social/screens/friend_requests_screen.dart
//
// Friend Requests Screen — manage incoming and outgoing requests.
//
// A custom segmented control (Received / Sent) sits above an
// AnimatedList so accepting, declining, or cancelling a request
// collapses that row out smoothly instead of just vanishing.
//
// NOTE ON STRUCTURE: same staging approach as the previous two
// screens. _SocialTokens is duplicated here for now (Dart privates
// are file-scoped); it collapses into one shared theme import once
// theme/app_theme.dart is approved.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // add to pubspec.yaml: google_fonts: ^6.2.1

import 'friend_profile_screen.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  int _tabIndex = 0; // 0 = Received, 1 = Sent

  final GlobalKey<AnimatedListState> _receivedKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _sentKey = GlobalKey<AnimatedListState>();

  late List<_RequestItem> _received;
  late List<_RequestItem> _sent;

  @override
  void initState() {
    super.initState();
    _received = List.of(_mockReceived);
    _sent = List.of(_mockSent);
  }

  void _removeReceived(int index) {
    final removed = _received.removeAt(index);
    _receivedKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRow(removed, animation, isReceived: true),
      duration: const Duration(milliseconds: 260),
    );
  }

  void _removeSent(int index) {
    final removed = _sent.removeAt(index);
    _sentKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRow(removed, animation, isReceived: false),
      duration: const Duration(milliseconds: 260),
    );
  }

  Widget _buildRow(_RequestItem item, Animation<double> animation, {required bool isReceived}) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RequestRow(
            tokens: _SocialTokens.of(context),
            item: item,
            isReceived: isReceived,
            onAccept: isReceived
                ? () => _removeReceived(_received.indexOf(item))
                : null,
            onDecline: isReceived
                ? () => _removeReceived(_received.indexOf(item))
                : null,
            onCancel: !isReceived
                ? () => _removeSent(_sent.indexOf(item))
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _SocialTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _ScreenHeader(tokens: tokens),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: _SegmentedControl(
                tokens: tokens,
                index: _tabIndex,
                labels: ['Received (${_received.length})', 'Sent (${_sent.length})'],
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                sizing: StackFit.expand,
                children: [
                  _received.isEmpty
                      ? _EmptyState(
                          tokens: tokens,
                          icon: Icons.mark_email_read_outlined,
                          message: 'No pending requests',
                        )
                      : AnimatedList(
                          key: _receivedKey,
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          initialItemCount: _received.length,
                          itemBuilder: (context, index, animation) =>
                              _buildRow(_received[index], animation, isReceived: true),
                        ),
                  _sent.isEmpty
                      ? _EmptyState(
                          tokens: tokens,
                          icon: Icons.outgoing_mail,
                          message: 'No outgoing requests',
                        )
                      : AnimatedList(
                          key: _sentKey,
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          initialItemCount: _sent.length,
                          itemBuilder: (context, index, animation) =>
                              _buildRow(_sent[index], animation, isReceived: false),
                        ),
                ],
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
// PRIVATE MODELS (staging for models/request_item.dart)
// ============================================================

class _RequestItem {
  final String name;
  final String handle;
  final String initials;
  final int mutualFriends;
  final String timeAgo;

  const _RequestItem({
    required this.name,
    required this.handle,
    required this.initials,
    required this.mutualFriends,
    required this.timeAgo,
  });
}

// ============================================================
// MOCK DATA (staging for data/mock_social_data.dart)
// ============================================================

const _mockReceived = [
  _RequestItem(
    name: 'Elena Petrova',
    handle: '@elena.p',
    initials: 'EP',
    mutualFriends: 4,
    timeAgo: '2h',
  ),
  _RequestItem(
    name: 'Jamal Wright',
    handle: '@jamal.w',
    initials: 'JW',
    mutualFriends: 1,
    timeAgo: '1d',
  ),
  _RequestItem(
    name: 'Naomi Chen',
    handle: '@naomi.c',
    initials: 'NC',
    mutualFriends: 8,
    timeAgo: '3d',
  ),
];

const _mockSent = [
  _RequestItem(
    name: 'Owen Bright',
    handle: '@owen.b',
    initials: 'OB',
    mutualFriends: 0,
    timeAgo: '5h',
  ),
  _RequestItem(
    name: 'Fatima Siddiqui',
    handle: '@fatima.s',
    initials: 'FS',
    mutualFriends: 2,
    timeAgo: '2d',
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
        Text('Friend requests', style: tokens.display(size: 20)),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final _SocialTokens tokens;
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.tokens,
    required this.icon,
    required this.onTap,
  });

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

/// Brand segmented control with a sliding active-pill indicator.
class _SegmentedControl extends StatelessWidget {
  final _SocialTokens tokens;
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.tokens,
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / labels.length;
        return Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: tokens.surfaceSunken,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  labels.length == 1 ? 0 : (-1 + (2 * index / (labels.length - 1))),
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / labels.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: tokens.isDark ? 0.3 : 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final selected = i == index;
                  return SizedBox(
                    width: segmentWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onChanged(i),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: tokens.body(
                            size: 13,
                            weight: FontWeight.w600,
                            color: selected ? tokens.ink : tokens.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  final _SocialTokens tokens;
  final _RequestItem item;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;

  const _RequestRow({
    required this.tokens,
    required this.item,
    required this.isReceived,
    this.onAccept,
    this.onDecline,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
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
                      radius: 22,
                      backgroundColor: tokens.signal.withValues(alpha: 0.14),
                      child: Text(
                        item.initials,
                        style: tokens.body(size: 14, color: tokens.signal, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: tokens.body(size: 14.5, weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(item.handle, style: tokens.body(size: 12.5, color: tokens.inkMuted)),
                              if (item.mutualFriends > 0) ...[
                                Text('  ·  ', style: tokens.body(size: 12.5, color: tokens.inkFaint)),
                                Text(
                                  '${item.mutualFriends} mutual',
                                  style: tokens.mono(size: 12, color: tokens.inkFaint),
                                ),
                              ],
                              Text('  ·  ', style: tokens.body(size: 12.5, color: tokens.inkFaint)),
                              Text(item.timeAgo, style: tokens.mono(size: 12, color: tokens.inkFaint)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isReceived) ...[
            _CircleActionButton(
              tokens: tokens,
              icon: Icons.close_rounded,
              filled: false,
              onTap: onDecline,
            ),
            const SizedBox(width: 8),
            _CircleActionButton(
              tokens: tokens,
              icon: Icons.check_rounded,
              filled: true,
              onTap: onAccept,
            ),
          ] else
            _PillButton(tokens: tokens, label: 'Cancel', onTap: onCancel),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final _SocialTokens tokens;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _CircleActionButton({
    required this.tokens,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: filled ? tokens.ember : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: filled ? tokens.ember : tokens.hairline),
          ),
          child: Icon(
            icon,
            size: 18,
            color: filled ? Colors.white : tokens.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final _SocialTokens tokens;
  final String label;
  final VoidCallback? onTap;

  const _PillButton({required this.tokens, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tokens.hairline),
          ),
          child: Text(
            label,
            style: tokens.body(size: 12.5, color: tokens.inkMuted, weight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _SocialTokens tokens;
  final IconData icon;
  final String message;

  const _EmptyState({required this.tokens, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: tokens.inkFaint),
          const SizedBox(height: 12),
          Text(
            message,
            style: tokens.body(size: 14, color: tokens.inkMuted, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}