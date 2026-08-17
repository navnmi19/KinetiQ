import 'package:flutter/material.dart';
import 'capability_assessment_screen.dart';
import 'package:gym_app/widgets/background_decoration.dart';
import 'package:gym_app/widgets/creative_value_picker.dart';

class TimeCommitmentScreen extends StatefulWidget {
  const TimeCommitmentScreen({super.key});

  @override
  State<TimeCommitmentScreen> createState() =>
      _TimeCommitmentScreenState();
}

class _TimeCommitmentScreenState
    extends State<TimeCommitmentScreen> {
  // ============================================================
  // KINETIQ DARK THEME
  // ============================================================

  static const Color orange = Color(0xFFFF8A00);
  static const Color background = Color(0xFF000000);
  static const Color backgroundMid = Color(0xFF080808);
  static const Color cardColor = Color(0xFF151515);
  static const Color fieldColor = Color(0xFF202020);

  // ============================================================
  // STATE
  // ============================================================

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
    90,
  ];

  final List<String> timeOptions = [
    "Morning",
    "Afternoon",
    "Evening",
    "Flexible",
  ];

  // ============================================================
  // RECOMMENDATION LOGIC
  // ============================================================

  void updateRecommendation() {
    if (selectedDays == null ||
        selectedDuration == null) {
      recommendationTitle = "";
      recommendationText = "";
      return;
    }

    if (selectedDays == 2 &&
        selectedDuration == 20) {
      recommendationTitle =
          "Consistency Foundation";

      recommendationText =
          "This is a minimal but valuable starting point. Expect improvements in energy, movement quality and general fitness. Building the habit matters most here.";
    } else if (selectedDays == 2) {
      recommendationTitle =
          "Efficient Training";

      recommendationText =
          "Two focused sessions per week can still deliver noticeable improvements when consistency is maintained.";
    } else if (selectedDays == 3 &&
        selectedDuration! <= 45) {
      recommendationTitle =
          "Classic Beginner Setup";

      recommendationText =
          "Perfect for full body programs and steady progress while keeping recovery simple.";
    } else if (selectedDays == 3) {
      recommendationTitle =
          "Balanced Progress";

      recommendationText =
          "Three quality sessions per week are enough for impressive long term results.";
    } else if (selectedDays == 4) {
      recommendationTitle =
          "Excellent Balance";

      recommendationText =
          "One of the best combinations of progress, recovery and sustainability.";
    } else if (selectedDays == 5) {
      recommendationTitle =
          "Growth Focused";

      recommendationText =
          "Great for muscle growth and strength progression while maintaining good recovery.";
    } else if (selectedDays == 6 &&
        selectedDuration! >= 90) {
      recommendationTitle =
          "Advanced Commitment";

      recommendationText =
          "This level of commitment allows specialization and rapid progression. Recovery, sleep and nutrition become essential.";
    } else if (selectedDays == 6) {
      recommendationTitle =
          "Serious Training";

      recommendationText =
          "A six day schedule allows focused training for every muscle group while maintaining high weekly volume.";
    } else if (selectedDays == 7) {
      recommendationTitle =
          "Maximum Frequency";

      recommendationText =
          "Training every day requires careful fatigue management and smart programming.";
    } else {
      recommendationTitle =
          "Customized Program";

      recommendationText =
          "We'll build a program optimized around your available time.";
    }
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool showRecommendation =
        selectedDays != null &&
        selectedDuration != null;

    final String recommendationDisplay =
        recommendationTitle.isEmpty
            ? ""
            : "$recommendationTitle! $recommendationText";

    return Scaffold(
      backgroundColor: background,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              background,
              backgroundMid,
              background,
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
            // Orange workout silhouettes
            const BackgroundDecorations(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // BACK BUTTON
                    // =================================================

                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(),

                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),

                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // SCROLLABLE CONTENT
                    // =================================================

                    Expanded(
                      child: SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            // =================================================
                            // TITLE
                            // =================================================

                            const Text(
                              "How much time can you\nrealistically commit?",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // =================================================
                            // RECOMMENDATION CARD
                            // =================================================

                            AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 300,
                              ),

                              transitionBuilder:
                                  (child, animation) {
                                final offsetAnimation =
                                    Tween<Offset>(
                                  begin:
                                      const Offset(0, -0.04),
                                  end: Offset.zero,
                                ).animate(animation);

                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position:
                                        offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },

                              child: showRecommendation
                                  ? Container(
                                      key: const ValueKey(
                                        "recommendation_card",
                                      ),

                                      width:
                                          double.infinity,

                                      constraints:
                                          const BoxConstraints(
                                        minHeight: 95,
                                      ),

                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),

                                      decoration:
                                          BoxDecoration(
                                        color: cardColor,

                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          18,
                                        ),

                                        border:
                                            Border.all(
                                          color: orange,
                                          width: 1.5,
                                        ),

                                        boxShadow: [
                                          BoxShadow(
                                            color: orange
                                                .withValues(
                                              alpha: 0.20,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                            offset:
                                                const Offset(
                                              0,
                                              4,
                                            ),
                                          ),
                                        ],
                                      ),

                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,

                                        children: [
                                          // =================================================
                                          // WHITE BICEP
                                          // =================================================

                                          ColorFiltered(
                                            colorFilter:
                                                const ColorFilter
                                                    .mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),

                                            child: Image.asset(
                                              'assets/images/bodyparts/bicep.png',
                                              height: 42,

                                              errorBuilder:
                                                  (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return const Icon(
                                                  Icons
                                                      .fitness_center_rounded,
                                                  size: 38,
                                                  color:
                                                      Colors.white,
                                                );
                                              },
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 14,
                                          ),

                                          // =================================================
                                          // RECOMMENDATION TEXT
                                          // =================================================

                                          Expanded(
                                            child: Text(
                                              recommendationDisplay,
                                              maxLines: 3,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,

                                              style:
                                                  const TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color:
                                                    Colors.white,
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                  : const SizedBox.shrink(
                                      key: ValueKey(
                                        "no_recommendation",
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 28),

                            // =================================================
                            // DAYS PER WEEK
                            // =================================================

                            _buildSectionHeader(
                              "Days per week",
                              "How many days can you realistically train?",
                            ),

                            const SizedBox(height: 14),

                            CreativeValuePicker(
                              options: daysOptions
                                  .map(
                                    (d) => "$d",
                                  )
                                  .toList(),

                              selectedIndex:
                                  selectedDays == null
                                      ? null
                                      : daysOptions.indexOf(
                                          selectedDays!,
                                        ),

                              onChanged: (index) {
                                setState(() {
                                  selectedDays =
                                      daysOptions[index];

                                  updateRecommendation();
                                });
                              },

                              accent: orange,
                              textColor: Colors.white,
                              mutedColor: Colors.white70,
                              chipBackground: fieldColor,
                            ),

                            const SizedBox(height: 28),

                            // =================================================
                            // HOURS PER SESSION
                            // =================================================

                            _buildSectionHeader(
                              "Hours per session",
                              "How much time can you dedicate per session?",
                            ),

                            const SizedBox(height: 14),

                            CreativeValuePicker(
                              options: durationOptions
                                  .map(
                                    (d) =>
                                        d == 90
                                            ? "90 min"
                                            : "$d min",
                                  )
                                  .toList(),

                              selectedIndex:
                                  selectedDuration == null
                                      ? null
                                      : durationOptions.indexOf(
                                          selectedDuration!,
                                        ),

                              onChanged: (index) {
                                setState(() {
                                  selectedDuration =
                                      durationOptions[index];

                                  updateRecommendation();
                                });
                              },

                              accent: orange,
                              textColor: Colors.white,
                              mutedColor: Colors.white70,
                              chipBackground: fieldColor,
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // CONTINUE BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(22),

                          boxShadow:
                              showRecommendation
                                  ? [
                                      BoxShadow(
                                        color:
                                            orange.withValues(
                                          alpha: 0.30,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                        offset:
                                            const Offset(
                                          0,
                                          5,
                                        ),
                                      ),
                                    ]
                                  : [],
                        ),

                        child: ElevatedButton(
                          onPressed:
                              !showRecommendation
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ExperienceScreen(),
                                        ),
                                      );
                                    },

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: orange,

                            disabledBackgroundColor:
                                const Color(0xFF2A2A2A),

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                22,
                              ),
                            ),
                          ),

                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              Text(
                                "Continue",

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w600,

                                  color:
                                      showRecommendation
                                          ? Colors.white
                                          : Colors.white38,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Icon(
                                Icons.arrow_forward,

                                color:
                                    showRecommendation
                                        ? Colors.white
                                        : Colors.white38,

                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}