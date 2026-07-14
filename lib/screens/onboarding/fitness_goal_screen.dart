import 'package:flutter/material.dart';
import 'target_body_parts.dart';
import'package:gym_app/widgets/background_decoration.dart';


class FitnessGoalScreen extends StatefulWidget {
  const FitnessGoalScreen({super.key});

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
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
        child: Stack(children:[const BackgroundDecorations(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Your Fitness Goal",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Choose your primary goal.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      bool selected =
                          primaryGoal == goal["title"];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            primaryGoal = goal["title"];
                          });
                        },
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: 15),
                          padding:
                              const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF22C55E)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                goal["icon"]!,
                                style: const TextStyle(
                                  fontSize: 32,
                                ),
                              ),

                              const SizedBox(width: 15),

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
                                            : Colors.black,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      goal["subtitle"]!,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const TargetBodyPartsScreen(),
    ),
  );},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),],)
      ),
    );
  }
}