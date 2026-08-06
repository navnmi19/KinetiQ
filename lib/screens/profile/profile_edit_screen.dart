import 'package:flutter/material.dart';
import 'profile_screen.dart';

/// Editable form for [UserProfileData]. Pops with the edited copy on Save,
/// or null on back — [ProfileScreen] owns the actual state.
class ProfileEditScreen extends StatefulWidget {
  final UserProfileData profile;
  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  static const Color green = Color(0xFF22C55E);
  static const Color darkText = Color(0xFF14532D);
  static const Color fieldBg = Color(0xFFECFDF5);

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

  static const List<String> _genderOptions = ["Male", "Female", "Other"];
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

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.name);
    _bioController = TextEditingController(text: p.bio);
    _gender = p.gender;
    _age = p.age;
    _heightCm = p.heightCm;
    _weightKg = p.weightKg;
    _primaryGoal = p.primaryGoal;
    _secondaryGoal = p.secondaryGoal;
    _targetBodyParts = p.targetBodyParts.toSet();
    _daysPerWeek = p.daysPerWeek;
    _sessionMinutes = p.sessionMinutes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

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
        targetBodyParts: _targetBodyParts.toList(),
        daysPerWeek: _daysPerWeek,
        sessionMinutes: _sessionMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              "Save",
              style: TextStyle(color: green, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label("Name"),
            const SizedBox(height: 8),
            _textField(_nameController, "Your name"),
            const SizedBox(height: 20),
            _label("About"),
            const SizedBox(height: 8),
            _textField(
              _bioController,
              "Say something about yourself",
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _label("Gender"),
            const SizedBox(height: 8),
            _chipRow(_genderOptions, _gender, (v) => setState(() => _gender = v)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _stepperField(
                    "Age",
                    _age,
                    (d) => setState(() => _age = (_age + d).clamp(13, 100)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _stepperField(
                    "Height (cm)",
                    _heightCm,
                    (d) => setState(
                      () => _heightCm = (_heightCm + d).clamp(120, 220),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _stepperField(
                    "Weight (kg)",
                    _weightKg.round(),
                    (d) => setState(
                      () => _weightKg = (_weightKg + d).clamp(35, 200),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _stepperField(
                    "Days / Week",
                    _daysPerWeek,
                    (d) => setState(
                      () => _daysPerWeek = (_daysPerWeek + d).clamp(1, 7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _stepperField(
              "Session Length (min)",
              _sessionMinutes,
              (d) => setState(
                () => _sessionMinutes = (_sessionMinutes + d * 15).clamp(
                  15,
                  120,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label("Primary Goal"),
            const SizedBox(height: 8),
            _chipWrap(
              _goalOptions,
              {_primaryGoal},
              (v) => setState(() => _primaryGoal = v),
            ),
            const SizedBox(height: 20),
            _label("Secondary Goal"),
            const SizedBox(height: 8),
            _chipWrap(
              _goalOptions,
              {_secondaryGoal},
              (v) => setState(() => _secondaryGoal = v),
            ),
            const SizedBox(height: 20),
            _label("Target Body Parts"),
            const SizedBox(height: 8),
            _chipWrap(_bodyPartOptions, _targetBodyParts, (v) {
              setState(() {
                if (_targetBodyParts.contains(v)) {
                  _targetBodyParts.remove(v);
                } else {
                  _targetBodyParts.add(v);
                }
              });
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: darkText,
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: darkText),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _chipRow(
    List<String> options,
    String selectedValue,
    ValueChanged<String> onSelect,
  ) {
    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fieldBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selectedValue == option
                        ? green
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: selectedValue == option
                      ? [
                          BoxShadow(
                            color: green.withValues(alpha: 0.25),
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
                    fontWeight: FontWeight.w700,
                    color: selectedValue == option ? green : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          if (option != options.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _chipWrap(
    List<String> options,
    Set<String> selected,
    ValueChanged<String> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: fieldBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? green : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: green.withValues(alpha: 0.25),
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
                fontWeight: FontWeight.w700,
                color: isSelected ? green : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _stepperField(String label, num value, void Function(int delta) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: fieldBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepIcon(Icons.remove_rounded, () => onChange(-1)),
              Text(
                "$value",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              _stepIcon(Icons.add_rounded, () => onChange(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: green),
      ),
    );
  }
}
