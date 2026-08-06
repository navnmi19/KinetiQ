import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gym_app/themes/theme_controller.dart';
import'package:gym_app/screens/progress/progress_screen.dart';
import'package:gym_app/screens/profile/profile_screen.dart';

/// -----------------------------------------------------------------------
/// PLACEHOLDER DATA MODELS
/// No backend / business logic — everything here is static demo data that
/// can be swapped for real values later. Mirrors the style of the
/// dashboard's placeholder models.
/// -----------------------------------------------------------------------

class MacroNutrient {
  final String label;
  final double currentGrams;
  final double targetGrams;
  final Color color;

  const MacroNutrient({
    required this.label,
    required this.currentGrams,
    required this.targetGrams,
    required this.color,
  });

  double get percent =>
      targetGrams == 0 ? 0 : (currentGrams / targetGrams).clamp(0, 1);
}

enum MealStatus { logged, upcoming }

class MealEntry {
  final String name;
  final String time;
  final String tag;
  final IconData icon;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final MealStatus status;

  const MealEntry({
    required this.name,
    required this.time,
    required this.tag,
    required this.icon,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.status = MealStatus.logged,
  });
}

/// A single data-driven AI insight line — no paragraphs, no generic
/// motivational copy. Always a metric + a one-line context.
class AIInsightItem {
  final String label;
  final String value;
  final String context;
  final bool isPositive;

  const AIInsightItem({
    required this.label,
    required this.value,
    required this.context,
    this.isPositive = true,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

/// -----------------------------------------------------------------------
/// NUTRITION SCREEN
/// -----------------------------------------------------------------------

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with TickerProviderStateMixin {
  // ---- palette (reuses global ThemeController — same source Dashboard uses) ----
  bool get isDarkMode => ThemeController.mode.value == ThemeMode.dark;

  Color get _bg => isDarkMode ? const Color(0xFF0B0B0D) : Colors.white;
  Color get _cardColor =>
      isDarkMode ? const Color(0xFF1A1A1D) : Colors.white;
  Color get _accent =>
      isDarkMode ? const Color(0xFFFF7A1A) : const Color(0xFF22C55E);
  Color get _textPrimary =>
      isDarkMode ? Colors.white : const Color(0xFF15181D);
  Color get _textSecondary =>
      isDarkMode ? Colors.white60 : const Color(0xFF6B7280);
  Color get _divider =>
      isDarkMode ? Colors.white12 : const Color(0xFFEFEFEF);
  Color get _downColor =>
      isDarkMode ? const Color(0xFFEF5350) : const Color(0xFFE53935);

  // ---- placeholder user info ----------------------------------------
  final String userName = "user"; // TODO: replace with real user name

  // ---- calories ------------------------------------------------------
  final double calorieGoal = 2400;
  final double calorieConsumed = 1560;
  final double calorieBurned = 340;

  double get calorieRemaining =>
      (calorieGoal - calorieConsumed + calorieBurned).clamp(0, calorieGoal);
  double get caloriePercent => (calorieConsumed / calorieGoal).clamp(0, 1);

  // ---- macros ----------------------------------------------------
  final List<MacroNutrient> macros = const [
    MacroNutrient(
      label: "Protein",
      currentGrams: 98,
      targetGrams: 150,
      color: Color(0xFFFF7A1A),
    ),
    MacroNutrient(
      label: "Carbs",
      currentGrams: 210,
      targetGrams: 300,
      color: Color(0xFF4FC3F7),
    ),
    MacroNutrient(
      label: "Fat",
      currentGrams: 40,
      targetGrams: 70,
      color: Color(0xFFAB47BC),
    ),
  ];

  // ---- water intake --------------------------------------------------
  final int totalGlasses = 8;
  late List<bool> filledGlasses;
  static const double glassMl = 250;

  // ---- AI nutrition insights ------------------------------------------
  final List<AIInsightItem> aiInsights = const [
    AIInsightItem(
      label: "Protein Intake",
      value: "65%",
      context: "of daily target reached",
      isPositive: true,
    ),
    AIInsightItem(
      label: "Calorie Pace",
      value: "On Track",
      context: "840 kcal remaining today",
      isPositive: true,
    ),
    AIInsightItem(
      label: "Sugar Intake",
      value: "▲22%",
      context: "Higher than usual — watch snacks",
      isPositive: false,
    ),
  ];

  // ---- today's meals --------------------------------------------------
  final List<MealEntry> meals = const [
    MealEntry(
      name: "Oats & Berries",
      time: "7:30 AM",
      tag: "Breakfast",
      icon: Icons.free_breakfast_rounded,
      calories: 420,
      protein: 22,
      carbs: 58,
      fat: 10,
    ),
    MealEntry(
      name: "Grilled Chicken Bowl",
      time: "1:15 PM",
      tag: "Lunch",
      icon: Icons.lunch_dining_rounded,
      calories: 610,
      protein: 48,
      carbs: 62,
      fat: 16,
    ),
    MealEntry(
      name: "Protein Shake",
      time: "4:00 PM",
      tag: "Snack",
      icon: Icons.local_cafe_rounded,
      calories: 220,
      protein: 28,
      carbs: 14,
      fat: 4,
    ),
    MealEntry(
      name: "Salmon & Veggies",
      time: "8:00 PM",
      tag: "Dinner",
      icon: Icons.dinner_dining_rounded,
      calories: 540,
      protein: 40,
      carbs: 30,
      fat: 22,
      status: MealStatus.upcoming,
    ),
  ];

  // ---- bottom nav -----------------------------------------------
  int navIndex = 1; // Nutrition tab active
  final List<_NavItem> navItems = const [
    _NavItem(icon: Icons.home_rounded, label: "Home"),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: "Nutrition"),
    _NavItem(icon: Icons.show_chart_rounded, label: "Progress"),
    _NavItem(icon: Icons.person_rounded, label: "Profile"),
  ];

  // ---- entry animation --------------------------------------------
  late final AnimationController _entryController;
  late final Animation<double> _entryFade;

  // ---- log meal button press feedback ---------------------------------
  bool _logButtonPressed = false;

  @override
  void initState() {
    super.initState();
    ThemeController.mode.addListener(_onThemeChanged);
    filledGlasses = List.generate(totalGlasses, (i) => i < 6);
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    ThemeController.mode.removeListener(_onThemeChanged);
    _entryController.dispose();
    super.dispose();
  }

  // ---- helpers -------------------------------------------------

  String get _greetingWord {
    final hour = TimeOfDay.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  static const List<String> _motivationalLines = [
    "Fuel today, perform tomorrow.",
    "Small choices, big results.",
    "Stay consistent with your intake.",
    "Every meal is a chance to recover better.",
    "Track it, don't guess it.",
  ];

  String get _motivationalLine {
    final dayOfYear = DateTime.now().day + DateTime.now().month * 31;
    return _motivationalLines[dayOfYear % _motivationalLines.length];
  }

  int get _glassesFilled => filledGlasses.where((f) => f).length;
  double get _litersFilled => (_glassesFilled * glassMl) / 1000;
  double get _litersGoal => (totalGlasses * glassMl) / 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _accent),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _bg,
        child: SafeArea(
          child: FadeTransition(
            opacity: _entryFade,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              22,
                              18,
                              22,
                              110,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 26),
                                _buildNutritionHeader(),
                                const SizedBox(height: 20),
                                _buildCaloriesCard(),
                                const SizedBox(height: 20),
                                _buildMacroCards(constraints.maxWidth),
                                const SizedBox(height: 20),
                                _buildWaterCard(),
                                const SizedBox(height: 20),
                                _buildAINutritionSnapshot(),
                                const SizedBox(height: 24),
                                _buildTodaysMealsHeader(),
                                const SizedBox(height: 14),
                                ...meals.map(
                                  (m) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    child: _buildMealCard(m),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    _buildBottomNav(),
                  ],
                ),
                _buildFloatingLogMealButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. GREETING
  // -------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingWord,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Hey, $userName 👋",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _motivationalLine,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: _accent,
            size: 17,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 2. NUTRITION HEADER
  // -------------------------------------------------------------

  Widget _buildNutritionHeader() {
    final now = DateTime.now();
    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    final dateLabel = "${weekdays[now.weekday - 1]}, ${now.day}/${now.month}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nutrition",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: _accent),
              const SizedBox(width: 6),
              Text(
                "Today",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 3. CALORIES PROGRESS
  // -------------------------------------------------------------

  Widget _buildCaloriesCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Calories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: _textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Goal 2,400",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 148,
                height: 148,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: caloriePercent),
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(148, 148),
                          painter: _RingPainter(
                            percent: value,
                            trackColor: Colors.white10,
                            progressColor: _accent,
                            strokeWidth: 14,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${(calorieGoal * value).round()}",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "kcal eaten",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _calorieStatRow(
                      icon: Icons.restaurant_rounded,
                      label: "Consumed",
                      value: "${calorieConsumed.round()} kcal",
                    ),
                    const SizedBox(height: 14),
                    _calorieStatRow(
                      icon: Icons.local_fire_department_rounded,
                      label: "Burned",
                      value: "${calorieBurned.round()} kcal",
                    ),
                    const SizedBox(height: 14),
                    _calorieStatRow(
                      icon: Icons.flag_rounded,
                      label: "Remaining",
                      value: "${calorieRemaining.round()} kcal",
                      highlighted: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calorieStatRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlighted = false,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: (highlighted ? _accent : Colors.white).withValues(
              alpha: highlighted ? 0.15 : 0.06,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 14,
            color: highlighted ? _accent : _textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: _textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: highlighted ? _accent : _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 4. MACRO CARDS
  // -------------------------------------------------------------

  Widget _buildMacroCards(double maxWidth) {
    return Row(
      children: List.generate(macros.length, (index) {
        final macro = macros[index];
        final isLast = index == macros.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: _macroCard(macro),
          ),
        );
      }),
    );
  }

  Widget _macroCard(MacroNutrient macro) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            macro.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${macro.currentGrams.round()}",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: _textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: "/${macro.targetGrams.round()}g",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: macro.percent),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(macro.color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 5. WATER INTAKE
  // -------------------------------------------------------------

  Widget _buildWaterCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Water Intake",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: _textPrimary,
                  ),
                ),
              ),
              Text(
                "${_litersFilled.toStringAsFixed(2)}L / ${_litersGoal.toStringAsFixed(1)}L",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (totalGlasses - 1)) /
                  totalGlasses;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalGlasses, (index) {
                  final filled = filledGlasses[index];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => filledGlasses[index] = !filled),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      width: itemWidth.clamp(24, 40),
                      height: 44,
                      decoration: BoxDecoration(
                        color: filled
                            ? _accent.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: filled ? _accent : _divider,
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        size: 18,
                        color: filled ? _accent : _textSecondary,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            "$_glassesFilled of $totalGlasses glasses • tap to log a glass",
            style: TextStyle(fontSize: 11.5, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 6. AI NUTRITION SNAPSHOT (premium highlighted card)
  // -------------------------------------------------------------

  Widget _buildAINutritionSnapshot() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accent.withValues(alpha: 0.16),
            _cardColor,
            _cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withValues(alpha: 0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: _accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "AI Nutrition Snapshot",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: _textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...aiInsights.asMap().entries.map((entry) {
            final isLast = entry.key == aiInsights.length - 1;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: item.isPositive ? _accent : _downColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.context,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 7. TODAY'S MEALS
  // -------------------------------------------------------------

  Widget _buildTodaysMealsHeader() {
    final logged = meals.where((m) => m.status == MealStatus.logged).length;
    return Row(
      children: [
        Expanded(
          child: Text(
            "Today's Meals",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
              color: _textPrimary,
            ),
          ),
        ),
        Text(
          "$logged/${meals.length} logged",
          style: TextStyle(fontSize: 12.5, color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealEntry meal) {
    final isUpcoming = meal.status == MealStatus.upcoming;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isUpcoming
            ? Border.all(color: _divider, width: 1)
            : null,
        boxShadow: isUpcoming
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUpcoming
                  ? Colors.white.withValues(alpha: 0.05)
                  : _accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              meal.icon,
              size: 20,
              color: isUpcoming ? _textSecondary : _accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${meal.calories} kcal",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isUpcoming ? _textSecondary : _textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "${meal.tag} • ${meal.time}",
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _macroChip("P", meal.protein, const Color(0xFFFF7A1A)),
                    const SizedBox(width: 8),
                    _macroChip("C", meal.carbs, const Color(0xFF4FC3F7)),
                    const SizedBox(width: 8),
                    _macroChip("F", meal.fat, const Color(0xFFAB47BC)),
                    const Spacer(),
                    if (isUpcoming)
                      Text(
                        "Upcoming",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      )
                    else
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: _accent,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String letter, int grams, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$letter $grams" "g",
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 8. FLOATING LOG MEAL BUTTON
  // -------------------------------------------------------------

  Widget _buildFloatingLogMealButton() {
    return Positioned(
      right: 20,
      bottom: 92,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _logButtonPressed = true),
        onTapUp: (_) => setState(() => _logButtonPressed = false),
        onTapCancel: () => setState(() => _logButtonPressed = false),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Log Meal — coming soon"),
              duration: Duration(milliseconds: 900),
            ),
          );
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _logButtonPressed ? 0.94 : 1.0,
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Log Meal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 9. BOTTOM NAVIGATION
  // -------------------------------------------------------------

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final selected = index == navIndex;
            final item = navItems[index];

            return GestureDetector(
              onTap: () {
                if (index == navIndex) return;

                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  return;
                }
                if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  );
                  return;
                }

                if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  return;
                }

                setState(() => navIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? _accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: selected ? _accent : _textSecondary,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: selected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                ),
                              ),
                            )
                          : const SizedBox(width: 0, height: 0),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SHARED CARD SHELL
  // -------------------------------------------------------------

  Widget _cardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// -----------------------------------------------------------------------
/// RING PAINTER — used for the circular calories progress indicator.
/// -----------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.percent,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: [
          progressColor.withValues(alpha: 0.55),
          progressColor,
        ],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}