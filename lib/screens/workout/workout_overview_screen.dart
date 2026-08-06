import 'package:flutter/material.dart';
import '../../../models/exercise_model.dart';
import '../../../widgets/exercise_help_sheet.dart';
import 'package:gym_app/themes/theme_controller.dart';

class WorkoutOverviewScreen extends StatefulWidget {
  final WorkoutSession session;
  final void Function(WorkoutSession reorderedSession) onStartWorkout;

  const WorkoutOverviewScreen({
    super.key,
    required this.session,
    required this.onStartWorkout,
  });

  @override
  State<WorkoutOverviewScreen> createState() => _WorkoutOverviewScreenState();
}

class _WorkoutOverviewScreenState extends State<WorkoutOverviewScreen> {
  late List<Exercise> _exercises;
  late TextEditingController _workoutNameController;

  bool _isCustomMode = false;
  int _selectedDayIndex = 0;

  String _equipmentQuery = '';
  String _bodyPartQuery = '';
  final Set<String> _equipmentFilters = {};
  final Set<String> _bodyPartFilters = {};

  int _catalogAddCounter = 0;

  @override
  void initState() {
    super.initState();
    _exercises = List.of(widget.session.exercises);
    _workoutNameController = TextEditingController(text: widget.session.name);
    _selectedDayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  Duration get _estimatedDuration =>
      widget.session.copyWith(exercises: _exercises).estimatedDuration;

  Set<String> get _muscleGroups =>
      widget.session.copyWith(exercises: _exercises).muscleGroups;

  String get _greeting {
    final hour = TimeOfDay.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static const List<String> _punchlines = [
    'Show up. The rest follows.',
    'Strength is built one rep at a time.',
    'Your only competition is yesterday.',
  ];

  String get _punchline {
    final dayOfYear = DateTime.now().day + DateTime.now().month * 31;
    return _punchlines[dayOfYear % _punchlines.length];
  }

  static const List<String> _weekdayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _formattedDate {
    final now = DateTime.now();
    return '${_weekdayNames[now.weekday - 1]}, ${_monthNames[now.month - 1]} ${now.day}';
  }

  List<_CatalogExercise> get _filteredCatalog {
    return _exerciseCatalog.where((e) {
      final matchesEquipmentQuery = _equipmentQuery.isEmpty ||
          e.equipment.toLowerCase().contains(_equipmentQuery.toLowerCase());
      final matchesBodyPartQuery = _bodyPartQuery.isEmpty ||
          e.bodyPart.toLowerCase().contains(_bodyPartQuery.toLowerCase());
      final matchesEquipmentFilter =
          _equipmentFilters.isEmpty || _equipmentFilters.contains(e.equipment);
      final matchesBodyPartFilter =
          _bodyPartFilters.isEmpty || _bodyPartFilters.contains(e.bodyPart);
      return matchesEquipmentQuery &&
          matchesBodyPartQuery &&
          matchesEquipmentFilter &&
          matchesBodyPartFilter;
    }).toList();
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  void _updateSets(int index, int delta) {
    setState(() {
      final ex = _exercises[index];
      _exercises[index] = ex.copyWith(sets: (ex.sets + delta).clamp(1, 20));
    });
  }

  void _updateReps(int index, int delta) {
    setState(() {
      final ex = _exercises[index];
      _exercises[index] = ex.copyWith(reps: (ex.reps + delta).clamp(1, 50));
    });
  }

  void _addFromCatalog(_CatalogExercise catalogExercise) {
    setState(() {
      _catalogAddCounter++;
      _exercises.add(
        Exercise(
          id: '${catalogExercise.id}_$_catalogAddCounter',
          name: catalogExercise.name,
          sets: 3,
          reps: 10,
          weight: 0,
          muscleGroup: catalogExercise.bodyPart,
          description: '',
          instructions: const [],
          commonMistakes: const [],
          youtubeUrl: '',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        final Color bgColor = isDark ? const Color(0xFF090909) : Colors.white;
        final Color cardColor = isDark ? const Color(0xFF141414) : Colors.white;
        final Color panelColor =
            isDark ? const Color(0xFF141414) : const Color(0xFFF7F7F7);
        final Color chipBg = isDark ? Colors.white10 : const Color(0xFFF0F0F0);
        final Color textColor = isDark ? Colors.white : const Color(0xFF14532D);
        final Color mutedColor = isDark
            ? Colors.white60
            : const Color(0xFF14532D).withValues(alpha: 0.6);
        final Color accent =
            isDark ? const Color(0xFFFF8A00) : const Color(0xFF22C55E);
        final Color dividerColor = isDark ? Colors.white12 : Colors.black12;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, textColor),
                _buildGreetingRow(textColor, mutedColor, accent),
                const SizedBox(height: 14),
                _buildModeToggle(chipBg, accent, mutedColor),
                const SizedBox(height: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_isCustomMode),
                      child: _isCustomMode
                          ? _buildCustomBody(
                              cardColor,
                              panelColor,
                              chipBg,
                              textColor,
                              mutedColor,
                              accent,
                              dividerColor,
                              isDark,
                            )
                          : _buildAiRecommendedBody(
                              cardColor,
                              textColor,
                              mutedColor,
                              accent,
                              isDark,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TOP: back button, greeting/date, mode toggle
  // -------------------------------------------------------------

  Widget _buildTopBar(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingRow(Color textColor, Color mutedColor, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _punchline,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _greeting,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _todaysWorkoutBadge(accent),
        ],
      ),
    );
  }

  Widget _todaysWorkoutBadge(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        "TODAY'S WORKOUT",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: accent,
        ),
      ),
    );
  }

  Widget _buildModeToggle(Color chipBg, Color accent, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            Expanded(
              child: _modeSegmentButton(
                'AI Recommended',
                !_isCustomMode,
                accent,
                mutedColor,
                () => setState(() => _isCustomMode = false),
              ),
            ),
            Expanded(
              child: _modeSegmentButton(
                'Custom',
                _isCustomMode,
                accent,
                mutedColor,
                () => setState(() => _isCustomMode = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeSegmentButton(
    String label,
    bool selected,
    Color accent,
    Color mutedColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : mutedColor,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // AI RECOMMENDED — single card only
  // -------------------------------------------------------------

  Widget _buildAiRecommendedBody(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color accent,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
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
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI Recommended',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.session.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Built from your recent training load and recovery.',
                  style: TextStyle(fontSize: 13, color: mutedColor),
                ),
                const SizedBox(height: 18),
                _buildMetaRow(textColor, mutedColor, accent),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Text(
                      'No exercises in this plan yet.',
                      style: TextStyle(fontSize: 13, color: mutedColor),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: _exercises.length,
                    onReorder: _handleReorder,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _AiExerciseRow(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        index: index,
                        cardColor: cardColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        accent: accent,
                        isDark: isDark,
                        onInfo: () => ExerciseHelpSheet.show(context, exercise),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          _buildStartButton(context, accent, isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetaRow(Color textColor, Color mutedColor, Color accent) {
    final minutes = _estimatedDuration.inMinutes;

    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 18, color: mutedColor),
        const SizedBox(width: 6),
        Text(
          '~$minutes min',
          style: TextStyle(fontSize: 14, color: mutedColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _muscleGroups
                .map((group) => _MuscleTag(label: group, accent: accent))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, Color accent, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => widget.onStartWorkout(
          widget.session.copyWith(
            name: _workoutNameController.text,
            exercises: _exercises,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'Start Workout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // CUSTOM — split screen
  // -------------------------------------------------------------

  Widget _buildCustomBody(
    Color cardColor,
    Color panelColor,
    Color chipBg,
    Color textColor,
    Color mutedColor,
    Color accent,
    Color dividerColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildLeftPanel(cardColor, chipBg, textColor, mutedColor, accent, isDark),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: dividerColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildRightPanel(panelColor, chipBg, textColor, mutedColor, accent, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(
    Color cardColor,
    Color chipBg,
    Color textColor,
    Color mutedColor,
    Color accent,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDaySelector(chipBg, accent, mutedColor),
        const SizedBox(height: 14),
        _buildWorkoutNameField(cardColor, textColor, mutedColor, isDark),
        const SizedBox(height: 12),
        _buildMetaRow(textColor, mutedColor, accent),
        const SizedBox(height: 10),
        Expanded(
          child: _exercises.isEmpty
              ? Center(
                  child: Text(
                    'No exercises yet — add some from the right panel',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: _exercises.length,
                  onReorder: _handleReorder,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return _CustomExerciseRow(
                      key: ValueKey(exercise.id),
                      exercise: exercise,
                      index: index,
                      cardColor: cardColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accent: accent,
                      isDark: isDark,
                      onInfo: () => ExerciseHelpSheet.show(context, exercise),
                      onDelete: () => _removeExercise(index),
                      onSetsChanged: (delta) => _updateSets(index, delta),
                      onRepsChanged: (delta) => _updateReps(index, delta),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        _buildStartButton(context, accent, isDark),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDaySelector(Color chipBg, Color accent, Color mutedColor) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dayLabels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? accent : chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : mutedColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutNameField(
    Color cardColor,
    Color textColor,
    Color mutedColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: TextField(
        controller: _workoutNameController,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: 'Workout name',
          hintStyle: TextStyle(color: mutedColor),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // CUSTOM — right panel: Add Exercises
  // -------------------------------------------------------------

  Widget _buildRightPanel(
    Color panelColor,
    Color chipBg,
    Color textColor,
    Color mutedColor,
    Color accent,
    bool isDark,
  ) {
    final results = _filteredCatalog;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Exercises',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
          ),
          const SizedBox(height: 12),
          _buildSearchField(
            hint: 'Search by equipment',
            icon: Icons.fitness_center,
            chipBg: chipBg,
            textColor: textColor,
            mutedColor: mutedColor,
            onChanged: (v) => setState(() => _equipmentQuery = v),
          ),
          const SizedBox(height: 8),
          _buildSearchField(
            hint: 'Search by body part',
            icon: Icons.accessibility_new_rounded,
            chipBg: chipBg,
            textColor: textColor,
            mutedColor: mutedColor,
            onChanged: (v) => setState(() => _bodyPartQuery = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._equipmentOptions.map(
                (e) => _FilterChip(
                  label: e,
                  selected: _equipmentFilters.contains(e),
                  accent: accent,
                  chipBg: chipBg,
                  mutedColor: mutedColor,
                  onTap: () => setState(() {
                    if (_equipmentFilters.contains(e)) {
                      _equipmentFilters.remove(e);
                    } else {
                      _equipmentFilters.add(e);
                    }
                  }),
                ),
              ),
              ..._bodyPartOptions.map(
                (b) => _FilterChip(
                  label: b,
                  selected: _bodyPartFilters.contains(b),
                  accent: accent,
                  chipBg: chipBg,
                  mutedColor: mutedColor,
                  onTap: () => setState(() {
                    if (_bodyPartFilters.contains(b)) {
                      _bodyPartFilters.remove(b);
                    } else {
                      _bodyPartFilters.add(b);
                    }
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      'No exercises match',
                      style: TextStyle(fontSize: 13, color: mutedColor),
                    ),
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _CatalogExerciseRow(
                      exercise: results[index],
                      cardColor: chipBg,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      accent: accent,
                      onAdd: () => _addFromCatalog(results[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required String hint,
    required IconData icon,
    required Color chipBg,
    required Color textColor,
    required Color mutedColor,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: mutedColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: mutedColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder catalog data — no backend, invented for the Add Exercises panel
// ---------------------------------------------------------------------------

class _CatalogExercise {
  final String id;
  final String name;
  final String equipment;
  final String bodyPart;

  const _CatalogExercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.bodyPart,
  });
}

const List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _equipmentOptions = ['Barbell', 'Dumbbell', 'Bodyweight', 'Machine', 'Cable'];
const List<String> _bodyPartOptions = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

const List<_CatalogExercise> _exerciseCatalog = [
  _CatalogExercise(id: 'cat_bench_press', name: 'Bench Press', equipment: 'Barbell', bodyPart: 'Chest'),
  _CatalogExercise(id: 'cat_incline_db_press', name: 'Incline Dumbbell Press', equipment: 'Dumbbell', bodyPart: 'Chest'),
  _CatalogExercise(id: 'cat_pushup', name: 'Push-up', equipment: 'Bodyweight', bodyPart: 'Chest'),
  _CatalogExercise(id: 'cat_cable_fly', name: 'Cable Fly', equipment: 'Cable', bodyPart: 'Chest'),
  _CatalogExercise(id: 'cat_deadlift', name: 'Deadlift', equipment: 'Barbell', bodyPart: 'Back'),
  _CatalogExercise(id: 'cat_lat_pulldown', name: 'Lat Pulldown', equipment: 'Machine', bodyPart: 'Back'),
  _CatalogExercise(id: 'cat_bent_row', name: 'Bent-Over Row', equipment: 'Barbell', bodyPart: 'Back'),
  _CatalogExercise(id: 'cat_pullup', name: 'Pull-up', equipment: 'Bodyweight', bodyPart: 'Back'),
  _CatalogExercise(id: 'cat_squat', name: 'Back Squat', equipment: 'Barbell', bodyPart: 'Legs'),
  _CatalogExercise(id: 'cat_leg_press', name: 'Leg Press', equipment: 'Machine', bodyPart: 'Legs'),
  _CatalogExercise(id: 'cat_lunge', name: 'Dumbbell Lunge', equipment: 'Dumbbell', bodyPart: 'Legs'),
  _CatalogExercise(id: 'cat_bw_squat', name: 'Bodyweight Squat', equipment: 'Bodyweight', bodyPart: 'Legs'),
  _CatalogExercise(id: 'cat_shoulder_press', name: 'Shoulder Press', equipment: 'Dumbbell', bodyPart: 'Shoulders'),
  _CatalogExercise(id: 'cat_lateral_raise', name: 'Lateral Raise', equipment: 'Dumbbell', bodyPart: 'Shoulders'),
  _CatalogExercise(id: 'cat_face_pull', name: 'Face Pull', equipment: 'Cable', bodyPart: 'Shoulders'),
  _CatalogExercise(id: 'cat_bicep_curl', name: 'Bicep Curl', equipment: 'Dumbbell', bodyPart: 'Arms'),
  _CatalogExercise(id: 'cat_tricep_pushdown', name: 'Tricep Pushdown', equipment: 'Cable', bodyPart: 'Arms'),
  _CatalogExercise(id: 'cat_dips', name: 'Dips', equipment: 'Bodyweight', bodyPart: 'Arms'),
  _CatalogExercise(id: 'cat_plank', name: 'Plank', equipment: 'Bodyweight', bodyPart: 'Core'),
  _CatalogExercise(id: 'cat_cable_crunch', name: 'Cable Crunch', equipment: 'Cable', bodyPart: 'Core'),
];

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _MuscleTag extends StatelessWidget {
  final String label;
  final Color accent;

  const _MuscleTag({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final Color chipBg;
  final Color mutedColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.chipBg,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? accent : mutedColor,
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final Color textColor;
  final Color mutedColor;
  final Color chipBg;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.textColor,
    required this.mutedColor,
    required this.chipBg,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(Icons.remove, () => onChanged(-1)),
          SizedBox(
            width: 22,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
          _stepButton(Icons.add, () => onChanged(1)),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: mutedColor),
      ),
    );
  }
}

class _CatalogExerciseRow extends StatelessWidget {
  final _CatalogExercise exercise;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color accent;
  final VoidCallback onAdd;

  const _CatalogExerciseRow({
    required this.exercise,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.accent,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.fitness_center, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.equipment} · ${exercise.bodyPart}',
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFF8A00),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color accent;
  final bool isDark;
  final VoidCallback onInfo;

  const _AiExerciseRow({
    super.key,
    required this.exercise,
    required this.index,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.accent,
    required this.isDark,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.drag_handle, color: mutedColor, size: 20),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.fitness_center, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise.sets} × ${exercise.reps}',
                    style: TextStyle(fontSize: 12.5, color: mutedColor),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onInfo,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              icon: Icon(Icons.info_outline, size: 18, color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color accent;
  final bool isDark;
  final VoidCallback onInfo;
  final VoidCallback onDelete;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;

  const _CustomExerciseRow({
    super.key,
    required this.exercise,
    required this.index,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.accent,
    required this.isDark,
    required this.onInfo,
    required this.onDelete,
    required this.onSetsChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = isDark ? Colors.white10 : const Color(0xFFF0F0F0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.drag_handle, color: mutedColor, size: 20),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fitness_center, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exercise.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                  ),
                ),
                IconButton(
                  onPressed: onInfo,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: Icon(Icons.info_outline, size: 18, color: mutedColor),
                ),
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE53935)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Sets', style: TextStyle(fontSize: 11, color: mutedColor)),
                const SizedBox(width: 6),
                _Stepper(
                  value: exercise.sets,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  chipBg: chipBg,
                  onChanged: onSetsChanged,
                ),
                const SizedBox(width: 18),
                Text('Reps', style: TextStyle(fontSize: 11, color: mutedColor)),
                const SizedBox(width: 6),
                _Stepper(
                  value: exercise.reps,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  chipBg: chipBg,
                  onChanged: onRepsChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
