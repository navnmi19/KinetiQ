import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '/themes/theme_controller.dart';

/// Editable form for [UserProfileData].
/// Pops with the edited copy on Save,
/// or null on back — [ProfileScreen] owns the actual state.
class ProfileEditScreen extends StatefulWidget {
  final UserProfileData profile;

  const ProfileEditScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileEditScreen> createState() =>
      _ProfileEditScreenState();
}

class _ProfileEditScreenState
    extends State<ProfileEditScreen> {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  static const Color lightGreen =
      Color(0xFF22C55E);

  static const Color lightDarkText =
      Color(0xFF14532D);

  static const Color lightFieldBg =
      Color(0xFFECFDF5);

  // ============================================================
  // DARK THEME
  // ============================================================

  static const Color darkOrange =
      Color(0xFFFF8A00);

  static const Color darkBackground =
      Color(0xFF000000);

  static const Color darkCard =
      Color(0xFF151515);

  static const Color darkField =
      Color(0xFF202020);

  // ============================================================
  // CONTROLLERS / DATA
  // ============================================================

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  late String _gender;
  late int _age;
  late int _heightCm;
  late double _weightKg;
  late String _primaryGoal;
  late String _secondaryGoal;
  late Set<String> _targetBodyParts;
  late int _daysPerWeek;
  late int _sessionMinutes;

  static const List<String> _genderOptions = [
    "Male",
    "Female",
    "Other",
  ];

  static const List<String> _goalOptions = [
    "Build Muscle",
    "Lose Fat",
    "Body Recomposition",
    "Improve Fitness",
    "General Health",
    "Athletic Performance",
  ];

  static const List<String> _bodyPartOptions = [
    "Chest",
    "Back",
    "Legs",
    "Shoulders",
    "Arms",
    "Core",
    "Glutes",
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final p = widget.profile;

    _nameController =
        TextEditingController(text: p.name);

    _bioController =
        TextEditingController(text: p.bio);

    _gender = p.gender;
    _age = p.age;
    _heightCm = p.heightCm;
    _weightKg = p.weightKg;
    _primaryGoal = p.primaryGoal;
    _secondaryGoal = p.secondaryGoal;
    _targetBodyParts =
        p.targetBodyParts.toSet();
    _daysPerWeek = p.daysPerWeek;
    _sessionMinutes = p.sessionMinutes;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _save() {
    Navigator.pop(
      context,
      widget.profile.copyWith(
        name: _nameController.text.trim().isEmpty
            ? widget.profile.name
            : _nameController.text.trim(),

        bio: _bioController.text.trim(),

        gender: _gender,

        age: _age,

        heightCm: _heightCm,

        weightKg: _weightKg,

        primaryGoal: _primaryGoal,

        secondaryGoal: _secondaryGoal,

        targetBodyParts:
            _targetBodyParts.toList(),

        daysPerWeek: _daysPerWeek,

        sessionMinutes: _sessionMinutes,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,

      builder: (
        context,
        mode,
        child,
      ) {
        final bool isDark =
            mode == ThemeMode.dark;

        // ========================================================
        // CURRENT THEME COLORS
        // ========================================================

        final Color accent = isDark
            ? darkOrange
            : lightGreen;

        final Color background = isDark
            ? darkBackground
            : Colors.white;

        final Color cardBackground = isDark
            ? darkCard
            : Colors.white;

        final Color fieldBackground = isDark
            ? darkField
            : lightFieldBg;

        final Color primaryText = isDark
            ? Colors.white
            : lightDarkText;

        final Color secondaryText = isDark
            ? Colors.white70
            : Colors.black54;

        return Scaffold(
          backgroundColor: background,

          // ======================================================
          // APP BAR
          // ======================================================

          appBar: AppBar(
            backgroundColor: background,

            elevation: 0,

            iconTheme: IconThemeData(
              color: primaryText,
            ),

            title: Text(
              "Edit Profile",

              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),

            actions: [
              TextButton(
                onPressed: _save,

                child: Text(
                  "Save",

                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          // ======================================================
          // BODY
          // ======================================================

          body: SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.all(20),

              children: [
                // ==================================================
                // NAME
                // ==================================================

                _label(
                  "Name",
                  primaryText,
                ),

                const SizedBox(height: 8),

                _textField(
                  _nameController,
                  "Your name",
                  fieldBackground,
                  primaryText,
                  secondaryText,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // ABOUT
                // ==================================================

                _label(
                  "About",
                  primaryText,
                ),

                const SizedBox(height: 8),

                _textField(
                  _bioController,
                  "Say something about yourself",
                  fieldBackground,
                  primaryText,
                  secondaryText,
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // GENDER
                // ==================================================

                _label(
                  "Gender",
                  primaryText,
                ),

                const SizedBox(height: 8),

                _chipRow(
                  _genderOptions,
                  _gender,
                  (v) {
                    setState(() {
                      _gender = v;
                    });
                  },
                  fieldBackground,
                  primaryText,
                  secondaryText,
                  accent,
                  isDark,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // AGE + HEIGHT
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: _stepperField(
                        "Age",
                        _age,
                        (d) {
                          setState(() {
                            _age =
                                (_age + d)
                                    .clamp(13, 100);
                          });
                        },
                        fieldBackground,
                        primaryText,
                        secondaryText,
                        accent,
                        isDark,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _stepperField(
                        "Height (cm)",
                        _heightCm,
                        (d) {
                          setState(() {
                            _heightCm =
                                (_heightCm + d)
                                    .clamp(120, 220);
                          });
                        },
                        fieldBackground,
                        primaryText,
                        secondaryText,
                        accent,
                        isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ==================================================
                // WEIGHT + DAYS
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: _stepperField(
                        "Weight (kg)",
                        _weightKg.round(),
                        (d) {
                          setState(() {
                            _weightKg =
                                (_weightKg + d)
                                    .clamp(35, 200);
                          });
                        },
                        fieldBackground,
                        primaryText,
                        secondaryText,
                        accent,
                        isDark,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: _stepperField(
                        "Days / Week",
                        _daysPerWeek,
                        (d) {
                          setState(() {
                            _daysPerWeek =
                                (_daysPerWeek + d)
                                    .clamp(1, 7);
                          });
                        },
                        fieldBackground,
                        primaryText,
                        secondaryText,
                        accent,
                        isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ==================================================
                // SESSION LENGTH
                // ==================================================

                _stepperField(
                  "Session Length (min)",
                  _sessionMinutes,
                  (d) {
                    setState(() {
                      _sessionMinutes =
                          (_sessionMinutes +
                                  d * 15)
                              .clamp(15, 120);
                    });
                  },
                  fieldBackground,
                  primaryText,
                  secondaryText,
                  accent,
                  isDark,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PRIMARY GOAL
                // ==================================================

                _label(
                  "Primary Goal",
                  primaryText,
                ),

                const SizedBox(height: 8),

                _chipWrap(
                  _goalOptions,
                  {_primaryGoal},
                  (v) {
                    setState(() {
                      _primaryGoal = v;
                    });
                  },
                  fieldBackground,
                  primaryText,
                  secondaryText,
                  accent,
                  isDark,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // SECONDARY GOAL
                // ==================================================

                _label(
                  "Secondary Goal",
                  primaryText,
                ),

                const SizedBox(height: 8),

                _chipWrap(
                  _goalOptions,
                  {_secondaryGoal},
                  (v) {
                    setState(() {
                      _secondaryGoal = v;
                    });
                  },
                  fieldBackground,
                  primaryText,
                  secondaryText,
                  accent,
                  isDark,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TARGET BODY PARTS
                // ==================================================

                _label(
                  "Target Body Parts",
                  primaryText,
                ),

                const SizedBox(height: 8),

                _chipWrap(
                  _bodyPartOptions,
                  _targetBodyParts,
                  (v) {
                    setState(() {
                      if (_targetBodyParts
                          .contains(v)) {
                        _targetBodyParts
                            .remove(v);
                      } else {
                        _targetBodyParts
                            .add(v);
                      }
                    });
                  },
                  fieldBackground,
                  primaryText,
                  secondaryText,
                  accent,
                  isDark,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(
    String text,
    Color color,
  ) {
    return Text(
      text,

      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField(
    TextEditingController controller,
    String hint,
    Color background,
    Color textColor,
    Color hintColor, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),

      child: TextField(
        controller: controller,

        maxLines: maxLines,

        style: TextStyle(
          fontSize: 15,
          color: textColor,
        ),

        cursorColor:
            ThemeController.mode.value ==
                    ThemeMode.dark
                ? darkOrange
                : lightGreen,

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(
            color: hintColor,
          ),

          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GENDER CHIP ROW
  // ============================================================

  Widget _chipRow(
    List<String> options,
    String selectedValue,
    ValueChanged<String> onSelect,
    Color fieldBackground,
    Color primaryText,
    Color secondaryText,
    Color accent,
    bool isDark,
  ) {
    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  onSelect(option),

              child: AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 200,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: fieldBackground,

                  borderRadius:
                      BorderRadius.circular(14),

                  border: Border.all(
                    color:
                        selectedValue ==
                                option
                            ? accent
                            : Colors.transparent,

                    width: 1.5,
                  ),

                  boxShadow:
                      selectedValue ==
                              option
                          ? [
                              BoxShadow(
                                color: accent
                                    .withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                ),

                child: Text(
                  option,

                  style: TextStyle(
                    fontSize: 13,

                    fontWeight:
                        FontWeight.w700,

                    color:
                        selectedValue ==
                                option
                            ? accent
                            : secondaryText,
                  ),
                ),
              ),
            ),
          ),

          if (option != options.last)
            const SizedBox(width: 10),
        ],
      ],
    );
  }

  // ============================================================
  // CHIP WRAP
  // ============================================================

  Widget _chipWrap(
    List<String> options,
    Set<String> selected,
    ValueChanged<String> onSelect,
    Color fieldBackground,
    Color primaryText,
    Color secondaryText,
    Color accent,
    bool isDark,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,

      children: options.map((option) {
        final bool isSelected =
            selected.contains(option);

        return GestureDetector(
          onTap: () =>
              onSelect(option),

          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 200,
            ),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(
                      alpha: isDark
                          ? 0.16
                          : 0.10,
                    )
                  : fieldBackground,

              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(
                color: isSelected
                    ? accent
                    : Colors.transparent,

                width: 1.5,
              ),

              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accent
                            .withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),

            child: Text(
              option,

              style: TextStyle(
                fontSize: 12.5,

                fontWeight:
                    FontWeight.w700,

                color: isSelected
                    ? accent
                    : secondaryText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // STEPPER FIELD
  // ============================================================

  Widget _stepperField(
    String label,
    num value,
    void Function(int delta) onChange,
    Color fieldBackground,
    Color primaryText,
    Color secondaryText,
    Color accent,
    bool isDark,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: fieldBackground,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: TextStyle(
              fontSize: 11,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              _stepIcon(
                Icons.remove_rounded,
                () => onChange(-1),
                accent,
                isDark,
              ),

              Text(
                "$value",

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                  color: primaryText,
                ),
              ),

              _stepIcon(
                Icons.add_rounded,
                () => onChange(1),
                accent,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEPPER ICON
  // ============================================================

  Widget _stepIcon(
    IconData icon,
    VoidCallback onTap,
    Color accent,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 30,
        height: 30,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : Colors.white,

          shape: BoxShape.circle,

          border: Border.all(
            color: accent.withValues(
              alpha: 0.25,
            ),
          ),

          boxShadow: [
            BoxShadow(
              color: accent.withValues(
                alpha: 0.12,
              ),
              blurRadius: 8,
            ),
          ],
        ),

        child: Icon(
          icon,
          size: 16,
          color: accent,
        ),
      ),
    );
  }
}