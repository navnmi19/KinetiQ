import 'package:flutter/material.dart';
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

        child: SafeArea(
          child: Padding(
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
                  "Select up to 3 focus areas",
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
                            } else if (selectedParts.length < 3) {
                              selectedParts.add(
                                  part["name"]!);
                            }
                          });
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF22C55E)
                                : Colors.white,

                            borderRadius:
                                BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              )
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

const SizedBox(height: 15),

Wrap(
  spacing: 10,
  runSpacing: 10,
  children: injuries.map((injury) {
    bool selected = selectedInjuries.contains(injury);

    return FilterChip(
      label: Text(injury),

      selected: selected,

      selectedColor: const Color(0xFF22C55E),

      checkmarkColor: Colors.white,

      onSelected: (value) {
        setState(() {

          if (injury == "None") {
            selectedInjuries.clear();

            if (value) {
              selectedInjuries.add("None");
            }
          } else {
            selectedInjuries.remove("None");

            if (value) {
              selectedInjuries.add(injury);
            } else {
              selectedInjuries.remove(injury);
            }
          }
        });
      },
    );
  }).toList(),
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
        ),
      ),
    );
  }
}