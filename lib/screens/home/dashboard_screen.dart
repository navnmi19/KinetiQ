import 'package:flutter/material.dart';
import 'package:gym_app/screens/data/sample_workout.dart';
import 'package:gym_app/screens/workout/workout_flow_controller.dart';
import 'package:gym_app/themes/theme_controller.dart';
import '../social/social_home_screen.dart';
import '../nutrition/nutrition_screen.dart';

/// -----------------------------------------------------------------------
/// PLACEHOLDER DATA MODELS
/// No backend / business logic — everything here is static demo data that
/// can be swapped for real values later.
/// -----------------------------------------------------------------------

enum DayStatus { completed, rest, missed, upcoming }

class CalendarDay {
  final int dayNumber;
  final String weekday;
  final DayStatus status;

  const CalendarDay({
    required this.dayNumber,
    required this.weekday,
    required this.status,
  });
}

class WorkoutExercise {
  final String name;
  final String setsReps;
  final bool done;
  // Optional display-only fields used for the richer exercise preview.
  final String? weight;
  final String? previousWeight;
  final String? change;

  const WorkoutExercise({
    required this.name,
    required this.setsReps,
    required this.done,
    this.weight,
    this.previousWeight,
    this.change,
  });
}

/// Represents either "Today's Workout" or a past "Workout History" entry,
/// or a rest / missed day placeholder.
class WorkoutSession {
  final String title;
  final String tags;
  final String duration;
  final String statusLabel;
  final List<WorkoutExercise> exercises;
  final bool isRestDay;
  final bool isMissedDay;
  final bool isFutureDay;
  final bool isToday;
  final String? volume;
  final String? totalSets;
  final String? totalReps;

  const WorkoutSession({
    required this.title,
    required this.tags,
    required this.duration,
    required this.statusLabel,
    required this.exercises,
    this.isRestDay = false,
    this.isMissedDay = false,
    this.isFutureDay = false,
    this.isToday = false,
    this.volume,
    this.totalSets,
    this.totalReps,
  });
}

class QuickStat {
  final IconData icon;
  final String label;
  final String value;
  final bool isPositive;

  const QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPositive,
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

/// Tracks whether today's workout hasn't started, is in progress, or is
/// done — drives the Start / Resume / Summary button + floating bar.
enum WorkoutRunState { notStarted, inProgress, completed }

/// -----------------------------------------------------------------------
/// DASHBOARD SCREEN
/// -----------------------------------------------------------------------

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // ---- theme -------------------------------------------------------
  bool get isDarkMode => ThemeController.mode.value == ThemeMode.dark;

  // ---- placeholder user info ----------------------------------------
  final String userName = "user"; // TODO: replace with real user name

  // ---- calendar --------------------------------------------------
  final List<CalendarDay> calendarDays = const [
    CalendarDay(dayNumber: 5, weekday: "Mon", status: DayStatus.completed),
    CalendarDay(dayNumber: 6, weekday: "Tue", status: DayStatus.completed),
    CalendarDay(dayNumber: 7, weekday: "Wed", status: DayStatus.rest),
    CalendarDay(dayNumber: 8, weekday: "Thu", status: DayStatus.missed),
    CalendarDay(dayNumber: 9, weekday: "Fri", status: DayStatus.completed),
    CalendarDay(dayNumber: 10, weekday: "Sat", status: DayStatus.completed),
    CalendarDay(dayNumber: 11, weekday: "Sun", status: DayStatus.upcoming),
  ];

  // index 5 (Sat) is treated as "today" for this placeholder
  static const int todayIndex = 5;
  int selectedDayIndex = todayIndex;

  // ---- workout sessions per calendar day -----------------------------
  late final Map<int, WorkoutSession> sessionsByDay = {
    0: const WorkoutSession(
      title: "Pull Day",
      tags: "Back • Biceps",
      duration: "50 min",
      statusLabel: "Completed",
      volume: "6,200 kg",
      totalSets: "16",
      totalReps: "128",
      exercises: [
        WorkoutExercise(name: "Deadlift", setsReps: "4 × 6", done: true),
        WorkoutExercise(name: "Lat Pulldown", setsReps: "3 × 10", done: true),
        WorkoutExercise(name: "Barbell Row", setsReps: "3 × 10", done: true),
      ],
    ),
    1: const WorkoutSession(
      title: "Leg Day",
      tags: "Quads • Hamstrings • Glutes",
      duration: "55 min",
      statusLabel: "Completed",
      volume: "6,800 kg",
      totalSets: "17",
      totalReps: "136",
      exercises: [
        WorkoutExercise(name: "Back Squat", setsReps: "4 × 8", done: true),
        WorkoutExercise(name: "Leg Press", setsReps: "3 × 12", done: true),
        WorkoutExercise(
          name: "Romanian Deadlift",
          setsReps: "3 × 10",
          done: true,
        ),
      ],
    ),
    2: const WorkoutSession(
      title: "Rest Day",
      tags: "Recovery",
      duration: "—",
      statusLabel: "🌙 Scheduled rest",
      isRestDay: true,
      exercises: [],
    ),
    3: const WorkoutSession(
      title: "Push Day",
      tags: "Chest • Shoulders • Triceps",
      duration: "0 min",
      statusLabel: "⚠ Missed workout",
      isMissedDay: true,
      exercises: [
        WorkoutExercise(name: "Bench Press", setsReps: "4 × 8", done: false),
        WorkoutExercise(name: "Incline Press", setsReps: "3 × 10", done: false),
        WorkoutExercise(
          name: "Shoulder Press",
          setsReps: "3 × 12",
          done: false,
        ),
      ],
    ),
    4: const WorkoutSession(
      title: "Push Day",
      tags: "Chest • Shoulders • Triceps",
      duration: "56 min",
      statusLabel: "⭐ New PR",
      volume: "7,120 kg",
      totalSets: "18",
      totalReps: "144",
      exercises: [
        WorkoutExercise(name: "Bench Press", setsReps: "4 × 8", done: true),
        WorkoutExercise(name: "Incline Press", setsReps: "3 × 10", done: true),
        WorkoutExercise(name: "Shoulder Press", setsReps: "3 × 12", done: true),
      ],
    ),
    5: const WorkoutSession(
      title: "Push Day",
      tags: "Chest • Shoulders • Triceps",
      duration: "58 min",
      statusLabel: "🔥 12-Day Streak",
      isToday: true,
      exercises: [
        WorkoutExercise(
          name: "Bench Press",
          setsReps: "4 × 8",
          done: true,
          weight: "60 kg",
          previousWeight: "55 kg",
          change: "▲ +9%",
        ),
        WorkoutExercise(
          name: "Incline Press",
          setsReps: "3 × 10",
          done: true,
          weight: "40 kg",
          previousWeight: "38 kg",
          change: "▲ +5%",
        ),
        WorkoutExercise(
          name: "Shoulder Press",
          setsReps: "3 × 12",
          done: true,
          weight: "24 kg",
          previousWeight: "24 kg",
          change: "— 0%",
        ),
      ],
    ),
    6: const WorkoutSession(
      title: "Pull Day",
      tags: "Back • Biceps",
      duration: "—",
      statusLabel: "Recovery Day Recommended",
      isFutureDay: true,
      exercises: [
        WorkoutExercise(name: "Deadlift", setsReps: "4 × 6", done: false),
        WorkoutExercise(name: "Lat Pulldown", setsReps: "3 × 10", done: false),
        WorkoutExercise(name: "Barbell Row", setsReps: "3 × 10", done: false),
      ],
    ),
  };

  // ---- graph state --------------------------------------------------
  final List<String> metrics = const [
    "Strength",
    "Workout Volume",
    "Weight",
    "Body Fat",
    "Calories",
    "Workout Time",
    "Running Distance",
    "Steps",
  ];

  final List<String> periods = const ["Week", "Month"];

  // Display-only labels shown on the pill (spec: "Weekly ▼" not "Week ▼").
  static const Map<String, String> _periodDisplayLabels = {
    "Week": "Weekly",
    "Month": "Monthly",
  };

  String selectedMetric = "Workout Volume";
  String selectedPeriod = "Week";

  int? touchedIndex;

  // 6-day weekly placeholder series (Mon–Sat), where the last two points
  // are used for the "today vs yesterday" comparison.
  final Map<String, List<double>> weeklyData = const {
    "Strength": [62, 64, 65, 63, 67, 70],
    "Workout Volume": [6200, 6800, 0, 0, 7120, 8450],
    "Weight": [78.4, 78.2, 78.1, 78.3, 78.0, 77.7],
    "Body Fat": [18.5, 18.4, 18.4, 18.3, 18.2, 18.0],
    "Calories": [2400, 2600, 2100, 2050, 2550, 2700],
    "Workout Time": [48, 52, 0, 0, 55, 58],
    "Running Distance": [3.2, 0, 0, 0, 4.1, 5.0],
    "Steps": [8200, 9100, 6400, 5800, 9600, 10200],
  };

  final Map<String, String> metricUnits = const {
    "Strength": " pts",
    "Workout Volume": " kg",
    "Weight": " kg",
    "Body Fat": "%",
    "Calories": " kcal",
    "Workout Time": " min",
    "Running Distance": " km",
    "Steps": "",
  };

  final List<String> weekLabels = const [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];
  final List<String> monthLabels = const [
    "Week 1",
    "Week 2",
    "Week 3",
    "Week 4",
  ];

  // AI insight — data-driven metric lines, never a paragraph.
  final List<AIInsightItem> aiInsights = const [
    AIInsightItem(
      label: "Chest Volume",
      value: "▲18%",
      context: "Compared to last week",
      isPositive: true,
    ),
    AIInsightItem(
      label: "Bench Press",
      value: "▲7%",
      context: "New strength peak",
      isPositive: true,
    ),
    AIInsightItem(
      label: "Recovery Score",
      value: "82%",
      context: "Ready for heavy training",
      isPositive: true,
    ),
  ];

  // Quick stats — exactly four
  final List<QuickStat> quickStats = const [
    QuickStat(
      icon: Icons.trending_up,
      label: "Strength",
      value: "+12%",
      isPositive: true,
    ),
    QuickStat(
      icon: Icons.bar_chart_rounded,
      label: "Volume",
      value: "+18%",
      isPositive: true,
    ),
    QuickStat(
      icon: Icons.monitor_weight_outlined,
      label: "Weight",
      value: "-1.3 kg",
      isPositive: true,
    ),
    QuickStat(
      icon: Icons.local_fire_department_rounded,
      label: "Streak",
      value: "12 days",
      isPositive: true,
    ),
  ];

  // ---- bottom nav -----------------------------------------------
  int navIndex = 0;
  final List<_NavItem> navItems = const [
    _NavItem(icon: Icons.home_rounded, label: "Home"),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: "Nutrition"),
    _NavItem(icon: Icons.show_chart_rounded, label: "Progress"),
    _NavItem(icon: Icons.person_rounded, label: "Friends"),
  ];

  // ---- active workout tracking (today only) --------------------------
  WorkoutRunState workoutRunState = WorkoutRunState.notStarted;
  int completedExerciseCount = 0;
  final int totalExercisesToday = 9;

  void _startWorkout() {
    setState(() {
      workoutRunState = WorkoutRunState.inProgress;
      completedExerciseCount = 1;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutFlowController(initialSession: sampleWorkoutSession),
      ),
    );
  }

  void _advanceActiveWorkout() {
    setState(() {
      completedExerciseCount = (completedExerciseCount + 1).clamp(
        0,
        totalExercisesToday,
      );
      if (completedExerciseCount >= totalExercisesToday) {
        workoutRunState = WorkoutRunState.completed;
      }
    });
  }

  // ---- entry animation --------------------------------------------
  late final AnimationController _entryController;
  late final Animation<double> _entryFade;

  @override
  void initState() {
    super.initState();
    ThemeController.mode.addListener(_onThemeChanged);
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
    "Today's effort becomes tomorrow's strength.",
    "Stay consistent.",
    "Progress compounds over time.",
    "Every rep counts.",
    "Ready to beat yesterday?",
  ];

  String get _motivationalLine {
    final dayOfYear = DateTime.now().day + DateTime.now().month * 31;
    return _motivationalLines[dayOfYear % _motivationalLines.length];
  }

  List<double> get _currentSeries {
    if (selectedPeriod == "Week") {
      return weeklyData[selectedMetric]!;
    }
    // Placeholder monthly aggregation derived from the weekly series —
    // purely cosmetic demo data, not a real computation pipeline.
    final weekly = weeklyData[selectedMetric]!;
    final nonZero = weekly.where((v) => v > 0).toList();
    final avg = nonZero.isEmpty
        ? 0.0
        : nonZero.reduce((a, b) => a + b) / nonZero.length;
    return [avg * 0.88, avg * 0.95, avg * 1.02, avg * 1.1];
  }

  List<String> get _currentLabels =>
      selectedPeriod == "Week" ? weekLabels : monthLabels;

  double get _todayValue => _currentSeries.last;
  double get _yesterdayValue => _currentSeries[_currentSeries.length - 2];

  double get _percentChange {
    if (_yesterdayValue == 0) return 0;
    return ((_todayValue - _yesterdayValue) / _yesterdayValue) * 100;
  }

  static const Set<String> _decimalMetrics = {
    "Weight",
    "Body Fat",
    "Running Distance",
  };

  String _formatValue(double v) {
    final unit = metricUnits[selectedMetric] ?? "";
    if (_decimalMetrics.contains(selectedMetric)) {
      return "${v.toStringAsFixed(1)}$unit";
    }
    return "${v.round()}$unit";
  }

  // ---- palette -------------------------------------------------

  Color get _bgTop => isDarkMode ? Colors.black : const Color(0xFFD1FAE5);
  Color get _bgBottom => isDarkMode ? Colors.black : Colors.white;
  Color get _cardColor => isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _workoutCardColor =>
      isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFE0EEFF);
  Color get _accent =>
      isDarkMode ? const Color(0xFFFF7A1A) : const Color(0xFF22C55E);
  Color get _textPrimary => isDarkMode ? Colors.white : const Color(0xFF15181D);
  Color get _textSecondary =>
      isDarkMode ? Colors.white60 : const Color(0xFF6B7280);
  Color get _divider => isDarkMode ? Colors.white12 : const Color(0xFFEFEFEF);
  Color get _downColor =>
      isDarkMode ? const Color(0xFFEF5350) : const Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final showFloatingBar = workoutRunState == WorkoutRunState.inProgress;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _entryFade,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          22,
                          18,
                          22,
                          showFloatingBar ? 96 : 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 30),
                            _buildCalendar(),
                            const SizedBox(height: 26),
                            _buildGraphCard(),
                            const SizedBox(height: 20),
                            _buildWorkoutCard(),
                            const SizedBox(height: 20),
                            _buildAIInsightCard(),
                            const SizedBox(height: 20),
                            _buildQuickStats(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomNav(),
                  ],
                ),
                _buildFloatingWorkoutBar(showFloatingBar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // HEADER
  // -------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: _accent,
                ),
                child: Text(_greetingWord),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                  color: _textPrimary,
                ),
                child: Text("Hey, $userName 👋"),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: _textSecondary,
                ),
                child: Text(_motivationalLine),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Column(
          children: [
            _buildThemeToggle(),
            const SizedBox(height: 10),
            _buildTrophyButton(),
          ],
        ),
      ],
    );
  }

  /// Small animated pill switch — replaces the old circular icon button.
  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () => ThemeController.toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        width: 60,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A2D) : const Color(0xFFEFF6F0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOut,
              alignment: isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Opacity(
                      opacity: isDarkMode ? 1 : 0,
                      child: const Text("☀️", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Opacity(
                      opacity: isDarkMode ? 0 : 1,
                      child: const Text("🌙", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Achievements coming soon"),
            duration: Duration(milliseconds: 900),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.emoji_events_rounded, color: _accent, size: 16),
      ),
    );
  }

  // -------------------------------------------------------------
  // CALENDAR
  // -------------------------------------------------------------

  Widget _buildCalendar() {
    return TweenAnimationBuilder<Offset>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      tween: Tween(begin: const Offset(0.05, 0), end: Offset.zero),
      builder: (context, offset, child) =>
          Transform.translate(offset: Offset(offset.dx * 40, 0), child: child),
      child: SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: calendarDays.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final day = calendarDays[index];
            final selected = index == selectedDayIndex;

            return GestureDetector(
              onTap: () => setState(() => selectedDayIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                width: selected ? 56 : 52,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _accent : _cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.38),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDarkMode ? 0.25 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.weekday,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white70 : _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "${day.dayNumber}",
                      style: TextStyle(
                        fontSize: selected ? 17 : 16,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _statusDot(day.status, selected),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tiny colored dot indicator — green (completed), orange (rest),
  /// red (missed). Replaces the old ✓ ✕ 🌙 glyphs.
  Widget _statusDot(DayStatus status, bool selected) {
    late final Color color;
    switch (status) {
      case DayStatus.completed:
        color = const Color(0xFF22C55E);
        break;
      case DayStatus.rest:
        color = const Color(0xFFF59E0B);
        break;
      case DayStatus.missed:
        color = const Color(0xFFE53935);
        break;
      case DayStatus.upcoming:
        color = selected ? Colors.white70 : _textSecondary;
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: selected ? Colors.white : color,
        shape: BoxShape.circle,
        boxShadow: selected
            ? []
            : [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
      ),
    );
  }

  // -------------------------------------------------------------
  // GRAPH CARD
  // -------------------------------------------------------------

  Widget _buildGraphCard() {
    final series = _currentSeries;
    final isUp = _percentChange >= 0;

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedMetric,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: _textPrimary,
                  ),
                ),
              ),
              _pillDropdown(
                value: selectedPeriod,
                options: periods,
                displayLabels: _periodDisplayLabels,
                onChanged: (v) => setState(() {
                  selectedPeriod = v;
                  touchedIndex = null;
                }),
              ),
              const SizedBox(width: 8),
              _pillDropdown(
                value: selectedMetric,
                options: metrics,
                onChanged: (v) => setState(() {
                  selectedMetric = v;
                  touchedIndex = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Floating comparison pill — the hero call-out for the graph.
          _buildComparisonPill(isUp),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: TweenAnimationBuilder<double>(
              key: ValueKey("$selectedMetric-$selectedPeriod"),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, progress, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      onPanDown: (details) =>
                          _updateTouch(details.localPosition, size, series),
                      onPanUpdate: (details) =>
                          _updateTouch(details.localPosition, size, series),
                      onPanEnd: (_) => setState(() => touchedIndex = null),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: size,
                            painter: _SplinePainter(
                              values: series,
                              progress: progress,
                              lineColor: _accent,
                              touchedIndex: touchedIndex,
                            ),
                          ),
                          if (touchedIndex != null)
                            _buildTooltip(size, series, touchedIndex!),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _currentLabels
                .map(
                  (l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: _textSecondary),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Divider(color: _divider, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _comparisonBlock(
                  label: "Today",
                  value: _formatValue(_todayValue),
                ),
              ),
              Expanded(
                child: _comparisonBlock(
                  label: "Yesterday",
                  value: _formatValue(_yesterdayValue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Today's Comparison ▲ +18.4%" floating pill above the graph.
  Widget _buildComparisonPill(bool isUp) {
    return TweenAnimationBuilder<double>(
      key: ValueKey("pill-$selectedMetric-$selectedPeriod"),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : (isUp
                    ? _accent.withValues(alpha: 0.08)
                    : _downColor.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              "Today's Comparison",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
            const Spacer(),
            Icon(
              isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 15,
              color: isUp ? _accent : _downColor,
            ),
            const SizedBox(width: 2),
            Text(
              "${_percentChange.abs().toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isUp ? _accent : _downColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTouch(Offset localPosition, Size size, List<double> series) {
    final dx = size.width / (series.length - 1);
    int index = (localPosition.dx / dx).round();
    index = index.clamp(0, series.length - 1);
    setState(() => touchedIndex = index);
  }

  Widget _buildTooltip(Size size, List<double> series, int index) {
    final point = _computePoint(index, size, series);
    final label = _formatValue(series[index]);

    double left = point.dx - 34;
    left = left.clamp(0, size.width - 68);
    double top = (point.dy - 38).clamp(0, size.height - 30);

    return Positioned(
      left: left,
      top: top,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white : Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _comparisonBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: _textSecondary)),
        const SizedBox(height: 5),
        TweenAnimationBuilder<double>(
          key: ValueKey("$value-$label"),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, t, _) => Opacity(
            opacity: t,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillDropdown({
    required String value,
    required List<String> options,
    Map<String, String>? displayLabels,
    required ValueChanged<String> onChanged,
  }) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => options
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              child: Text(
                displayLabels?[o] ?? o,
                style: TextStyle(color: _textPrimary, fontSize: 14),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 92),
              child: Text(
                displayLabels?[value] ?? value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: _textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WORKOUT CARD / HISTORY CARD
  // -------------------------------------------------------------

  Widget _buildWorkoutCard() {
    final session = sessionsByDay[selectedDayIndex]!;
    final isToday = selectedDayIndex == todayIndex;
    final incomplete =
        isToday &&
        !session.isRestDay &&
        workoutRunState != WorkoutRunState.completed;

    final card = Container(
      key: ValueKey(selectedDayIndex),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _workoutCardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
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
              Expanded(
                child: Text(
                  isToday ? "Today's Workout" : "Workout History",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: _textSecondary,
                  ),
                ),
              ),
              if (isToday && !session.isRestDay)
                _PulseBadge(
                  color: _accent,
                  enabled: incomplete,
                  child: Text(
                    _statusLabelForRunState(session.statusLabel),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                )
              else
                Text(
                  session.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: session.isMissedDay ? _downColor : _textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            session.tags,
            style: TextStyle(fontSize: 13.5, color: _textSecondary),
          ),
          const SizedBox(height: 4),
          if (!session.isRestDay)
            Text(
              session.duration,
              style: TextStyle(fontSize: 13.5, color: _textSecondary),
            ),

          if (!session.isToday &&
              !session.isRestDay &&
              !session.isFutureDay) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _historyStat("Volume", session.volume ?? "-"),
                _historyStat("Sets", session.totalSets ?? "-"),
                _historyStat("Reps", session.totalReps ?? "-"),
              ],
            ),
          ],

          if (session.exercises.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: _divider, height: 1),
            const SizedBox(height: 14),
            ...session.exercises.take(3).map((ex) => _exerciseRow(ex)),
          ],

          const SizedBox(height: 18),

          if (session.isRestDay)
            Text(
              "Recovery day — no exercises scheduled.",
              style: TextStyle(fontSize: 13, color: _textSecondary),
            )
          else if (isToday)
            _buildTodayActionButton()
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: _accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "View Full Workout",
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: card,
    );
  }

  String _statusLabelForRunState(String fallback) {
    switch (workoutRunState) {
      case WorkoutRunState.inProgress:
        return "In Progress";
      case WorkoutRunState.completed:
        return "Completed";
      case WorkoutRunState.notStarted:
        return fallback;
    }
  }

  /// Exactly one primary action is shown at a time, per spec:
  /// Start Workout → Resume Workout → View Workout Summary.
  Widget _buildTodayActionButton() {
    late final String label;
    late final VoidCallback onPressed;

    switch (workoutRunState) {
      case WorkoutRunState.notStarted:
        label = "Start Workout";
        onPressed = _startWorkout;
        break;
      case WorkoutRunState.inProgress:
        label = "Resume Workout";
        onPressed = () {};
        break;
      case WorkoutRunState.completed:
        label = "View Workout Summary";
        onPressed = () {};
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _exerciseRow(WorkoutExercise ex) {
    final hasWeight = ex.weight != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ex.setsReps,
                  style: TextStyle(fontSize: 12.5, color: _textSecondary),
                ),
              ],
            ),
          ),
          if (hasWeight)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ex.weight!,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Prev ${ex.previousWeight ?? '-'}",
                    style: TextStyle(fontSize: 11.5, color: _textSecondary),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          if (ex.change != null)
            Text(
              ex.change!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ex.change!.contains('▲') ? _accent : _textSecondary,
              ),
            )
          else
            Icon(
              ex.done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: ex.done ? _accent : _textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _historyStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: _textSecondary)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // FLOATING ACTIVE WORKOUT BAR (Spotify-style mini player)
  // -------------------------------------------------------------

  Widget _buildFloatingWorkoutBar(bool visible) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      left: 16,
      right: 16,
      bottom: visible ? 84 : -100,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1 : 0,
        child: GestureDetector(
          onTap: _advanceActiveWorkout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Workout in Progress",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$completedExerciseCount / $totalExercisesToday Exercises",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          tween: Tween<double>(
                            begin: 0,
                            end: completedExerciseCount / totalExercisesToday,
                          ),
                          builder: (context, value, _) =>
                              LinearProgressIndicator(
                                value: value,
                                minHeight: 5,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(_accent),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Resume",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: _accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // AI INSIGHT CARD
  // -------------------------------------------------------------

  Widget _buildAIInsightCard() {
    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: _accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "AI Insight",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  color: _textPrimary,
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
                      style: TextStyle(fontSize: 12, color: _textSecondary),
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
  // QUICK STATS — 2 x 2 grid with count-up numbers
  // -------------------------------------------------------------

  Widget _buildQuickStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _quickStatTile(quickStats[0])),
            const SizedBox(width: 12),
            Expanded(child: _quickStatTile(quickStats[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _quickStatTile(quickStats[2])),
            const SizedBox(width: 12),
            Expanded(child: _quickStatTile(quickStats[3])),
          ],
        ),
      ],
    );
  }

  Widget _quickStatTile(QuickStat stat) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: (stat.isPositive ? _accent : _downColor).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              stat.icon,
              size: 16,
              color: stat.isPositive ? _accent : _downColor,
            ),
          ),
          const SizedBox(height: 12),
          _CountUpText(
            targetText: stat.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stat.label,
            style: TextStyle(fontSize: 12, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // BOTTOM NAV
  // -------------------------------------------------------------

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
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
  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NutritionScreen(),
      ),
    );
    return;
  }

  if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SocialHomeScreen(),
      ),
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
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

Offset _computePoint(int index, Size size, List<double> values) {
  final maxVal = values.reduce((a, b) => a > b ? a : b);
  final minVal = values.reduce((a, b) => a < b ? a : b);
  final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
  final dx = size.width / (values.length - 1);
  final normalized = (values[index] - minVal) / range;
  final y =
      size.height - (normalized * size.height * 0.75) - size.height * 0.12;
  return Offset(dx * index, y);
}

class _SplinePainter extends CustomPainter {
  final List<double> values;
  final double progress;
  final Color lineColor;
  final int? touchedIndex;

  _SplinePainter({
    required this.values,
    required this.progress,
    required this.lineColor,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final points = List.generate(
      values.length,
      (i) => _computePoint(i, size, values),
    );

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i + 2 < points.length) ? points[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final revealPath = Path();
    for (final metric in path.computeMetrics()) {
      revealPath.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }

    // soft fill under the line
    final fillMetrics = revealPath.computeMetrics().toList();
    if (fillMetrics.isNotEmpty) {
      final fillPath = Path.from(revealPath);
      final lastMetric = fillMetrics.last;
      final tangent = lastMetric.getTangentForOffset(lastMetric.length);
      final lastPoint = tangent?.position ?? points.last;

      fillPath.lineTo(lastPoint.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.22),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(revealPath, linePaint);

    if (touchedIndex != null &&
        touchedIndex! >= 0 &&
        touchedIndex! < points.length) {
      final p = points[touchedIndex!];
      canvas.drawCircle(
        p,
        8,
        Paint()..color = lineColor.withValues(alpha: 0.2),
      );
      canvas.drawCircle(p, 4.5, Paint()..color = lineColor);
      canvas.drawCircle(
        p,
        4.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.progress != progress ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.lineColor != lineColor;
  }
}

/// Small pulsing badge used on the "today, not yet fully complete" state
/// of the workout card. Kept isolated so the rest of the screen can stay
/// implicit-animation only.
class _PulseBadge extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool enabled;

  const _PulseBadge({
    required this.child,
    required this.color,
    this.enabled = true,
  });

  @override
  State<_PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<_PulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.97,
    end: 1.05,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.enabled
          ? _scale
          : const AlwaysStoppedAnimation<double>(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Animates a numeric-prefixed string (e.g. "+12%", "-1.3 kg", "12 days")
/// counting up from zero to its target value, preserving sign/suffix.
class _CountUpText extends StatelessWidget {
  final String targetText;
  final TextStyle style;

  const _CountUpText({required this.targetText, required this.style});

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^([+-]?)(\d+(\.\d+)?)(.*)$').firstMatch(targetText);
    if (match == null) {
      return Text(targetText, style: style);
    }
    final sign = match.group(1) ?? '';
    final numberStr = match.group(2) ?? '0';
    final suffix = match.group(4) ?? '';
    final targetValue = double.tryParse(numberStr) ?? 0;
    final isDecimal = numberStr.contains('.');

    return TweenAnimationBuilder<double>(
      key: ValueKey(targetText),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: targetValue),
      builder: (context, value, _) {
        final display = isDecimal
            ? value.toStringAsFixed(1)
            : value.round().toString();
        return Text("$sign$display$suffix", style: style);
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
