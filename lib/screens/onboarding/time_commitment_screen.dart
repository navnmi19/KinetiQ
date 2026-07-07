import 'package:flutter/material.dart';
import 'capability_assessment_screen.dart';

class TimeCommitmentScreen extends StatefulWidget {
  const TimeCommitmentScreen({super.key});

  @override
  State<TimeCommitmentScreen> createState() =>
      _TimeCommitmentScreenState();
}

class _TimeCommitmentScreenState
    extends State<TimeCommitmentScreen> {

  int? selectedDays;
  int? selectedDuration;
  String? selectedTime;

  String recommendationTitle = "";
  String recommendationText = "";

  final List<int> daysOptions = [2, 3, 4, 5, 6, 7];

  final List<int> durationOptions = [
    20,
    30,
    45,
    60,
    90
  ];

  final List<String> timeOptions = [
    "Morning",
    "Afternoon",
    "Evening",
    "Flexible"
  ];

  void updateRecommendation() {

    if (selectedDays == null ||
        selectedDuration == null) {
      recommendationTitle = "";
      recommendationText = "";
      return;
    }

    // 2 day cases
    if (selectedDays == 2 &&
        selectedDuration == 20) {

      recommendationTitle =
          "Consistency Foundation";

      recommendationText =
          "This is a minimal but valuable starting point. Expect improvements in energy, movement quality and general fitness. Building the habit matters most here.";
    }

    else if (selectedDays == 2) {

      recommendationTitle =
          "Efficient Training";

      recommendationText =
          "Two focused sessions per week can still deliver noticeable improvements when consistency is maintained.";
    }

    // 3 day cases
    else if (selectedDays == 3 &&
        selectedDuration! <= 45) {

      recommendationTitle =
          "Classic Beginner Setup";

      recommendationText =
          "Perfect for full body programs and steady progress while keeping recovery simple.";
    }

    else if (selectedDays == 3) {

      recommendationTitle =
          "Balanced Progress";

      recommendationText =
          "Three quality sessions per week are enough for impressive long term results.";
    }

    // 4 day cases
    else if (selectedDays == 4) {

      recommendationTitle =
          "Excellent Balance";

      recommendationText =
          "One of the best combinations of progress, recovery and sustainability.";
    }

    // 5 day cases
    else if (selectedDays == 5) {

      recommendationTitle =
          "Growth Focused";

      recommendationText =
          "Great for muscle growth and strength progression while maintaining good recovery.";
    }

    // 6 day cases
    else if (selectedDays == 6 &&
        selectedDuration! >= 90) {

      recommendationTitle =
          "Advanced Commitment";

      recommendationText =
          "This level of commitment allows specialization and rapid progression. Recovery, sleep and nutrition become essential.";
    }

    else if (selectedDays == 6) {

      recommendationTitle =
          "Serious Training";

      recommendationText =
          "A six day schedule allows focused training for every muscle group while maintaining high weekly volume.";
    }

    // 7 day cases
    else if (selectedDays == 7) {

      recommendationTitle =
          "Maximum Frequency";

      recommendationText =
          "Training every day requires careful fatigue management and smart programming.";
    }

    else {

      recommendationTitle =
          "Customized Program";

      recommendationText =
          "We'll build a program optimized around your available time.";
    }
  }

  // ---------------------------------------------------------------------
  // UI HELPERS (visual only — no state/logic changes below this point)
  // ---------------------------------------------------------------------

  Widget _buildOptionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 56,
          alignment: Alignment.center,
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF16803C)
                    : Colors.black87,
              ),
            ),
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

    final bool showRecommendation =
        selectedDays != null && selectedDuration != null;

    // Combine the existing title + text into a single, two-line-safe
    // string for the redesigned card. No recommendation data is changed.
    final String recommendationDisplay = recommendationTitle.isEmpty
        ? ""
        : "$recommendationTitle! $recommendationText";

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

                // Back arrow (visual only, no navigation logic changes
                // beyond a standard pop)
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
                          "How much time can you\nrealistically commit?",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Animated recommendation card
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
                                  height: 95,
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16),
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
                                        child: Text(
                                          recommendationDisplay,
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.black,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey("no_recommendation"),
                                ),
                        ),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          "Days per week",
                          "How many days can you realistically train?",
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: daysOptions.map((days) {
                            final bool selected =
                                selectedDays == days;

                            return _buildOptionChip(
                              label: "$days",
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  selectedDays = days;
                                  updateRecommendation();
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          "Hours per session",
                          "How much time can you dedicate per session?",
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: durationOptions.map((duration) {
                            final bool selected =
                                selectedDuration == duration;

                            return _buildOptionChip(
                              label: duration == 90
                                  ? "90 min"
                                  : "$duration min",
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  selectedDuration = duration;
                                  updateRecommendation();
                                });
                              },
                            );
                          }).toList(),
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
                              const ExperienceScreen(),
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