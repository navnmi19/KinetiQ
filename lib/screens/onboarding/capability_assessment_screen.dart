import 'package:flutter/material.dart';
import 'training_setup_screen.dart';
import 'package:gym_app/widgets/background_decoration.dart';
import 'package:gym_app/widgets/creative_value_picker.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  // ============================================================
  // KINETIQ DARK THEME
  // ============================================================

  static const Color orange = Color(0xFFFF8A00);
  static const Color background = Color(0xFF000000);
  static const Color backgroundMid = Color(0xFF080808);
  static const Color cardColor = Color(0xFF151515);
  static const Color fieldColor = Color(0xFF202020);

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
    "50+",
  ];

  final List<String> squatOptions = [
    "0-10",
    "10-25",
    "25-50",
    "50-100",
    "100+",
  ];

  final List<String> pullupOptions = [
    "0",
    "1-3",
    "4-8",
    "9-15",
    "15+",
  ];

  final List<String> familiarityOptions = [
    "Mostly New To Me",
    "Know The Basics",
    "Comfortable With Most Exercises",
    "Very Comfortable",
  ];

  // ============================================================
  // RECOMMENDATION LOGIC
  // ============================================================

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
    } else if ((pushups == "15-30" ||
            pushups == "30-50") &&
        (pullups == "1-3" ||
            pullups == "4-8")) {
      title = "Solid Foundation";

      description =
          "You've built a solid foundation. Your program will focus on progressive overload while maintaining proper recovery.";
    } else if (pushups == "50+" &&
        pullups == "15+" &&
        familiarity == "Very Comfortable") {
      title = "Performance Focus";

      description =
          "Strong numbers across the board. We'll shift toward specialization, advanced progression and performance optimization.";
    } else {
      title = "Personalized Progression";

      description =
          "We'll guide you step by step, matching your program to your current capabilities and experience level.";
    }
  }

  // ============================================================
  // FAMILIARITY SELECTOR
  // ============================================================

  Widget _buildFamiliaritySelector() {
    return Column(
      children: familiarityOptions.map((option) {
        final bool selected = familiarity == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                familiarity = option;
                updateRecommendation();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? orange
                      : Colors.white.withValues(alpha: 0.06),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: orange.withValues(alpha: 0.28),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? orange
                            : Colors.white,
                      ),
                    ),
                  ),

                  AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    scale: selected ? 1.0 : 0.0,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: orange,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
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
    final bool showRecommendation = title.isNotEmpty;

    final bool complete =
        pushups != null &&
        squats != null &&
        pullups != null &&
        familiarity != null;

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
                              "Current Capability",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Help us understand your current fitness level.",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // =================================================
                            // AI RECOMMENDATION CARD
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
                                      width: double.infinity,
                                      padding:
                                          const EdgeInsets.all(
                                        16,
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
                                                .start,
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
                                              errorBuilder: (
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
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                const Text(
                                                  "AI Coach Recommendation",
                                                  style:
                                                      TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight
                                                            .w700,
                                                    color:
                                                        Colors.white,
                                                  ),
                                                ),

                                                const SizedBox(
                                                  height: 6,
                                                ),

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
                                                    color:
                                                        Colors.white70,
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
                                      key: ValueKey(
                                        "no_recommendation",
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 24),

                            // =================================================
                            // PUSHUPS
                            // =================================================

                            _buildSectionHeader(
                              "Comfortable Pushups",
                              "How many can you comfortably do in one set?",
                            ),

                            const SizedBox(height: 12),

                            CreativeValuePicker(
                              options: pushupOptions,
                              selectedIndex: pushups == null
                                  ? null
                                  : pushupOptions.indexOf(
                                      pushups!,
                                    ),
                              onChanged: (index) {
                                setState(() {
                                  pushups =
                                      pushupOptions[index];
                                  updateRecommendation();
                                });
                              },
                              accent: orange,
                              textColor: Colors.white,
                              mutedColor: Colors.white70,
                              chipBackground: fieldColor,
                            ),

                            const SizedBox(height: 24),

                            // =================================================
                            // SQUATS
                            // =================================================

                            _buildSectionHeader(
                              "Comfortable Bodyweight Squats",
                              "How many can you comfortably do in one set?",
                            ),

                            const SizedBox(height: 12),

                            CreativeValuePicker(
                              options: squatOptions,
                              selectedIndex: squats == null
                                  ? null
                                  : squatOptions.indexOf(
                                      squats!,
                                    ),
                              onChanged: (index) {
                                setState(() {
                                  squats =
                                      squatOptions[index];
                                  updateRecommendation();
                                });
                              },
                              accent: orange,
                              textColor: Colors.white,
                              mutedColor: Colors.white70,
                              chipBackground: fieldColor,
                            ),

                            const SizedBox(height: 24),

                            // =================================================
                            // PULLUPS
                            // =================================================

                            _buildSectionHeader(
                              "Comfortable Pullups",
                              "How many can you comfortably do in one set?",
                            ),

                            const SizedBox(height: 12),

                            CreativeValuePicker(
                              options: pullupOptions,
                              selectedIndex: pullups == null
                                  ? null
                                  : pullupOptions.indexOf(
                                      pullups!,
                                    ),
                              onChanged: (index) {
                                setState(() {
                                  pullups =
                                      pullupOptions[index];
                                  updateRecommendation();
                                });
                              },
                              accent: orange,
                              textColor: Colors.white,
                              mutedColor: Colors.white70,
                              chipBackground: fieldColor,
                            ),

                            const SizedBox(height: 24),

                            // =================================================
                            // GYM FAMILIARITY
                            // =================================================

                            _buildSectionHeader(
                              "Gym Familiarity",
                              "How familiar are you with gym equipment and exercises?",
                            ),

                            const SizedBox(height: 12),

                            _buildFamiliaritySelector(),

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
                          boxShadow: complete
                              ? [
                                  BoxShadow(
                                    color: orange.withValues(
                                      alpha: 0.30,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset:
                                        const Offset(0, 5),
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: !complete
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TrainingSetupScreen(),
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
                                  color: complete
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: complete
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