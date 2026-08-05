import 'package:flutter/material.dart';
import 'package:gym_app/widgets/background_decoration.dart';
import'time_commitment_screen.dart';



class TargetBodyPartsScreen extends StatefulWidget {
  const TargetBodyPartsScreen({super.key});

  @override
  State<TargetBodyPartsScreen> createState() =>
      _TargetBodyPartsScreenState();
    
}

class _TargetBodyPartsScreenState
    extends State<TargetBodyPartsScreen> {

  final List<String> selectedParts = [];
  final List<String> selectedInjuries = [];

  final List<Map<String, String>> bodyParts = [
    {
      "name": "Chest",
      "image": "assets/images/bodyparts/chest.png"
    },
    {
      "name": "Back",
      "image": "assets/images/bodyparts/back.png"
    },
    {
      "name": "Shoulders",
      "image": "assets/images/bodyparts/shoulder.png"
    },
    {
      "name": "Arms",
      "image": "assets/images/bodyparts/bicep.png"
    },
    {
      "name": "Abs",
      "image": "assets/images/bodyparts/abs.png"
    },
    {
      "name": "Legs",
      "image": "assets/images/bodyparts/leg.png"
    },
  ];
  final List<String> injuries = [
  "None",
  "Shoulder",
  "Knee",
  "Lower Back",
  "Wrist",
  "Elbow",
  "Ankle",
  "Other",
  ];

  static const Map<String, IconData> _injuryIcons = {
    "Shoulder": Icons.accessibility_new_rounded,
    "Knee": Icons.directions_walk_rounded,
    "Lower Back": Icons.self_improvement_rounded,
    "Wrist": Icons.back_hand_rounded,
    "Elbow": Icons.sports_martial_arts_rounded,
    "Ankle": Icons.directions_run_rounded,
    "Other": Icons.more_horiz_rounded,
  };

  Widget _buildNoneCard() {
    final bool selected = selectedInjuries.contains("None");

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            selectedInjuries.remove("None");
          } else {
            selectedInjuries
              ..clear()
              ..add("None");
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF22C55E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF22C55E) : Colors.black12,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.favorite_border_rounded,
              color: selected ? Colors.white : const Color(0xFF22C55E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No injuries — I'm good to go!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryChip(String injury) {
    final bool selected = selectedInjuries.contains(injury);
    final IconData icon = _injuryIcons[injury] ?? Icons.circle;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInjuries.remove("None");
          if (selected) {
            selectedInjuries.remove(injury);
          } else {
            selectedInjuries.add(injury);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF22C55E) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? const Color(0xFF22C55E) : Colors.black12,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF22C55E),
            ),
            const SizedBox(width: 8),
            Text(
              injury,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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

        child: Stack(children: [const BackgroundDecorations(),
          SafeArea(child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),

                const Text(
                  "Target Body Parts",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Select all the areas you'd like to focus on",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GridView.builder(
                    itemCount: bodyParts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {

                      final part = bodyParts[index];
                      bool selected =
                          selectedParts.contains(
                              part["name"]);

                      return GestureDetector(
                        onTap: () {

                          setState(() {

                            if (selected) {
                              selectedParts.remove(
                                  part["name"]);
                            } else {
                              selectedParts.add(
                                  part["name"]!);
                            }
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF22C55E)
                                : Colors.white,

                            borderRadius:
                                BorderRadius.circular(20),

                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              ),
                              if (selected)
                                BoxShadow(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),

                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Image.asset(
                                part["image"]!,
                                height: 80,
                              ),

                              const SizedBox(height: 10),

                              Text(
                                part["name"]!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: selected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),

                              if (selected)
                                const Padding(
                                  padding:
                                      EdgeInsets.only(
                                          top: 8),

                                  child: Icon(
                                    Icons.fitness_center,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

const Text(
  "Any injuries or limitations?",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 6),

const Text(
  "Tap all that apply — we'll tailor your program around them.",
  style: TextStyle(
    fontSize: 14,
    color: Colors.black54,
  ),
),

const SizedBox(height: 15),

_buildNoneCard(),

const SizedBox(height: 12),

Wrap(
  spacing: 10,
  runSpacing: 10,
  children: injuries
      .where((injury) => injury != "None")
      .map(_buildInjuryChip)
      .toList(),
),
const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 60,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const TimeCommitmentScreen(),
        ),
      );
    },

    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF22C55E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    child: const Text(
      "Continue",
      style: TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
    ),
  ),
),

              ],
            ),
          ),
        ),],)
      ),
    );
  }
}