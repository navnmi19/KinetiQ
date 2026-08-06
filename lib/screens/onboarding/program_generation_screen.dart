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

  static const String _firstLineFull = 'Welcome to Workout.';
  static const String _secondLineFull = 'Your journey starts today.';

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildAnimationContainer(),
                  const SizedBox(height: 32),
                  _buildContentSwitcher(),
                  const SizedBox(height: 32),
                  _buildStepChecklist(),
                  const SizedBox(height: 32),
                ],
              ),
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
                color: primaryGreen.withValues(alpha: _glowAnimation.value),
                blurRadius: 50,
                spreadRadius: 12,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
        _StaggeredText(
          key: const ValueKey('welcome_line1'),
          text: _firstLineFull,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        _StaggeredText(
          key: const ValueKey('welcome_line2'),
          text: _secondLineFull,
          startDelay:
              _StaggeredText.estimateDuration(_firstLineFull) +
              const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
          onCompleted: _scheduleNavigation,
        ),
      ],
    );
  }

  Widget _buildStepChecklist() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _loadingComplete ? 0.0 : 1.0,
      child: Column(
        children: List.generate(_loadingMessages.length, (i) {
          final done = i < _currentMessageIndex;
          final active = i == _currentMessageIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? primaryGreen
                        : (active
                            ? primaryGreen.withValues(alpha: 0.15)
                            : Colors.grey.shade200),
                    border: active
                        ? Border.all(color: primaryGreen, width: 2)
                        : null,
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _loadingMessages[i].replaceAll('...', ''),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: done || active
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

}

/// Reveals [text] one character at a time, each letter fading in with a
/// slight upward drift. Cadence between letters roughly matches natural
/// typing speed (a touch faster) -- the difference from a plain typewriter
/// is that each letter eases in smoothly instead of popping in instantly.
class _StaggeredText extends StatefulWidget {
  static const int _staggerMs = 75;
  static const int _letterRevealMs = 200;

  final String text;
  final TextStyle style;
  final Duration startDelay;
  final VoidCallback? onCompleted;

  const _StaggeredText({
    super.key,
    required this.text,
    required this.style,
    this.startDelay = Duration.zero,
    this.onCompleted,
  });

  static Duration estimateDuration(String text) {
    return Duration(
      milliseconds: text.length * _staggerMs + _letterRevealMs,
    );
  }

  @override
  State<_StaggeredText> createState() => _StaggeredTextState();
}

class _StaggeredTextState extends State<_StaggeredText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _StaggeredText.estimateDuration(widget.text),
    );
    if (widget.onCompleted != null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onCompleted!();
      });
    }
    _startTimer = Timer(widget.startDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _controller.duration!.inMilliseconds;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(widget.text.length, (i) {
            final startFraction =
                (i * _StaggeredText._staggerMs) / totalMs;
            final endFraction =
                (i * _StaggeredText._staggerMs + _StaggeredText._letterRevealMs) /
                totalMs;
            final progress = CurvedAnimation(
              parent: _controller,
              curve: Interval(
                startFraction.clamp(0.0, 1.0),
                endFraction.clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ).value;

            return Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, (1 - progress) * 8),
                child: Text(widget.text[i], style: widget.style),
              ),
            );
          }),
        );
      },
    );
  }
}