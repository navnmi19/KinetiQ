import 'package:flutter/material.dart';
import 'body_metrics_screen.dart';
import'package:gym_app/widgets/background_decoration.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  static const Color mint50 = Color(0xFFD1FAE5);
  static const Color mint25 = Color(0xFFECFDF5);
  static const Color green = Color(0xFF22C55E);
  static const Color darkText = Color(0xFF14532D);

  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();

  int age = 19;
  static const int minAge = 13;
  static const int maxAge = 100;

  bool isNameFocused = false;
  String? gender;

  String? get ageError {
    if (age < minAge) return "Age must be at least $minAge";
    if (age > maxAge) return "Age must be at most $maxAge";
    return null;
  }

  bool get isFormValid =>
      nameController.text.trim().isNotEmpty &&
      gender != null &&
      ageError == null;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() => setState(() {}));
    nameFocusNode.addListener(() {
      setState(() => isNameFocused = nameFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!isFormValid) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BodyMetricsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? size.width * 0.15 : 25.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mint50, mint25, Colors.white],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background silhouettes
            const BackgroundDecorations(),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top - 48,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildBrandHeader(),
                      const SizedBox(height: 36),
                      _buildMainCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.fitness_center, color: green, size: 34),
            SizedBox(width: 10),
            Text(
              "GYMIN",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: darkText,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: "Stronger ",
                style: TextStyle(color: green, fontWeight: FontWeight.w700),
              ),
              TextSpan(text: "every day."),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: mint25,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center, color: green, size: 26),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Welcome",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              "Let's get to know you better.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _fieldLabel(Icons.person_outline, "Your Name"),
          const SizedBox(height: 10),
          _buildNameField(),

          const SizedBox(height: 26),

          _fieldLabel(Icons.wc_outlined, "Gender"),
          const SizedBox(height: 10),
          _buildGenderSelector(),

          const SizedBox(height: 26),

          _fieldLabel(Icons.calendar_today_outlined, "Your Age"),
          const SizedBox(height: 10),
          _buildAgeSelector(),
          const SizedBox(height: 10),
          Text(
            ageError ?? "We use this to personalize your experience",
            style: TextStyle(
              fontSize: 13,
              color: ageError != null ? Colors.red : Colors.black45,
            ),
          ),

          const SizedBox(height: 32),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _fieldLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: green),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isNameFocused
            ? [
                BoxShadow(
                  color: green.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: TextField(
        controller: nameController,
        focusNode: nameFocusNode,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(fontSize: 16, color: darkText),
        decoration: InputDecoration(
          hintText: "Enter your name",
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(
            Icons.person_outline,
            color: isNameFocused ? green : Colors.black38,
          ),
          filled: true,
          fillColor: mint25.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: green, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    const options = [
      {'label': 'Male', 'icon': Icons.male},
      {'label': 'Female', 'icon': Icons.female},
      {'label': 'Other', 'icon': Icons.transgender},
    ];

    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: _genderOption(
              label: option['label'] as String,
              icon: option['icon'] as IconData,
            ),
          ),
          if (option != options.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _genderOption({required String label, required IconData icon}) {
    final bool selected = gender == label;

    return GestureDetector(
      onTap: () => setState(() => gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: mint25.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? green : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: green.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? green : Colors.black38, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? darkText : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: mint25.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ageStepButton(Icons.remove_rounded, () => _changeAge(-1)),
          GestureDetector(
            onTap: _editAge,
            child: Text(
              "$age",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
          ),
          _ageStepButton(Icons.add_rounded, () => _changeAge(1)),
        ],
      ),
    );
  }

  Widget _ageStepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: green, size: 20),
      ),
    );
  }

  void _changeAge(int delta) {
    setState(() => age = (age + delta).clamp(1, 130));
  }

  Future<void> _editAge() async {
    final controller = TextEditingController(text: "$age");
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Enter your age",
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 20, color: darkText),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text(
              "Done",
              style: TextStyle(color: green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (result != null) setState(() => age = result);
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _onContinue,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isFormValid ? green : green.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isFormValid
              ? [
                  BoxShadow(
                    color: green.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Continue",
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Large, low-opacity decorative silhouettes placed around the screen edges.
/// Approximated with Material icons rather than hand-drawn stick figures.
