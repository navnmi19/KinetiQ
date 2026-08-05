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

  bool isMetric = true;

  double bmi = 0;
  String bmiStatus = "";

  // State for the custom ruler cards.
  bool heightExpanded = false;
  bool weightExpanded = false;

  double heightValue = 174; // cm (or inches when isMetric == false)
  double weightValue = 68; // kg (or lbs when isMetric == false)

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
      return const Color(0xFF22C55E);
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

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _switchToMetric,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isMetric ? const Color(0xFF22C55E) : Colors.white,
                          ),
                          child: Text(
                            "Metric",
                            style: TextStyle(
                              color: isMetric ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _switchToUS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !isMetric ? const Color(0xFF22C55E) : Colors.white,
                          ),
                          child: Text(
                            "US",
                            style: TextStyle(
                              color: !isMetric ? Colors.white : Colors.black,
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
      onTap: () {}, // absorb taps so they don't collapse the card
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              _heightDisplay,
              key: ValueKey(_heightDisplay),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              _weightDisplay,
              key: ValueKey(_weightDisplay),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF22C55E).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
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
              color: Colors.black54,
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
                  key: ValueKey(bmi.toStringAsFixed(1)),
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
              color: Colors.black54,
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
                              Color(0xFF22C55E),
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
                          border: Border.all(color: getBMIColor(), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: expanded
              ? Border.all(color: const Color(0xFF22C55E), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
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
                      color: Colors.black,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: expanded
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : Container(
                          key: const ValueKey('pill'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            displayValue,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16803C),
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
                      color: Colors.black45,
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
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEIGHT / WEIGHT RULER — rebuilt implementation
//
// Built entirely from:
//   - ListView.builder (horizontal, lazy)
//   - ScrollController
//   - NotificationListener<ScrollNotification>
//   - Custom snapping logic (animateTo on scroll end)
//
// Deliberately avoids ListWheelScrollView, RotatedBox,
// CupertinoPicker, Slider, and any rotated scrollables — this is
// what caused the mouse_tracker assertions, dead scrolling, and
// RenderFlex overflows in the previous version.
//
// A custom ScrollBehavior enables mouse + trackpad dragging so the
// ruler works with real click-and-drag on Windows, macOS and Web,
// not just touch.
// ============================================================

/// Custom scroll behavior that allows the ruler to be dragged with a
/// mouse or trackpad (desktop/web) in addition to touch, and pins the
/// physics to a predictable, non-bouncy clamp so our manual snapping
/// logic always has a stable final resting offset to animate to.
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
    // No glow — this is a ruler, not a list.
    return child;
  }
}

/// A premium horizontal ruler picker.
///
/// A fixed green capsule marks the center of the widget; the ruler
/// itself scrolls underneath it. The list is padded on both sides by
/// half the viewport width so that the first and last values can
/// still be centered under the indicator, which keeps the mapping
/// between scroll offset and selected index a simple, robust
/// `index = offset / itemExtent` — no matter the screen size.
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
  // Spacing between individual minor ticks on screen (px).
  static const double itemExtent = 12.0;
  // Total on-screen height reserved for each ruler column. Generous
  // on purpose so nothing can ever overflow, even at the largest
  // (font 28, bold) selected-label size.
  static const double rulerHeight = 112.0;

  late final ScrollController _controller;
  late final int _totalSteps;
  late int _selectedIndex;
  bool _isSettling = false;

  int _valueToIndex(double v) => ((v - widget.min) / widget.step).round();

  double _indexToValue(int i) {
    final double raw = widget.min + (i * widget.step);
    // Guard against binary floating point drift (e.g. 0.1 + 0.2 style
    // errors) so values like 68.5 never render as 68.499999999.
    return double.parse(raw.toStringAsFixed(3));
  }

  @override
  void initState() {
    super.initState();
    _totalSteps = ((widget.max - widget.min) / widget.step).round();
    final double clamped = widget.initialValue.clamp(widget.min, widget.max);
    _selectedIndex = _valueToIndex(clamped).clamp(0, _totalSteps);
    _controller = ScrollController(
      initialScrollOffset: _selectedIndex * itemExtent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Recomputes the selected index from a raw scroll offset. Only
  /// notifies the parent when the integer step actually changes, so
  /// we don't spam `setState` on every sub-pixel scroll delta.
  void _updateFromOffset(double offset) {
    final int index = (offset / itemExtent).round().clamp(0, _totalSteps);
    if (index != _selectedIndex) {
      _selectedIndex = index;
      widget.onChanged(_indexToValue(index));
    }
  }

  /// Custom snapping: once the scroll comes to rest, animate the
  /// remaining fraction of a step so the selected value always ends
  /// exactly under the center indicator.
  void _snapToNearest() {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) {
      return;
    }
    final double target = (_selectedIndex * itemExtent)
        .clamp(0.0, _controller.position.maxScrollExtent);

    if ((_controller.offset - target).abs() > 0.5) {
      _isSettling = true;
      _controller
          .animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      )
          .whenComplete(() {
        _isSettling = false;
      });
    }
    widget.onChanged(_indexToValue(_selectedIndex));
  }

  @override
  Widget build(BuildContext context) {
    final int majorEveryIdx = (widget.majorEvery / widget.step).round();
    final int mediumEveryIdx = (widget.mediumEvery / widget.step).round();
    final int itemCount = _totalSteps + 1;

    return SizedBox(
      height: rulerHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double sidePadding =
              (constraints.maxWidth / 2) - (itemExtent / 2);

          return Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    _updateFromOffset(notification.metrics.pixels);
                  } else if (notification is ScrollEndNotification) {
                    if (!_isSettling) {
                      _updateFromOffset(notification.metrics.pixels);
                      _snapToNearest();
                    }
                  }
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: const _RulerScrollBehavior(),
                  child: RepaintBoundary(
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: sidePadding),
                      itemCount: itemCount,
                      itemExtent: itemExtent,
                      itemBuilder: (context, index) {
                        final bool isMajor = index % majorEveryIdx == 0;
                        final bool isMedium =
                            !isMajor && index % mediumEveryIdx == 0;
                        final String label = isMajor
                            ? _indexToValue(index).toStringAsFixed(0)
                            : "";

                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            double distanceMajor;
                            if (_controller.hasClients &&
                                _controller.position.hasContentDimensions) {
                              final double centerIndex =
                                  _controller.offset / itemExtent;
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
                              distanceMajor: distanceMajor,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Fixed center indicator — thin rounded green capsule,
              // small glow. Never intercepts touches/clicks.
              IgnorePointer(
                child: Container(
                  width: 3.5,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.55),
                        blurRadius: 10,
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

/// A single ruler column: a tick mark, plus (only on major ticks) a
/// number label that is always laid out on ONE line, never wrapped —
/// achieved via [OverflowBox], which lets the label be visually wider
/// than its 12px-wide tick slot without affecting layout/scroll math
/// and without ever triggering a RenderFlex overflow.
class _RulerTick extends StatelessWidget {
  final bool isMajor;
  final bool isMedium;
  final String label;
  final double distanceMajor; // 0 = centered, 1 = one major step away, ...

  const _RulerTick({
    required this.isMajor,
    required this.isMedium,
    required this.label,
    required this.distanceMajor,
  });

  @override
  Widget build(BuildContext context) {
    final double tickHeight = isMajor ? 34 : (isMedium ? 22 : 12);
    final double tickWidth = isMajor ? 3 : (isMedium ? 2 : 1);
    final Color tickColor = isMajor
        ? Colors.black.withOpacity(0.75)
        : (isMedium ? Colors.black38 : Colors.black26);

    return SizedBox(
      width: _RulerPickerState.itemExtent,
      height: _RulerPickerState.rulerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Tick mark, anchored to the bottom of the column.
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Container(
              width: tickWidth,
              height: tickHeight,
              decoration: BoxDecoration(
                color: tickColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Label, fixed slot above the tick — only major ticks have text.
          if (isMajor)
            Positioned(
              bottom: 18 + tickHeight + 6,
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

/// Renders a major-tick number. Sized in a fixed-height box (so it can
/// never cause a layout overflow) but allowed to overflow its 12px-wide
/// column horizontally via [OverflowBox], so multi-digit numbers like
/// "210" always stay on one line instead of wrapping vertically.
class _AnimatedRulerLabel extends StatelessWidget {
  final String label;
  final double distanceMajor;

  const _AnimatedRulerLabel({
    required this.label,
    required this.distanceMajor,
  });

  @override
  Widget build(BuildContext context) {
    // Three style "stops": selected (0), neighbour (1), everything
    // else (2+) — interpolated smoothly between them as the ruler scrolls.
    const selected = _LabelStyleStop(
      fontSize: 28,
      weight: FontWeight.bold,
      color: Colors.black,
      opacity: 1.0,
      liftPx: 6,
      scale: 1.0,
    );
    const neighbour = _LabelStyleStop(
      fontSize: 18,
      weight: FontWeight.w600,
      color: Colors.black87,
      opacity: 0.85,
      liftPx: 0,
      scale: 0.95,
    );
    const rest = _LabelStyleStop(
      fontSize: 14,
      weight: FontWeight.w500,
      color: Colors.black38,
      opacity: 0.5,
      liftPx: 0,
      scale: 0.9,
    );

    final double t = distanceMajor.clamp(0.0, 2.0);
    final _LabelStyleStop style = t <= 1.0
        ? _LabelStyleStop.lerp(selected, neighbour, t)
        : _LabelStyleStop.lerp(neighbour, rest, t - 1.0);

    return SizedBox(
      height: 36, // fixed slot: sized for the largest (28px bold) case
      child: OverflowBox(
        minWidth: 0,
        maxWidth: 80, // allows "210" etc. to render on one line
        alignment: Alignment.center,
        child: Transform.translate(
          offset: Offset(0, -style.liftPx),
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

  static _LabelStyleStop lerp(_LabelStyleStop a, _LabelStyleStop b, double t) {
    return _LabelStyleStop(
      fontSize: a.fontSize + (b.fontSize - a.fontSize) * t,
      weight: t < 0.5 ? a.weight : b.weight,
      color: Color.lerp(a.color, b.color, t) ?? b.color,
      opacity: a.opacity + (b.opacity - a.opacity) * t,
      liftPx: a.liftPx + (b.liftPx - a.liftPx) * t,
      scale: a.scale + (b.scale - a.scale) * t,
    );
  }
}