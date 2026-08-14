import 'package:flutter/material.dart';
import 'body_metrics_screen.dart';
import 'package:gym_app/widgets/background_decoration.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  // ------------------------------------------------------------
  // DARK THEME COLORS
  // ------------------------------------------------------------

  static const Color orange = Color(0xFFFF8A00);

  // Background gradient
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color backgroundDark = Color(0xFF080808);

  // Main card
  static const Color cardColor = Color(0xFF151515);

  // Input / selector boxes
  static const Color fieldColor = Color(0xFF202020);

  // Text
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFFBDBDBD);
  static const Color mutedText = Color(0xFF777777);

  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();

  int age = 19;

  static const int minAge = 13;
  static const int maxAge = 100;

  bool isNameFocused = false;
  String? gender;

  // ------------------------------------------------------------
  // VALIDATION
  // ------------------------------------------------------------

  String? get ageError {
    if (age < minAge) return "Age must be at least $minAge";
    if (age > maxAge) return "Age must be at most $maxAge";
    return null;
  }

  bool get isFormValid =>
      nameController.text.trim().isNotEmpty &&
      gender != null &&
      ageError == null;

  // ------------------------------------------------------------
  // INIT / DISPOSE
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void _onContinue() {
    if (!isFormValid) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BodyMetricsScreen(),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final horizontalPadding = isTablet ? size.width * 0.15 : 25.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // BLACK → DARK GRAY → BLACK
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundBlack,
              backgroundDark,
              backgroundBlack,
            ],
            stops: [
              0.0,
              0.5,
              1.0,
            ],
          ),
        ),

        child: Stack(
          children: [
            // Decorative orange silhouettes
            const BackgroundDecorations(),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        size.height -
                        MediaQuery.of(context).padding.top -
                        48,
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

  // ------------------------------------------------------------
  // BRAND HEADER
  // ------------------------------------------------------------

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // WHITE DUMBBELL
            Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 34,
            ),

            SizedBox(width: 10),

            // ORANGE APP NAME
            Text(
              "KinetiQ",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: orange,
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
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: "Stronger ",
                style: TextStyle(
                  color: orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: "every day.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // MAIN CARD
  // ------------------------------------------------------------

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        // Distinguishable from black background
        color: cardColor,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // TOP ICON
          // ------------------------------------------------------

          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: fieldColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                color: orange,
                size: 26,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------------
          // WELCOME
          // ------------------------------------------------------

          const Center(
            child: Text(
              "Welcome",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryText,
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
                color: secondaryText,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ------------------------------------------------------
          // NAME
          // ------------------------------------------------------

          _fieldLabel(
            Icons.person_outline,
            "Your Name",
          ),

          const SizedBox(height: 10),

          _buildNameField(),

          const SizedBox(height: 26),

          // ------------------------------------------------------
          // GENDER
          // ------------------------------------------------------

          _fieldLabel(
            Icons.wc_outlined,
            "Gender",
          ),

          const SizedBox(height: 10),

          _buildGenderSelector(),

          const SizedBox(height: 26),

          // ------------------------------------------------------
          // AGE
          // ------------------------------------------------------

          _fieldLabel(
            Icons.calendar_today_outlined,
            "Your Age",
          ),

          const SizedBox(height: 10),

          _buildAgeSelector(),

          const SizedBox(height: 10),

          Text(
            ageError ??
                "We use this to personalize your experience",
            style: TextStyle(
              fontSize: 13,
              color: ageError != null
                  ? Colors.redAccent
                  : mutedText,
            ),
          ),

          const SizedBox(height: 32),

          // ------------------------------------------------------
          // CONTINUE
          // ------------------------------------------------------

          _buildContinueButton(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FIELD LABEL
  // ------------------------------------------------------------

  Widget _fieldLabel(
    IconData icon,
    String label,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: orange,
        ),

        const SizedBox(width: 8),

        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // NAME FIELD
  // ------------------------------------------------------------

  Widget _buildNameField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        // ORANGE GLOW WHEN CLICKED
        boxShadow: isNameFocused
            ? [
                BoxShadow(
                  color: orange.withValues(alpha: 0.30),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),

      child: TextField(
        controller: nameController,
        focusNode: nameFocusNode,

        textCapitalization: TextCapitalization.words,

        style: const TextStyle(
          fontSize: 16,
          color: primaryText,
        ),

        decoration: InputDecoration(
          hintText: "Enter your name",

          hintStyle: const TextStyle(
            color: mutedText,
          ),

          prefixIcon: Icon(
            Icons.person_outline,
            color: isNameFocused
                ? orange
                : mutedText,
          ),

          filled: true,

          // LIGHTER BLACK FIELD
          fillColor: fieldColor,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          // ORANGE BORDER WHEN FOCUSED
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: orange,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // GENDER SELECTOR
  // ------------------------------------------------------------

  Widget _buildGenderSelector() {
    const options = [
      {
        'label': 'Male',
        'icon': Icons.male,
      },
      {
        'label': 'Female',
        'icon': Icons.female,
      },
      {
        'label': 'Other',
        'icon': Icons.transgender,
      },
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

          if (option != options.last)
            const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _genderOption({
    required String label,
    required IconData icon,
  }) {
    final bool selected = gender == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          gender = label;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,

        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),

        decoration: BoxDecoration(
          color: fieldColor,

          borderRadius: BorderRadius.circular(16),

          // ORANGE BORDER WHEN SELECTED
          border: Border.all(
            color: selected
                ? orange
                : Colors.transparent,
            width: 1.5,
          ),

          // ORANGE GLOW WHEN SELECTED
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: orange.withValues(alpha: 0.30),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? orange
                  : mutedText,
              size: 22,
            ),

            const SizedBox(height: 6),

            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? primaryText
                    : secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // AGE SELECTOR
  // ------------------------------------------------------------

  Widget _buildAgeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),

      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ageStepButton(
            Icons.remove_rounded,
            () => _changeAge(-1),
          ),

          GestureDetector(
            onTap: _editAge,
            child: Text(
              "$age",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
          ),

          _ageStepButton(
            Icons.add_rounded,
            () => _changeAge(1),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // AGE +/- BUTTON
  // ------------------------------------------------------------

  Widget _ageStepButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 44,
        height: 44,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Icon(
          icon,
          color: orange,
          size: 20,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CHANGE AGE
  // ------------------------------------------------------------

  void _changeAge(int delta) {
    setState(() {
      age = (age + delta).clamp(1, 130);
    });
  }

  // ------------------------------------------------------------
  // EDIT AGE DIALOG
  // ------------------------------------------------------------

  Future<void> _editAge() async {
    final controller = TextEditingController(
      text: "$age",
    );

    final result = await showDialog<int>(
      context: context,

      builder: (context) => AlertDialog(
        backgroundColor: cardColor,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        title: const Text(
          "Enter your age",
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),

        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,

          style: const TextStyle(
            fontSize: 20,
            color: primaryText,
          ),

          decoration: InputDecoration(
            filled: true,
            fillColor: fieldColor,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: orange,
                width: 1.5,
              ),
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: secondaryText,
              ),
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                int.tryParse(
                  controller.text.trim(),
                ),
              );
            },

            child: const Text(
              "Done",
              style: TextStyle(
                color: orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        age = result;
      });
    }
  }

  // ------------------------------------------------------------
  // CONTINUE BUTTON
  // ------------------------------------------------------------

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _onContinue,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,

        width: double.infinity,
        height: 56,

        decoration: BoxDecoration(
          color: isFormValid
              ? orange
              : orange.withValues(alpha: 0.35),

          borderRadius: BorderRadius.circular(18),

          boxShadow: isFormValid
              ? [
                  BoxShadow(
                    color: orange.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
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

            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}