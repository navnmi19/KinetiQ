import 'dart:ui';
import 'package:flutter/material.dart';
import 'program_generation_screen.dart';
 
class TrainingSetupScreen extends StatefulWidget {
  const TrainingSetupScreen({super.key});
 
  @override
  State<TrainingSetupScreen> createState() => _TrainingSetupScreenState();
}
 
class _TrainingSetupScreenState extends State<TrainingSetupScreen>
    with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color bgGradientTop = Color(0xFFD1FAE5);
 
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
 
  final List<_TrainingOption> _trainingOptions = const [
    _TrainingOption(
      emoji: '💪',
      title: 'Muscle Building',
      subtitle: 'Focus on size, aesthetics and hypertrophy.',
    ),
    _TrainingOption(
      emoji: '🏋️',
      title: 'Strength Focused',
      subtitle: 'Lift heavier and build raw strength.',
    ),
    _TrainingOption(
      emoji: '⚡',
      title: 'Athletic Training',
      subtitle: 'Improve explosiveness and performance.',
    ),
    _TrainingOption(
      emoji: '❤️',
      title: 'General Fitness',
      subtitle: 'Stay healthy and active.',
    ),
    _TrainingOption(
      emoji: '🔀',
      title: 'Balanced Approach',
      subtitle: 'A mix of everything.',
    ),
  ];
 
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
 
  bool get _isComplete =>
      _selectedTrainingIndex != null && _selectedEquipmentIndex != null;
 
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
 
  String get _recommendationText {
    if (_selectedTrainingIndex == null) return '';
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
 
  @override
  Widget build(BuildContext context) {
    final showRecommendation = _isComplete;
 
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientTop, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
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
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                  ],
                ),
              ),
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
 
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.05),
          end: Offset.zero,
        ).animate(_headerFade),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training Setup',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Let's tailor your workouts.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
 
  Widget _buildTrainingCarousel() {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _trainingOptions.length,
        itemBuilder: (context, index) {
          final option = _trainingOptions[index];
          final isSelected = _selectedTrainingIndex == index;
 
          double delta = 0.0;
          if (_pageController.position.haveDimensions) {
            delta = index - _pageValue;
          } else {
            delta = index.toDouble();
          }
          final scale = (1 - (delta.abs() * 0.15)).clamp(0.85, 1.0);
          final rotation = (delta * 0.05).clamp(-0.12, 0.12);
 
          return GestureDetector(
            onTap: () => _selectTraining(index),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: isSelected ? 1.05 : scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isSelected
                          ? primaryGreen
                          : Colors.black.withValues(alpha: 0.05),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? primaryGreen.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: isSelected ? 24 : 14,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: isSelected
                                ? Container(
                                    key: const ValueKey('selected'),
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                : const SizedBox(
                                    key: ValueKey('unselected'),
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
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
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
 
  Widget _buildEquipmentWheel() {
    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primaryGreen.withValues(alpha: 0.25)),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _wheelController,
            itemExtent: 52,
            diameterRatio: 1.6,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: _selectEquipment,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _equipmentOptions.length,
              builder: (context, index) {
                final isSelected = _selectedEquipmentIndex == index;
                return AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 17,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? primaryGreen
                        : Colors.black.withValues(alpha: 0.35),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: isSelected ? 1.08 : 1.0,
                      child: Text(_equipmentOptions[index]),
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
 
  Widget _buildAdditionalEquipmentTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _additionalEquipmentExpanded,
          onExpansionChanged: (value) {
            setState(() => _additionalEquipmentExpanded = value);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          title: const Text(
            'Additional Equipment (Optional)',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          iconColor: primaryGreen,
          collapsedIconColor: Colors.black45,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_additionalEquipmentOptions.length,
                    (index) {
                  final isSelected =
                      _selectedAdditionalEquipment.contains(index);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    child: FilterChip(
                      label: Text(_additionalEquipmentOptions[index]),
                      selected: isSelected,
                      onSelected: (_) => _toggleAdditionalEquipment(index),
                      avatar: isSelected
                          ? const Icon(
                              Icons.fitness_center,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                      showCheckmark: false,
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? primaryGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      elevation: isSelected ? 4 : 0,
                      shadowColor: primaryGreen.withValues(alpha: 0.4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildRecommendationCard() {
    return ClipRRect(
      key: const ValueKey('recommendation'),
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _recommendationText,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
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
 
  Widget _buildBottomButton() {
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_buttonScale.value - 0.95) * 0.5 + 0.05,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _isComplete
            ? () { Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const ProgramGenerationScreen(),
          ),
        );
          
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _isComplete ? primaryGreen : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isComplete
                ? [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isComplete ? 'Generate My Program →' : 'Continue',
              key: ValueKey(_isComplete),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _isComplete ? Colors.white : Colors.grey.shade500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 
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