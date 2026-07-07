import 'package:flutter/material.dart';
import'training_setup_screen.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {

  String? pushups;
  String? squats;
  String? pullups;
  String? familiarity;

  String title = "";
  String description = "";

  final List<String> pushupOptions = [
    "0-5",
    "5-15",
    "15-30",
    "30-50",
    "50+"
  ];

  final List<String> squatOptions = [
    "0-10",
    "10-25",
    "25-50",
    "50-100",
    "100+"
  ];

  final List<String> pullupOptions = [
    "0",
    "1-3",
    "4-8",
    "9-15",
    "15+"
  ];

  final List<String> familiarityOptions = [
    "Mostly New To Me",
    "Know The Basics",
    "Comfortable With Most Exercises",
    "Very Comfortable"
  ];

  void updateRecommendation() {

    if (pushups == null ||
        squats == null ||
        pullups == null ||
        familiarity == null) {
      title = "";
      description = "";
      return;
    }

    if (pushups == "0-5" &&
        pullups == "0" &&
        familiarity == "Mostly New To Me") {

      title = "Building Foundations";

      description =
          "Everyone starts somewhere. We'll build your strength gradually with proper technique and consistent progression.";
    }

    else if (
        (pushups == "15-30" || pushups == "30-50") &&
        (pullups == "1-3" || pullups == "4-8")) {

      title = "Solid Foundation";

      description =
          "You've built a solid foundation. Your program will focus on progressive overload while maintaining proper recovery.";
    }

    else if (
        pushups == "50+" &&
        pullups == "15+" &&
        familiarity == "Very Comfortable") {

      title = "Performance Focus";

      description =
          "Strong numbers across the board. We'll shift toward specialization, advanced progression and performance optimization.";
    }

    else {

      title = "Personalized Progression";

      description =
          "We'll guide you step by step, matching your program to your current capabilities and experience level.";
    }
  }

  // ---------------------------------------------------------------------
  // UI HELPERS (visual only — no state/logic changes below this point)
  // ---------------------------------------------------------------------

  Widget buildChip(
      String text,
      String? selectedValue,
      Function(String) onSelect) {

    final bool selected = selectedValue == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          onSelect(text);
          updateRecommendation();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF22C55E).withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF22C55E)
                : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? const Color(0xFF16803C)
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final bool showRecommendation = title.isNotEmpty;

    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1FAE5),
              Colors.white,
            ],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Back arrow (visual only, standard pop navigation)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Scrollable content so nothing overflows on any
                // phone size. Continue button stays fixed below.
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Current Capability",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Help us understand your current fitness level.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Animated AI Coach recommendation card
                        AnimatedSwitcher(
                          duration:
                              const Duration(milliseconds: 300),
                          transitionBuilder:
                              (child, animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0, -0.04),
                              end: Offset.zero,
                            ).animate(animation);

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: showRecommendation
                              ? Container(
                                  key: const ValueKey(
                                      "recommendation_card"),
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    border: Border.all(
                                      color:
                                          const Color(0xFF22C55E),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                                0xFF22C55E)
                                            .withOpacity(0.08),
                                        blurRadius: 12,
                                        offset:
                                            const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'assets/images/bodyparts/bicep.png',
                                        height: 42,
                                        errorBuilder: (context,
                                                error,
                                                stackTrace) =>
                                            const Icon(
                                          Icons
                                              .fitness_center_rounded,
                                          size: 38,
                                          color:
                                              Color(0xFF22C55E),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            const Text(
                                              "AI Coach Recommendation",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                                color:
                                                    Colors.black,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 6),
                                            Text(
                                              description,
                                              maxLines: 3,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style:
                                                  const TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight
                                                        .w500,
                                                color: Colors
                                                    .black87,
                                                height: 1.25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey("no_recommendation"),
                                ),
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          "Comfortable Pushups",
                          "How many can you comfortably do in one set?",
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: pushupOptions
                              .map((option) => buildChip(
                                  option,
                                  pushups,
                                  (v) => pushups = v))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          "Comfortable Bodyweight Squats",
                          "How many can you comfortably do in one set?",
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: squatOptions
                              .map((option) => buildChip(
                                  option,
                                  squats,
                                  (v) => squats = v))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          "Comfortable Pullups",
                          "How many can you comfortably do in one set?",
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: pullupOptions
                              .map((option) => buildChip(
                                  option,
                                  pullups,
                                  (v) => pullups = v))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          "Gym Familiarity",
                          "How familiar are you with gym equipment and exercises?",
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: familiarityOptions
                              .map((option) => buildChip(
                                  option,
                                  familiarity,
                                  (v) => familiarity = v))
                              .toList(),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Continue button — always fixed at the bottom
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TrainingSetupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}