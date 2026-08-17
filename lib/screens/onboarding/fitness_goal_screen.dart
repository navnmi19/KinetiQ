import 'package:flutter/material.dart';
import 'target_body_parts.dart';
import 'package:gym_app/widgets/background_decoration.dart';

class FitnessGoalScreen extends StatefulWidget {
  const FitnessGoalScreen({super.key});

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  // ------------------------------------------------------------
  // KINETIQ DARK THEME
  // ------------------------------------------------------------

  static const Color orange = Color(0xFFFF8A00);

  static const Color background = Color(0xFF000000);
  static const Color backgroundMid = Color(0xFF080808);

  static const Color cardColor = Color(0xFF151515);
  static const Color fieldColor = Color(0xFF202020);

  String? primaryGoal;
  String? secondaryGoal;

  final List<Map<String, String>> goals = [
    {
      "title": "Build Muscle",
      "subtitle": "Increase muscle mass and strength",
      "icon": "💪"
    },
    {
      "title": "Lose Fat",
      "subtitle": "Reduce body fat percentage",
      "icon": "🔥"
    },
    {
      "title": "Body Recomposition",
      "subtitle": "Gain muscle while losing fat",
      "icon": "⚖️"
    },
    {
      "title": "Improve Fitness",
      "subtitle": "Boost stamina and endurance",
      "icon": "🏃"
    },
    {
      "title": "General Health",
      "subtitle": "Improve overall wellbeing",
      "icon": "❤️"
    },
    {
      "title": "Athletic Performance",
      "subtitle": "Train for sports and performance",
      "icon": "🏆"
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            // Orange workout decorations
            const BackgroundDecorations(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    const Text(
                      "Your Fitness Goal",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Choose your primary goal.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ------------------------------------------------
                    // GOAL LIST
                    // ------------------------------------------------

                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: goals.length,

                        itemBuilder: (context, index) {
                          final goal = goals[index];

                          final bool selected =
                              primaryGoal == goal["title"];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                primaryGoal = goal["title"];
                              });
                            },

                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 250),

                              curve: Curves.easeOutCubic,

                              margin: const EdgeInsets.only(
                                bottom: 15,
                              ),

                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                // Selected = orange
                                // Unselected = dark gray
                                color: selected
                                    ? orange
                                    : cardColor,

                                borderRadius:
                                    BorderRadius.circular(20),

                                border: Border.all(
                                  color: selected
                                      ? orange
                                      : Colors.white.withValues(
                                          alpha: 0.06,
                                        ),
                                  width: selected ? 1.5 : 1,
                                ),

                                // Orange glow on selection
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: orange.withValues(
                                            alpha: 0.32,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 1,
                                          offset:
                                              const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 12,
                                          offset:
                                              const Offset(0, 4),
                                        ),
                                      ],
                              ),

                              child: Row(
                                children: [
                                  // ------------------------------------------------
                                  // ICON
                                  // ------------------------------------------------

                                  Container(
                                    width: 54,
                                    height: 54,

                                    alignment: Alignment.center,

                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white
                                              .withValues(
                                            alpha: 0.12,
                                          )
                                          : fieldColor,

                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),

                                    child: Text(
                                      goal["icon"]!,
                                      style: const TextStyle(
                                        fontSize: 28,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  // ------------------------------------------------
                                  // TEXT
                                  // ------------------------------------------------

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal["title"]!,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: selected
                                                ? Colors.white
                                                : Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        Text(
                                          goal["subtitle"]!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: selected
                                                ? Colors.white
                                                    .withValues(
                                                    alpha: 0.78,
                                                  )
                                                : Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ------------------------------------------------
                                  // CHECK
                                  // ------------------------------------------------

                                  AnimatedScale(
                                    duration: const Duration(
                                      milliseconds: 220,
                                    ),
                                    scale: selected ? 1.0 : 0.0,

                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ------------------------------------------------
                    // CONTINUE BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 60,

                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20),

                          boxShadow: primaryGoal != null
                              ? [
                                  BoxShadow(
                                    color: orange.withValues(
                                      alpha: 0.32,
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
                          onPressed: primaryGoal == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TargetBodyPartsScreen(),
                                    ),
                                  );
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,

                            disabledBackgroundColor:
                                const Color(0xFF2A2A2A),

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),

                          child: Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,

                              color: primaryGoal == null
                                  ? Colors.white38
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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