import 'package:flutter/material.dart';
import 'package:gym_app/models/friend_model.dart';
import 'search_people_screen.dart';
import 'friend_requests_screen.dart';
import 'friend_profile_screen.dart';
import 'my_friends_screen.dart';
import 'friends_controller.dart';
import '../../themes/theme_controller.dart';
import '../nutrition/nutrition_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // ---- bottom nav -----------------------------------------------
  // Friends is reached from within Profile now, not a tab of its own — the
  // Profile tab stays highlighted since this is still "under" that section,
  // but tapping it again navigates back to the Profile screen itself.
  int navIndex = 3;
  final List<_NavItem> navItems = const [
    _NavItem(icon: Icons.home_rounded, label: "Home"),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: "Nutrition"),
    _NavItem(icon: Icons.show_chart_rounded, label: "Progress"),
    _NavItem(icon: Icons.person_rounded, label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bgTop = isDark ? Colors.black : const Color(0xFFD1FAE5);
        final bgBottom = isDark ? const Color(0xFF0B0B0D) : Colors.white;
        final card = isDark ? const Color(0xFF1A1A1D) : Colors.white;
        final accent =
            isDark ? const Color(0xFFFF7A1A) : const Color(0xFF22C55E);
        final textPrimary = isDark ? Colors.white : Colors.black87;
        final textSecondary =
            isDark ? Colors.white70 : Colors.grey.shade700;
        final chipInactive = isDark ? Colors.white24 : Colors.grey.shade300;
        final chipInactiveText =
            isDark ? Colors.white70 : Colors.grey.shade700;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgTop, bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          Text(
                            "Friends",
                            style: TextStyle(
                              fontSize: width < 360 ? 30 : 36,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Stay connected with your fitness partners.",
                            style: TextStyle(
                              fontSize: 15,
                              color: textSecondary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          _ActionCard(
                            icon: Icons.person_search_rounded,
                            title: "Find Friends",
                            subtitle: "Discover new workout partners nearby.",
                            accent: accent,
                            cardColor: card,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SearchPeopleScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          _ActionCard(
                            icon: Icons.groups_rounded,
                            title: "My Friends",
                            subtitle: "View your fitness circle and activity.",
                            accent: accent,
                            cardColor: card,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MyFriendsScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          ValueListenableBuilder<List<Friend>>(
                            valueListenable: FriendsController.friends,
                            builder: (context, _, _) {
                              final pendingCount =
                                  FriendsController.pendingIncoming.length;
                              return _ActionCard(
                                icon: Icons.mark_email_unread_rounded,
                                title: "Friend Requests",
                                subtitle: pendingCount > 0
                                    ? "$pendingCount pending requests waiting for you."
                                    : "No pending requests.",
                                accent: accent,
                                cardColor: card,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                badge: pendingCount > 0 ? "$pendingCount" : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          Row(
                            children: [
                              Text(
                                "Suggested Friends",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 210,
                            child: ValueListenableBuilder<List<Friend>>(
                              valueListenable: FriendsController.friends,
                              builder: (context, _, _) {
                                final suggested = FriendsController.discoverable;

                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: suggested.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                                  itemBuilder: (_, index) {
                                    final item = suggested[index];
                                    final requested =
                                        item.status == FriendStatus.pendingOutgoing;

                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FriendProfileScreen(friend: item),
                                            ),
                                          );
                                        },
                                        child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                      width: 170,
                                      decoration: BoxDecoration(
                                        color: card,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              radius: 34,
                                              backgroundColor:
                                                  item.color.withValues(alpha: .15),
                                              child: Icon(
                                                item.icon,
                                                color: item.color,
                                                size: 34,
                                              ),
                                            ),

                                            Column(
                                              children: [
                                                Text(
                                                  item.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 17,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.activityTag,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            InkWell(
                                              borderRadius: BorderRadius.circular(14),
                                              onTap: requested
                                                  ? null
                                                  : () => FriendsController
                                                      .sendRequest(item.id),
                                              child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 350),
                                              curve: Curves.easeInOut,
                                              height: 42,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: requested
                                                    ? chipInactive
                                                    : accent,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  requested ? "Requested" : "Add",
                                                  style: TextStyle(
                                                    color: requested
                                                        ? chipInactiveText
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNav(card, accent, textSecondary, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // BOTTOM NAVIGATION
  // -------------------------------------------------------------

  Widget _buildBottomNav(
    Color card,
    Color accent,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final selected = index == navIndex;
            final item = navItems[index];

            return GestureDetector(
              onTap: () {
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

                if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: selected ? accent : textSecondary,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: selected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            )
                          : const SizedBox(width: 0, height: 0),
                    ),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final String? badge;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    this.badge,
    this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? .98 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.accent,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: widget.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: widget.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (widget.badge != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: widget.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
