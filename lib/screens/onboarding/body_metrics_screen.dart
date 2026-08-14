import 'package:flutter/gestures.dart';
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

  static const Color orange = Color(0xFFFF8A00);
  static const Color background = Color(0xFF000000);
  static const Color backgroundMid = Color(0xFF080808);
  static const Color cardColor = Color(0xFF151515);
  static const Color fieldColor = Color(0xFF202020);

  bool isMetric = true;

  double bmi = 0;
  String bmiStatus = "";

  bool heightExpanded = false;
  bool weightExpanded = false;

  double heightValue = 174;
  double weightValue = 68;

  @override
  void initState() {
    super.initState();

    heightController.text = heightValue.toStringAsFixed(0);
    weightController.text = weightValue.toStringAsFixed(1);

    calculateBMI();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

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
      return orange;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String getBmiDescription() {
    switch (bmiStatus) {
      case "Underweight":
        return "You may benefit from gradually increasing muscle mass.";
      case "Healthy Weight":
        return "You're within the recommended BMI range.";
      case "Overweight":
        return "We'll help you reach your goal through balanced nutrition and training.";
      case "Obese":
        return "We'll build a gradual and sustainable fitness plan.";
      default:
        return "";
    }
  }

  void _switchToMetric() {
    setState(() {
      isMetric = true;
      heightValue = 174;
      weightValue = 68;
      heightExpanded = false;
      weightExpanded = false;
    });

    heightController.text = heightValue.toStringAsFixed(0);
    weightController.text = weightValue.toStringAsFixed(1);

    calculateBMI();
  }

  void _switchToUS() {
    setState(() {
      isMetric = false;
      heightValue = 68;
      weightValue = 150;
      heightExpanded = false;
      weightExpanded = false;
    });

    heightController.text = heightValue.toStringAsFixed(0);
    weightController.text = weightValue.toStringAsFixed(1);

    calculateBMI();
  }

  void _collapseAll() {
    if (heightExpanded || weightExpanded) {
      setState(() {
        heightExpanded = false;
        weightExpanded = false;
      });
    }
  }

  String get _heightDisplay =>
      "${heightValue.toStringAsFixed(0)} ${isMetric ? 'cm' : 'in'}";

  String get _weightDisplay =>
      "${weightValue.toStringAsFixed(1)} ${isMetric ? 'kg' : 'lbs'}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              background,
              backgroundMid,
              background,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: _collapseAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Body Metrics",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Help us understand your body better.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isMetric
                                ? [
                                    BoxShadow(
                                      color: orange.withValues(alpha: 0.30),
                                      blurRadius: 18,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ElevatedButton(
                            onPressed: _switchToMetric,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMetric
                                  ? orange
                                  : fieldColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Metric",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isMetric
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: !isMetric
                                ? [
                                    BoxShadow(
                                      color: orange.withValues(alpha: 0.30),
                                      blurRadius: 18,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ElevatedButton(
                            onPressed: _switchToUS,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !isMetric
                                  ? orange
                                  : fieldColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "US",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: !isMetric
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _MetricCard(
                            question: "How tall are you?",
                            displayValue: _heightDisplay,
                            expanded: heightExpanded,
                            onTap: () {
                              setState(() {
                                heightExpanded = !heightExpanded;
                                weightExpanded = false;
                              });
                            },
                            child: _buildHeightRuler(),
                          ),

                          const SizedBox(height: 16),

                          _MetricCard(
                            question: "How much do you weigh?",
                            displayValue: _weightDisplay,
                            expanded: weightExpanded,
                            onTap: () {
                              setState(() {
                                weightExpanded = !weightExpanded;
                                heightExpanded = false;
                              });
                            },
                            child: _buildWeightRuler(),
                          ),

                          const SizedBox(height: 16),

                          _buildBmiCard(),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: orange.withValues(alpha: 0.30),
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FitnessGoalScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeightRuler() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
            child: Text(
              _heightDisplay,
              key: ValueKey(_heightDisplay),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          _RulerPicker(
            key: ValueKey('height-$isMetric'),
            min: isMetric ? 120 : 47,
            max: isMetric ? 230 : 91,
            step: 1,
            initialValue: heightValue,
            majorEvery: 10,
            mediumEvery: 5,
            onChanged: (v) {
              setState(() => heightValue = v);
              heightController.text = v.toStringAsFixed(0);
              calculateBMI();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRuler() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
            child: Text(
              _weightDisplay,
              key: ValueKey(_weightDisplay),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          _RulerPicker(
            key: ValueKey('weight-$isMetric'),
            min: isMetric ? 30 : 66,
            max: isMetric ? 180 : 397,
            step: isMetric ? 0.5 : 1,
            initialValue: weightValue,
            majorEvery: 10,
            mediumEvery: 5,
            onChanged: (v) {
              setState(() => weightValue = v);
              weightController.text = v.toStringAsFixed(1);
              calculateBMI();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard() {
    const double barMin = 15.0;
    const double barMax = 35.0;

    final double fraction =
        ((bmi - barMin) / (barMax - barMin)).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: orange.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: orange.withValues(alpha: 0.10),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BMI",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  bmi.toStringAsFixed(1),
                  key: ValueKey(
                    bmi.toStringAsFixed(1),
                  ),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: getBMIColor(),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  bmiStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: getBMIColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            getBmiDescription(),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth;
              const double dotSize = 18;

              return SizedBox(
                height: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 5,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.blue,
                              orange,
                              Colors.orange,
                              Colors.red,
                            ],
                            stops: [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      left: (fraction * (barWidth - dotSize))
                          .clamp(0.0, barWidth - dotSize),
                      top: 0,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: getBMIColor(),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: getBMIColor()
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// METRIC CARD
// ============================================================

class _MetricCard extends StatelessWidget {
  final String question;
  final String displayValue;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _MetricCard({
    required this.question,
    required this.displayValue,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const Color orange = Color(0xFFFF8A00);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),

          border: expanded
              ? Border.all(
                  color: orange,
                  width: 1.5,
                )
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),

          boxShadow: [
            BoxShadow(
              color: expanded
                  ? orange.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.45),
              blurRadius: expanded ? 20 : 16,
              spreadRadius: expanded ? 1 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: expanded
                      ? const SizedBox.shrink(
                          key: ValueKey('empty'),
                        )
                      : Container(
                          key: const ValueKey('pill'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1A0A),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            displayValue,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFA733),
                            ),
                          ),
                        ),
                ),

                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: expanded ? 0.5 : 0,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: child,
                    )
                  : const SizedBox(
                      width: double.infinity,
                      height: 0,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RULER SCROLL BEHAVIOR
// ============================================================

class _RulerScrollBehavior extends MaterialScrollBehavior {
  const _RulerScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ============================================================
// RULER PICKER
// ============================================================

class _RulerPicker extends StatefulWidget {
  final double min;
  final double max;
  final double step;
  final double initialValue;
  final double majorEvery;
  final double mediumEvery;
  final ValueChanged<double> onChanged;

  const _RulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.step,
    required this.initialValue,
    required this.onChanged,
    this.majorEvery = 10,
    this.mediumEvery = 5,
  });

  @override
  State<_RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<_RulerPicker> {
  static const double itemExtent = 12.0;
  static const double rulerHeight = 112.0;

  late final ScrollController _controller;
  late final int _totalSteps;
  late int _selectedIndex;

  bool _isSettling = false;

  int _valueToIndex(double v) {
    return ((v - widget.min) / widget.step).round();
  }

  double _indexToValue(int i) {
    final double raw = widget.min + (i * widget.step);

    return double.parse(
      raw.toStringAsFixed(3),
    );
  }

  @override
  void initState() {
    super.initState();

    _totalSteps =
        ((widget.max - widget.min) / widget.step).round();

    final double clamped =
        widget.initialValue.clamp(
      widget.min,
      widget.max,
    );

    _selectedIndex =
        _valueToIndex(clamped).clamp(
      0,
      _totalSteps,
    );

    _controller = ScrollController(
      initialScrollOffset: _selectedIndex * itemExtent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFromOffset(double offset) {
    final int index =
        (offset / itemExtent)
            .round()
            .clamp(0, _totalSteps);

    if (index != _selectedIndex) {
      _selectedIndex = index;

      widget.onChanged(
        _indexToValue(index),
      );
    }
  }

  void _snapToNearest() {
    if (!_controller.hasClients ||
        !_controller.position.hasContentDimensions) {
      return;
    }

    final double target =
        (_selectedIndex * itemExtent)
            .clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );

    if ((_controller.offset - target).abs() > 0.5) {
      _isSettling = true;

      _controller
          .animateTo(
        target,
        duration: const Duration(
          milliseconds: 260,
        ),
        curve: Curves.easeOutCubic,
      )
          .whenComplete(() {
        _isSettling = false;
      });
    }

    widget.onChanged(
      _indexToValue(_selectedIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color orange = Color(0xFFFF8A00);

    final int majorEveryIdx =
        (widget.majorEvery / widget.step).round();

    final int mediumEveryIdx =
        (widget.mediumEvery / widget.step).round();

    final int itemCount = _totalSteps + 1;

    return SizedBox(
      height: rulerHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double sidePadding =
              (constraints.maxWidth / 2) -
                  (itemExtent / 2);

          return Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification
                      is ScrollUpdateNotification) {
                    _updateFromOffset(
                      notification.metrics.pixels,
                    );
                  } else if (notification
                      is ScrollEndNotification) {
                    if (!_isSettling) {
                      _updateFromOffset(
                        notification.metrics.pixels,
                      );

                      _snapToNearest();
                    }
                  }

                  return false;
                },
                child: ScrollConfiguration(
                  behavior:
                      const _RulerScrollBehavior(),
                  child: RepaintBoundary(
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics:
                          const ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: sidePadding,
                      ),
                      itemCount: itemCount,
                      itemExtent: itemExtent,
                      itemBuilder: (context, index) {
                        final bool isMajor =
                            index % majorEveryIdx == 0;

                        final bool isMedium =
                            !isMajor &&
                            index % mediumEveryIdx == 0;

                        final String label = isMajor
                            ? _indexToValue(index)
                                .toStringAsFixed(0)
                            : "";

                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            double distanceMajor;

                            if (_controller.hasClients &&
                                _controller.position
                                    .hasContentDimensions) {
                              final double centerIndex =
                                  _controller.offset /
                                      itemExtent;

                              distanceMajor =
                                  (index - centerIndex).abs() /
                                      majorEveryIdx;
                            } else {
                              distanceMajor =
                                  (index - _selectedIndex).abs() /
                                      majorEveryIdx;
                            }

                            return _RulerTick(
                              isMajor: isMajor,
                              isMedium: isMedium,
                              label: label,
                              distanceMajor:
                                  distanceMajor,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ORANGE CENTER INDICATOR + GLOW
              IgnorePointer(
                child: Container(
                  width: 3.5,
                  height: 40,
                  margin: const EdgeInsets.only(
                    bottom: 26,
                  ),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius:
                        BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color:
                            orange.withValues(alpha: 0.60),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// RULER TICK
// ============================================================

class _RulerTick extends StatelessWidget {
  final bool isMajor;
  final bool isMedium;
  final String label;
  final double distanceMajor;

  const _RulerTick({
    required this.isMajor,
    required this.isMedium,
    required this.label,
    required this.distanceMajor,
  });

  @override
  Widget build(BuildContext context) {
    final double tickHeight =
        isMajor ? 34 : (isMedium ? 22 : 12);

    final double tickWidth =
        isMajor ? 3 : (isMedium ? 2 : 1);

    final Color tickColor = isMajor
        ? Colors.white.withValues(alpha: 0.80)
        : (isMedium
            ? Colors.white54
            : Colors.white24);

    return SizedBox(
      width: _RulerPickerState.itemExtent,
      height: _RulerPickerState.rulerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 18,
            ),
            child: Container(
              width: tickWidth,
              height: tickHeight,
              decoration: BoxDecoration(
                color: tickColor,
                borderRadius:
                    BorderRadius.circular(2),
              ),
            ),
          ),

          if (isMajor)
            Positioned(
              bottom: 18 + tickHeight + 6,
              width: _RulerPickerState.itemExtent,
              child: _AnimatedRulerLabel(
                label: label,
                distanceMajor: distanceMajor,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// ANIMATED RULER LABEL
// ============================================================

class _AnimatedRulerLabel extends StatelessWidget {
  final String label;
  final double distanceMajor;

  const _AnimatedRulerLabel({
    required this.label,
    required this.distanceMajor,
  });

  @override
  Widget build(BuildContext context) {
    const selected = _LabelStyleStop(
      fontSize: 28,
      weight: FontWeight.bold,
      color: Colors.white,
      opacity: 1.0,
      liftPx: 6,
      scale: 1.0,
    );

    const neighbour = _LabelStyleStop(
      fontSize: 18,
      weight: FontWeight.w600,
      color: Colors.white70,
      opacity: 0.85,
      liftPx: 0,
      scale: 0.95,
    );

    const rest = _LabelStyleStop(
      fontSize: 14,
      weight: FontWeight.w500,
      color: Colors.white38,
      opacity: 0.5,
      liftPx: 0,
      scale: 0.9,
    );

    final double t =
        distanceMajor.clamp(0.0, 2.0);

    final _LabelStyleStop style =
        t <= 1.0
            ? _LabelStyleStop.lerp(
                selected,
                neighbour,
                t,
              )
            : _LabelStyleStop.lerp(
                neighbour,
                rest,
                t - 1.0,
              );

    return SizedBox(
      height: 36,
      child: OverflowBox(
        minWidth: 0,
        maxWidth: 80,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: Offset(
            0,
            -style.liftPx,
          ),
          child: Transform.scale(
            scale: style.scale,
            child: Opacity(
              opacity: style.opacity,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: style.fontSize,
                  fontWeight: style.weight,
                  color: style.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LABEL STYLE
// ============================================================

class _LabelStyleStop {
  final double fontSize;
  final FontWeight weight;
  final Color color;
  final double opacity;
  final double liftPx;
  final double scale;

  const _LabelStyleStop({
    required this.fontSize,
    required this.weight,
    required this.color,
    required this.opacity,
    required this.liftPx,
    required this.scale,
  });

  static _LabelStyleStop lerp(
    _LabelStyleStop a,
    _LabelStyleStop b,
    double t,
  ) {
    return _LabelStyleStop(
      fontSize:
          a.fontSize +
          (b.fontSize - a.fontSize) * t,
      weight:
          t < 0.5 ? a.weight : b.weight,
      color:
          Color.lerp(a.color, b.color, t) ??
              b.color,
      opacity:
          a.opacity +
          (b.opacity - a.opacity) * t,
      liftPx:
          a.liftPx +
          (b.liftPx - a.liftPx) * t,
      scale:
          a.scale +
          (b.scale - a.scale) * t,
    );
  }
}