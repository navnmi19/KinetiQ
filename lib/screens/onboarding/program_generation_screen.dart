import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_app/widgets/background_decoration.dart';
import 'package:lottie/lottie.dart';
import 'package:gym_app/screens/home/dashboard_screen.dart';

class ProgramGenerationScreen extends StatefulWidget {
  const ProgramGenerationScreen({super.key});

  @override
  State<ProgramGenerationScreen> createState() =>
      _ProgramGenerationScreenState();
}

class _ProgramGenerationScreenState extends State<ProgramGenerationScreen>
    with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color bgGradientTop = Color(0xFFD1FAE5);

  final List<String> _loadingMessages = const [
    'Analyzing your goals...',
    'Checking available equipment...',
    'Adjusting for injuries...',
    'Optimizing recovery balance...',
    'Building your weekly schedule...',
    'Finalizing your personalized program...',
  ];

  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  late final AnimationController _progressController;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  Timer? _messageTimer;
  int _currentMessageIndex = 0;

  bool _loadingComplete = false;
  bool _showWelcomeSequence = false;

  String _firstLineText = '';
  String _secondLineText = '';
  bool _firstLineDone = false;
  

  static const String _firstLineFull = 'Welcome to Workout.';
  static const String _secondLineFull = 'Your journey starts today.';

  Timer? _typewriterTimer;
  Timer? _navigationTimer;

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

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _progressController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startMessageRotation();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onLoadingComplete();
      }
    });
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_currentMessageIndex < _loadingMessages.length - 1) {
        setState(() {
          _currentMessageIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onLoadingComplete() {
    if (!mounted) return;
    setState(() {
      _loadingComplete = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _showWelcomeSequence = true;
      });
      _typeFirstLine();
    });
  }

  void _typeFirstLine() {
    int index = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (index < _firstLineFull.length) {
        setState(() {
          _firstLineText = _firstLineFull.substring(0, index + 1);
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          _firstLineDone = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _typeSecondLine();
        });
      }
    });
  }

  void _typeSecondLine() {
    int index = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (index < _secondLineFull.length) {
        setState(() {
          _secondLineText = _secondLineFull.substring(0, index + 1);
        });
        index++;
      } else {
        timer.cancel();
        _scheduleNavigation();
      }
    });
  }

  void _scheduleNavigation() {
  _navigationTimer = Timer(
    const Duration(seconds: 2),
    () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
        (route) => false,
      );
    },
  );
}
  @override
  void dispose() {
    _headerController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    _messageTimer?.cancel();
    _typewriterTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientTop, Colors.white],
          ),
        ),
        child: Stack(children: [const BackgroundDecorations(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const Spacer(),
                _buildAnimationContainer(),
                const SizedBox(height: 40),
                _buildContentSwitcher(),
                const Spacer(),
                _buildProgressBar(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),],)
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
          children: [
            const Text(
              'Building Your Plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our AI coach is creating your personalized program.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationContainer() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(_glowAnimation.value),
                blurRadius: 50,
                spreadRadius: 12,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Lottie.asset(
            'assets/animations/pushup.lottie',
            repeat: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSwitcher() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showWelcomeSequence
          ? _buildWelcomeSequence()
          : _buildLoadingMessage(),
    );
  }

  Widget _buildLoadingMessage() {
    return SizedBox(
      key: const ValueKey('loading'),
      height: 60,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text(
          _loadingMessages[_currentMessageIndex],
          key: ValueKey<int>(_currentMessageIndex),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSequence() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _firstLineText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _firstLineDone ? 1.0 : 0.0,
          child: Text(
            _secondLineText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _loadingComplete ? 0.0 : 1.0,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 8,
                  backgroundColor: primaryGreen.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final percent = (_progressController.value * 100).round();
              return Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}