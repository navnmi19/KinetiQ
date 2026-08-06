import 'package:flutter/material.dart';
import 'package:gym_app/themes/theme_controller.dart';
import '../social/friends_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../progress/progress_screen.dart';
import 'profile_edit_screen.dart';

/// Placeholder onboarding-derived profile data. There's no shared
/// backend/state store yet (see CLAUDE.md — everything is in-file
/// placeholders), so this lives only in [ProfileScreen]'s local state;
/// once onboarding writes to a real store this becomes its read model.
class UserProfileData {
  final String name;
  final String gender;
  final int age;
  final int heightCm;
  final double weightKg;
  final String primaryGoal;
  final String secondaryGoal;
  final List<String> targetBodyParts;
  final int daysPerWeek;
  final int sessionMinutes;
  final String bio;

  const UserProfileData({
    required this.name,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.primaryGoal,
    required this.secondaryGoal,
    required this.targetBodyParts,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.bio,
  });

  UserProfileData copyWith({
    String? name,
    String? gender,
    int? age,
    int? heightCm,
    double? weightKg,
    String? primaryGoal,
    String? secondaryGoal,
    List<String>? targetBodyParts,
    int? daysPerWeek,
    int? sessionMinutes,
    String? bio,
  }) {
    return UserProfileData(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      secondaryGoal: secondaryGoal ?? this.secondaryGoal,
      targetBodyParts: targetBodyParts ?? this.targetBodyParts,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      bio: bio ?? this.bio,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileData _profile = const UserProfileData(
    name: "Alex Carter",
    gender: "Male",
    age: 24,
    heightCm: 178,
    weightKg: 74,
    primaryGoal: "Build Muscle",
    secondaryGoal: "Improve Fitness",
    targetBodyParts: ["Chest", "Back", "Legs"],
    daysPerWeek: 4,
    sessionMinutes: 45,
    bio: "Consistency > motivation. Chasing progress, one rep at a time.",
  );

  final int navIndex = 3;

  Future<void> _openEdit() async {
    final result = await Navigator.push<UserProfileData>(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditScreen(profile: _profile)),
    );
    if (result != null) setState(() => _profile = result);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bgTop = isDark ? Colors.black : const Color(0xFFD1FAE5);
        final bgBottom = isDark ? const Color(0xFF0B0B0D) : Colors.white;
        final card = isDark ? const Color(0xFF1A1A1D) : Colors.white;
        final accent = isDark ? const Color(0xFFFF7A1A) : const Color(0xFF22C55E);
        final textPrimary = isDark ? Colors.white : Colors.black87;
        final textSecondary = isDark ? Colors.white70 : Colors.grey.shade700;

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
                            "Profile",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildHeaderCard(card, accent, textPrimary, textSecondary),
                          const SizedBox(height: 20),
                          _buildInfoCard(card, accent, textPrimary, textSecondary),
                          const SizedBox(height: 20),
                          _buildFriendsCard(card, accent, textPrimary, textSecondary),
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

  Widget _buildHeaderCard(
    Color card,
    Color accent,
    Color textPrimary,
    Color textSecondary,
  ) {
    return GestureDetector(
      onTap: _openEdit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: accent.withValues(alpha: 0.15),
              child: Text(
                _initials(_profile.name),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 18, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    Color card,
    Color accent,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Your Info",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openEdit,
                child: Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 22,
            runSpacing: 16,
            children: [
              _infoStat("Age", "${_profile.age}", textPrimary, textSecondary),
              _infoStat(
                "Height",
                "${_profile.heightCm} cm",
                textPrimary,
                textSecondary,
              ),
              _infoStat(
                "Weight",
                "${_profile.weightKg.toStringAsFixed(0)} kg",
                textPrimary,
                textSecondary,
              ),
              _infoStat("Gender", _profile.gender, textPrimary, textSecondary),
              _infoStat(
                "Days/Week",
                "${_profile.daysPerWeek}",
                textPrimary,
                textSecondary,
              ),
              _infoStat(
                "Session",
                "${_profile.sessionMinutes} min",
                textPrimary,
                textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text("Goal", style: TextStyle(fontSize: 12, color: textSecondary)),
          const SizedBox(height: 6),
          Text(
            _profile.secondaryGoal.isEmpty
                ? _profile.primaryGoal
                : "${_profile.primaryGoal} · ${_profile.secondaryGoal}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Target Body Parts",
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile.targetBodyParts
                .map(
                  (part) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      part,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoStat(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFriendsCard(
    Color card,
    Color accent,
    Color textPrimary,
    Color textSecondary,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FriendsScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.groups_rounded, color: accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Friends",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Find workout partners, manage requests.",
                    style: TextStyle(fontSize: 12.5, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(
    Color card,
    Color accent,
    Color textSecondary,
    bool isDark,
  ) {
    const items = [
      (icon: Icons.home_rounded, label: "Home"),
      (icon: Icons.restaurant_menu_rounded, label: "Nutrition"),
      (icon: Icons.show_chart_rounded, label: "Progress"),
      (icon: Icons.person_rounded, label: "Profile"),
    ];

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
          children: List.generate(items.length, (index) {
            final selected = index == navIndex;
            final item = items[index];

            return GestureDetector(
              onTap: () {
                if (index == navIndex) return;
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
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: 0.12)
                      : Colors.transparent,
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
