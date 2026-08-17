import 'dart:ui';
import 'package:flutter/material.dart';
import 'program_generation_screen.dart';
import 'package:gym_app/widgets/background_decoration.dart';

class TrainingSetupScreen extends StatefulWidget {
  const TrainingSetupScreen({super.key});

  @override
  State<TrainingSetupScreen> createState() =>
      _TrainingSetupScreenState();
}

class _TrainingSetupScreenState extends State<TrainingSetupScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // KINETIQ DARK THEME
  // ============================================================

  static const Color orange = Color(0xFFFF8A00);
  static const Color background = Color(0xFF000000);
  static const Color backgroundMid = Color(0xFF080808);
  static const Color cardColor = Color(0xFF151515);
  static const Color fieldColor = Color(0xFF202020);

  final PageController _pageController =
      PageController(viewportFraction: 0.82);

  final FixedExtentScrollController _wheelController =
      FixedExtentScrollController();

  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  late final AnimationController _buttonController;
  late final Animation<double> _buttonScale;

  double _pageValue = 0.0;

  int? _selectedTrainingIndex;
  int? _selectedEquipmentIndex;

  final Set<int> _selectedAdditionalEquipment = {};

  bool _additionalEquipmentExpanded = false;

  // ============================================================
  // TRAINING OPTIONS
  // ============================================================

  final List<_TrainingOption> _trainingOptions = const [
    _TrainingOption(
      emoji: '💪',
      title: 'Muscle Building',
      subtitle:
          'Focus on size, aesthetics and hypertrophy.',
    ),
    _TrainingOption(
      emoji: '🏋️',
      title: 'Strength Focused',
      subtitle:
          'Lift heavier and build raw strength.',
    ),
    _TrainingOption(
      emoji: '⚡',
      title: 'Athletic Training',
      subtitle:
          'Improve explosiveness and performance.',
    ),
    _TrainingOption(
      emoji: '❤️',
      title: 'General Fitness',
      subtitle:
          'Stay healthy and active.',
    ),
    _TrainingOption(
      emoji: '🔀',
      title: 'Balanced Approach',
      subtitle:
          'A mix of everything.',
    ),
  ];

  // ============================================================
  // EQUIPMENT
  // ============================================================

  final List<String> _equipmentOptions = const [
    'Full Gym',
    'Home Gym',
    'Dumbbells Only',
    'Bodyweight Only',
    'Mixed Equipment',
  ];

  final List<String> _additionalEquipmentOptions = const [
    'Adjustable Bench',
    'Pullup Bar',
    'Resistance Bands',
    'Barbell',
    'Cable Machine',
    'Kettlebells',
    'Dip Bars',
    'Weight Plates',
    'Smith Machine',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _headerController.forward();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 0.95,
    );

    _buttonScale = _buttonController;

    _pageController.addListener(() {
      setState(() {
        _pageValue = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _wheelController.dispose();
    _headerController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECTION LOGIC
  // ============================================================

  bool get _isComplete =>
      _selectedTrainingIndex != null &&
      _selectedEquipmentIndex != null;

  void _selectTraining(int index) {
    setState(() {
      _selectedTrainingIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    _maybeAnimateButton();
  }

  void _selectEquipment(int index) {
    setState(() {
      _selectedEquipmentIndex = index;
    });

    _maybeAnimateButton();
  }

  void _toggleAdditionalEquipment(int index) {
    setState(() {
      if (_selectedAdditionalEquipment.contains(index)) {
        _selectedAdditionalEquipment.remove(index);
      } else {
        _selectedAdditionalEquipment.add(index);
      }
    });
  }

  void _maybeAnimateButton() {
    if (_isComplete) {
      _buttonController.forward();
    } else {
      _buttonController.reverse();
    }
  }

  // ============================================================
  // RECOMMENDATION
  // ============================================================

  String get _recommendationText {
    if (_selectedTrainingIndex == null) {
      return '';
    }

    switch (_selectedTrainingIndex) {
      case 0:
        if (_selectedEquipmentIndex == 0) {
          return 'Excellent environment for hypertrophy and specialization training.';
        }

        return 'A solid setup to focus on size, aesthetics and hypertrophy.';

      case 1:
        return 'Perfect setup for progressive overload and compound lifts.';

      case 2:
        return 'Ideal for explosive movements and conditioning work.';

      case 3:
        return "We'll prioritize sustainability and long-term health.";

      case 4:
        return "We'll build a balanced program tailored to your setup.";

      default:
        return '';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool showRecommendation = _isComplete;

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

        child: SafeArea(
          child: Stack(
            children: [
              const BackgroundDecorations(),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  140,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _buildHeader(),

                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'What type of training sounds most enjoyable to you?',
                    ),

                    const SizedBox(height: 16),

                    _buildTrainingCarousel(),

                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      'What equipment do you have regular access to?',
                    ),

                    const SizedBox(height: 8),

                    _buildEquipmentWheel(),

                    const SizedBox(height: 24),

                    _buildAdditionalEquipmentTile(),

                    const SizedBox(height: 24),

                    AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 500),

                      transitionBuilder:
                          (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },

                      child: showRecommendation
                          ? _buildRecommendationCard()
                          : const SizedBox.shrink(
                              key: ValueKey('empty'),
                            ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // BOTTOM BUTTON
              // ============================================================

              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: _buildBottomButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,

      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.05),
          end: Offset.zero,
        ).animate(_headerFade),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Training Setup',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Let's tailor your workouts.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // TRAINING CAROUSEL
  // ============================================================

  Widget _buildTrainingCarousel() {
    return SizedBox(
      height: 190,

      child: PageView.builder(
        controller: _pageController,
        itemCount: _trainingOptions.length,

        itemBuilder: (context, index) {
          final option = _trainingOptions[index];

          final bool isSelected =
              _selectedTrainingIndex == index;

          double delta = 0.0;

          if (_pageController.position.haveDimensions) {
            delta = index - _pageValue;
          } else {
            delta = index.toDouble();
          }

          final double scale =
              (1 - (delta.abs() * 0.15))
                  .clamp(0.85, 1.0);

          final double rotation =
              (delta * 0.05)
                  .clamp(-0.12, 0.12);

          return GestureDetector(
            onTap: () => _selectTraining(index),

            child: Transform.rotate(
              angle: rotation,

              child: Transform.scale(
                scale: isSelected
                    ? 1.05
                    : scale,

                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 300),

                  curve: Curves.easeOut,

                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),

                  padding:
                      const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: cardColor,

                    borderRadius:
                        BorderRadius.circular(26),

                    border: Border.all(
                      color: isSelected
                          ? orange
                          : Colors.white.withValues(
                              alpha: 0.06,
                            ),
                      width:
                          isSelected ? 2.0 : 1,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? orange.withValues(
                                alpha: 0.30,
                              )
                            : Colors.black.withValues(
                                alpha: 0.45,
                              ),

                        blurRadius:
                            isSelected ? 24 : 14,

                        spreadRadius:
                            isSelected ? 1 : 0,

                        offset:
                            const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          Text(
                            option.emoji,
                            style:
                                const TextStyle(
                              fontSize: 36,
                            ),
                          ),

                          AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds: 250,
                            ),

                            child: isSelected
                                ? Container(
                                    key: const ValueKey(
                                      'selected',
                                    ),

                                    padding:
                                        const EdgeInsets
                                            .all(6),

                                    decoration:
                                        const BoxDecoration(
                                      color: orange,
                                      shape:
                                          BoxShape.circle,
                                    ),

                                    child: const Icon(
                                      Icons
                                          .fitness_center,
                                      color:
                                          Colors.white,
                                      size: 16,
                                    ),
                                  )

                                : const SizedBox(
                                    key: ValueKey(
                                      'unselected',
                                    ),
                                    width: 28,
                                    height: 28,
                                  ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(
                        option.title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        option.subtitle,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.white70,
                          fontWeight:
                              FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // EQUIPMENT WHEEL
  // ============================================================

  Widget _buildEquipmentWheel() {
    return Container(
      height: 190,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
      ),

      child: Stack(
        alignment: Alignment.center,

        children: [
          // Selected area behind wheel
          Container(
            height: 52,

            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            decoration: BoxDecoration(
              color: orange.withValues(
                alpha: 0.08,
              ),

              borderRadius:
                  BorderRadius.circular(18),

              border: Border.all(
                color: orange.withValues(
                  alpha: 0.35,
                ),
              ),

              boxShadow: [
                BoxShadow(
                  color: orange.withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          ListWheelScrollView.useDelegate(
            controller: _wheelController,

            itemExtent: 52,

            diameterRatio: 1.6,

            physics:
                const FixedExtentScrollPhysics(),

            onSelectedItemChanged:
                _selectEquipment,

            childDelegate:
                ListWheelChildBuilderDelegate(
              childCount:
                  _equipmentOptions.length,

              builder: (context, index) {
                final bool isSelected =
                    _selectedEquipmentIndex ==
                        index;

                return AnimatedDefaultTextStyle(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),

                  curve: Curves.easeOut,

                  style: TextStyle(
                    fontSize: isSelected
                        ? 22
                        : 17,

                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w500,

                    color: isSelected
                        ? orange
                        : Colors.white
                            .withValues(
                            alpha: 0.35,
                          ),
                  ),

                  child: Center(
                    child: AnimatedScale(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      scale: isSelected
                          ? 1.08
                          : 1.0,

                      child: Text(
                        _equipmentOptions[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADDITIONAL EQUIPMENT
  // ============================================================

  Widget _buildAdditionalEquipmentTile() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.45,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),

        child: ExpansionTile(
          initiallyExpanded:
              _additionalEquipmentExpanded,

          onExpansionChanged: (value) {
            setState(() {
              _additionalEquipmentExpanded =
                  value;
            });
          },

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          collapsedShape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          tilePadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 4,
          ),

          title: const Text(
            'Additional Equipment (Optional)',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          iconColor: orange,

          collapsedIconColor:
              Colors.white54,

          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                18,
              ),

              child: Wrap(
                spacing: 10,
                runSpacing: 10,

                children: List.generate(
                  _additionalEquipmentOptions
                      .length,

                  (index) {
                    final bool isSelected =
                        _selectedAdditionalEquipment
                            .contains(index);

                    return AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      child: FilterChip(
                        label: Text(
                          _additionalEquipmentOptions[
                              index],
                        ),

                        selected: isSelected,

                        onSelected: (_) =>
                            _toggleAdditionalEquipment(
                          index,
                        ),

                        avatar: isSelected
                            ? const Icon(
                                Icons.fitness_center,
                                size: 16,
                                color:
                                    Colors.white,
                              )
                            : null,

                        showCheckmark: false,

                        backgroundColor:
                            fieldColor,

                        selectedColor:
                            orange,

                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white70,

                          fontWeight:
                              FontWeight.w600,

                          fontSize: 13,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),

                          side: BorderSide(
                            color: isSelected
                                ? orange
                                : Colors.white
                                    .withValues(
                                    alpha: 0.10,
                                  ),
                          ),
                        ),

                        elevation:
                            isSelected ? 4 : 0,

                        shadowColor:
                            orange.withValues(
                          alpha: 0.40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECOMMENDATION CARD
  // ============================================================

  Widget _buildRecommendationCard() {
    return ClipRRect(
      key: const ValueKey('recommendation'),

      borderRadius:
          BorderRadius.circular(24),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),

        child: Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius:
                BorderRadius.circular(24),

            border: Border.all(
              color: orange.withValues(
                alpha: 0.75,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: orange.withValues(
                  alpha: 0.20,
                ),

                blurRadius: 24,

                spreadRadius: 1,

                offset:
                    const Offset(0, 12),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: orange.withValues(
                    alpha: 0.12,
                  ),

                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color:
                          orange.withValues(
                        alpha: 0.15,
                      ),
                      blurRadius: 12,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.auto_awesome,
                  color: orange,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                        color: orange,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _recommendationText,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight.w500,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTON
  // ============================================================

  Widget _buildBottomButton() {
    return AnimatedBuilder(
      animation: _buttonScale,

      builder: (context, child) {
        return Transform.scale(
          scale:
              0.95 +
              (_buttonScale.value - 0.95) *
                  0.5 +
              0.05,

          child: child,
        );
      },

      child: GestureDetector(
        onTap: _isComplete
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProgramGenerationScreen(),
                  ),
                );
              }
            : null,

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 350),

          curve: Curves.easeOut,

          width: double.infinity,
          height: 60,

          decoration: BoxDecoration(
            color: _isComplete
                ? orange
                : const Color(0xFF2A2A2A),

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: _isComplete
                  ? orange
                  : Colors.white.withValues(
                      alpha: 0.06,
                    ),
            ),

            boxShadow: _isComplete
                ? [
                    BoxShadow(
                      color: orange.withValues(
                        alpha: 0.45,
                      ),

                      blurRadius: 22,

                      spreadRadius: 1,

                      offset:
                          const Offset(0, 10),
                    ),
                  ]
                : [],
          ),

          alignment: Alignment.center,

          child: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 300),

            child: Text(
              _isComplete
                  ? 'Generate My Program →'
                  : 'Continue',

              key: ValueKey(_isComplete),

              style: TextStyle(
                fontSize: 17,

                fontWeight:
                    FontWeight.w800,

                color: _isComplete
                    ? Colors.white
                    : Colors.white38,

                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TRAINING OPTION MODEL
// ============================================================

class _TrainingOption {
  final String emoji;
  final String title;
  final String subtitle;

  const _TrainingOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}