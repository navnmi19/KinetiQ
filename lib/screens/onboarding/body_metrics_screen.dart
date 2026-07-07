import 'package:flutter/material.dart';
import 'fitness_goal_screen.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool isMetric = true;

  double bmi = 0;
  String bmiStatus = "";

  void calculateBMI() {
    double height = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      if (isMetric) {
        double heightInMeters = height / 100;
        bmi = weight / (heightInMeters * heightInMeters);
      } else {
        bmi = (weight * 703) / (height * height);
      }

      if (bmi < 18.5) {
        bmiStatus = "Underweight";
      } else if (bmi < 25) {
        bmiStatus = "Healthy Weight";
      } else if (bmi < 30) {
        bmiStatus = "Overweight";
      } else {
        bmiStatus = "Obese";
      }
      
    } else {
      bmi = 0;
      bmiStatus = "";
    }

    setState(() {});
}
    Color getBMIColor() {
  if (bmi < 18.5) {
    return Colors.blue;
  } else if (bmi < 25) {
    return const Color(0xFF22C55E);
  } else if (bmi < 30) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}


  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                const Text(
                  "Body Metrics",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Help us understand your body better.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isMetric = true;
                          });
                          calculateBMI();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMetric
                              ? const Color(0xFF22C55E)
                              : Colors.white,
                        ),
                        child: Text(
                          "Metric",
                          style: TextStyle(
                            color: isMetric
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isMetric = false;
                          });
                          calculateBMI();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isMetric
                              ? const Color(0xFF22C55E)
                              : Colors.white,
                        ),
                        child: Text(
                          "US",
                          style: TextStyle(
                            color: !isMetric
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => calculateBMI(),
                  decoration: InputDecoration(
                    labelText: isMetric
                        ? "Height (cm)"
                        : "Height (inches)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => calculateBMI(),
                  decoration: InputDecoration(
                    labelText: isMetric
                        ? "Weight (kg)"
                        : "Weight (lbs)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                if (bmi > 0)
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Your BMI",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color:getBMIColor(),
                          ),
                        ),

                        Text(
                          bmiStatus,
                          style:  TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: getBMIColor(),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FitnessGoalScreen(),
    ),
  );
},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
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