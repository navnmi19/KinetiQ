// social/screens/search_people_screen.dart
//
// Search People Screen — find and send friend requests.
//
// Shows a search field, a "Suggested for you" list before typing,
// and filtered results while typing. Each row carries a stateful
// action button (Add -> Requested) with an optimistic tap animation.
//
// NOTE ON STRUCTURE: same staging approach as social_home_screen.dart.
// _SocialTokens is duplicated here for now since Dart privates are
// file-scoped and this screen must compile standalone. Once
// theme/app_theme.dart and widgets/ are approved, this and the
// home screen's copy collapse into one shared, imported source —
// no logic changes, just relocation.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // add to pubspec.yaml: google_fonts: ^6.2.1

import 'friend_profile_screen.dart';

class SearchPeopleScreen extends StatefulWidget {
  const SearchPeopleScreen({super.key});

  @override
  State<SearchPeopleScreen> createState() => _SearchPeopleScreenState();
}

class _SearchPeopleScreenState extends State<SearchPeopleScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_PersonResult> get _filtered {
    if (_query.trim().isEmpty) return _mockSuggested;
    final q = _query.trim().toLowerCase();
    return _mockAllPeople.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.handle.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _SocialTokens.of(context);
    final results = _filtered;
    final isSearching = _query.trim().isNotEmpty;

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _SearchField(
                tokens: tokens,
                controller: _controller,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isSearching ? 'Results' : 'Suggested for you',
                  style: tokens.body(
                    size: 11,
                    color: tokens.inkFaint,
                    weight: FontWeight.w600,
                  ).copyWith(letterSpacing: 0.8),
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? _EmptyResults(tokens: tokens, query: _query)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _PersonRow(
                          tokens: tokens,
                          person: results[index],
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
// PRIVATE MODELS (staging for models/person_result.dart)
// ============================================================

enum _FriendStatus { none, requested, friends }

class _PersonResult {
  final String name;
  final String handle;
  final String initials;
  final int mutualFriends;
  final _FriendStatus status;

  const _PersonResult({
    required this.name,
    required this.handle,
    required this.initials,
    required this.mutualFriends,
    required this.status,
  });
}

// ============================================================
// MOCK DATA (staging for data/mock_social_data.dart)
// ============================================================

const _mockSuggested = [
  _PersonResult(
    name: 'Priya Nair',
    handle: '@priya.trains',
    initials: 'PN',
    mutualFriends: 6,
    status: _FriendStatus.none,
  ),
  _PersonResult(
    name: 'Diego Alvarez',
    handle: '@diego.lifts',
    initials: 'DA',
    mutualFriends: 3,
    status: _FriendStatus.requested,
  ),
  _PersonResult(
    name: 'Marcus Cole',
    handle: '@marcus.runs',
    initials: 'MC',
    mutualFriends: 9,
    status: _FriendStatus.friends,
  ),
];

const _mockAllPeople = [
  ..._mockSuggested,
  _PersonResult(
    name: 'Sara Kim',
    handle: '@sara.kim',
    initials: 'SK',
    mutualFriends: 2,
    status: _FriendStatus.none,
  ),
  _PersonResult(
    name: 'Owen Bright',
    handle: '@owen.b',
    initials: 'OB',
    mutualFriends: 0,
    status: _FriendStatus.none,
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
        Text('Find people', style: tokens.display(size: 20)),
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

class _SearchField extends StatelessWidget {
  final _SocialTokens tokens;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.tokens,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.hairline),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: tokens.body(size: 15),
        cursorColor: tokens.ember,
        decoration: InputDecoration(
          hintText: 'Search by name or handle',
          hintStyle: tokens.body(size: 15, color: tokens.inkFaint),
          prefixIcon: Icon(Icons.search_rounded, color: tokens.inkMuted, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: tokens.inkMuted, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final _SocialTokens tokens;
  final _PersonResult person;
  const _PersonRow({required this.tokens, required this.person});

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
                        person.initials,
                        style: tokens.body(size: 14, color: tokens.signal, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name,
                            style: tokens.body(size: 14.5, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                person.handle,
                                style: tokens.body(size: 12.5, color: tokens.inkMuted),
                              ),
                              if (person.mutualFriends > 0) ...[
                                Text(
                                  '  ·  ',
                                  style: tokens.body(size: 12.5, color: tokens.inkFaint),
                                ),
                                Text(
                                  '${person.mutualFriends} mutual',
                                  style: tokens.mono(size: 12, color: tokens.inkFaint),
                                ),
                              ],
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
          _FriendActionButton(tokens: tokens, status: person.status),
        ],
      ),
    );
  }
}

/// Tri-state action button: Add -> Requested -> Friends.
/// Purely visual state change on tap (optimistic UI, no backend call).
class _FriendActionButton extends StatefulWidget {
  final _SocialTokens tokens;
  final _FriendStatus status;
  const _FriendActionButton({required this.tokens, required this.status});

  @override
  State<_FriendActionButton> createState() => _FriendActionButtonState();
}

class _FriendActionButtonState extends State<_FriendActionButton> {
  late _FriendStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  void _handleTap() {
    if (_status == _FriendStatus.friends) return;
    setState(() {
      _status = _status == _FriendStatus.none
          ? _FriendStatus.requested
          : _FriendStatus.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    final (label, bg, fg, border) = switch (_status) {
      _FriendStatus.none => (
          'Add',
          tokens.ember,
          Colors.white,
          tokens.ember,
        ),
      _FriendStatus.requested => (
          'Requested',
          Colors.transparent,
          tokens.inkMuted,
          tokens.hairline,
        ),
      _FriendStatus.friends => (
          'Friends',
          tokens.signal.withValues(alpha: 0.12),
          tokens.signal,
          Colors.transparent,
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: tokens.body(size: 12.5, color: fg, weight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final _SocialTokens tokens;
  final String query;
  const _EmptyResults({required this.tokens, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded, size: 36, color: tokens.inkFaint),
            const SizedBox(height: 12),
            Text(
              'No one matches "$query"',
              textAlign: TextAlign.center,
              style: tokens.body(size: 14, color: tokens.inkMuted, weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Check the spelling or try a different name.',
              textAlign: TextAlign.center,
              style: tokens.body(size: 12.5, color: tokens.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}