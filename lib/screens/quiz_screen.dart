import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;

  const QuizScreen({
    super.key,
    required this.subject,
  });

  static const int questionTimeSeconds = 10;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex

  Timer? _questionTimer;
  Timer? _autoAdvanceTimer;
  DateTime? _questionEndTime;

  int _remainingSeconds = QuizScreen.questionTimeSeconds;
  double _remainingFraction = 1.0;

  int _answeredCount = 0;
  int _skippedCount = 0;

  bool _isSubmitting = false;
  bool _isAdvancing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionEndTime = DateTime.now().add(
      const Duration(seconds: QuizScreen.questionTimeSeconds),
    );
    _remainingSeconds = QuizScreen.questionTimeSeconds;
    _remainingFraction = 1.0;

    _questionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      if (_isAdvancing || _isSubmitting) return;

      final diffMs =
          _questionEndTime!.difference(DateTime.now()).inMilliseconds;
      final remainingSecs =
          (diffMs / 1000).ceil().clamp(0, QuizScreen.questionTimeSeconds);
      final fraction =
          (diffMs / (QuizScreen.questionTimeSeconds * 1000)).clamp(0.0, 1.0);

      setState(() {
        _remainingSeconds = remainingSecs;
        _remainingFraction = fraction;
      });

      if (_remainingSeconds <= 3 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (_remainingSeconds > 3 && _pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0;
      }

      if (diffMs <= 0) {
        _questionTimer?.cancel();
        _pulseController.stop();
        _handleQuestionTimeout();
      }
    });
  }

  void _handleQuestionTimeout() {
    if (_isAdvancing || _isSubmitting) return;

    setState(() {
      _isAdvancing = true;
      _skippedCount++;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.timer_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Time\'s up! Moving to next question...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: context.quizTheme.errorColor,
          duration: const Duration(milliseconds: 350),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
        ),
      );
    }

    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_isSubmitting) return;

      if (_currentQuestionIndex < widget.subject.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAdvancing = false;
        });
        _startQuestionTimer();
      } else {
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectOption(int optionIndex) {
    if (_isAdvancing || _isSubmitting) return;

    _questionTimer?.cancel();
    _pulseController.stop();

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionIndex;
      _isAdvancing = true;
      _answeredCount++;
    });

    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (_isSubmitting) return;

      if (_currentQuestionIndex < widget.subject.questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isAdvancing = false;
        });
        _startQuestionTimer();
      } else {
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _questionTimer?.cancel();
    _autoAdvanceTimer?.cancel();

    int correctCount = 0;
    final questions = widget.subject.questions;

    for (int i = 0; i < questions.length; i++) {
      final selectedOption = _selectedAnswers[i];
      if (selectedOption != null &&
          selectedOption == questions[i].correctAnswerIndex) {
        correctCount++;
      }
    }

    final totalQuestions = questions.length;
    final wrongCount = totalQuestions - correctCount;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            subject: widget.subject,
            selectedAnswers: _selectedAnswers,
            correctCount: correctCount,
            wrongCount: wrongCount,
            totalQuestions: totalQuestions,
            answeredCount: _answeredCount,
            skippedCount: _skippedCount,
          ),
        ),
      );
    }
  }

  Future<bool> _showExitDialog() async {
    _questionTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    final quizTheme = context.quizTheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        title: Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: quizTheme.errorColor),
            const SizedBox(width: 10),
            const Text(
              'Exit Quiz?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Your progress will be lost.',
          style: TextStyle(fontSize: 15, color: quizTheme.textSecondary),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: quizTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: quizTheme.errorColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Exit Quiz',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result != true && mounted) {
      setState(() {
        _isAdvancing = false;
      });
      _startQuestionTimer();
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = context.quizTheme;
    final questions = widget.subject.questions;
    final currentQuestion = questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final progress = (_currentQuestionIndex + 1) / questions.length;
    final selectedOptionIndex = _selectedAnswers[_currentQuestionIndex];

    Color ringColor;
    if (_remainingSeconds > 5) {
      ringColor = Colors.white;
    } else if (_remainingSeconds > 3) {
      ringColor = quizTheme.warningColor; // Orange/Amber
    } else {
      ringColor = quizTheme.errorColor; // Red
    }

    Widget timerRing = SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: _remainingFraction,
              strokeWidth: 4.5,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            ),
          ),
          Text(
            '$_remainingSeconds',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (_remainingSeconds <= 3) {
      timerRing = ScaleTransition(
        scale: _pulseAnimation,
        child: timerRing,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog();
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.subject.effectiveGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppTokens.radiusHeader),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.subject.themeColor.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Row(
                      children: [
                        // Exit Button
                        InkWell(
                          onTap: () async {
                            final shouldExit = await _showExitDialog();
                            if (shouldExit && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Exit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.subject.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        timerRing,
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Progress Section
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: widget.subject.themeColor,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                if (widget.subject.selectedDifficulty != null) ...[
                                  const SizedBox(width: 8),
                                  _DifficultyChip(
                                    difficulty:
                                        widget.subject.selectedDifficulty!,
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.subject.themeColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.subject.themeColor,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Animated Progress Bar
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    width: double.infinity,
                                    color: quizTheme.cardBorder,
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors:
                                              widget.subject.effectiveGradient,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // Step Dots
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(questions.length, (idx) {
                              final isDone = idx < _currentQuestionIndex;
                              final isCurrent = idx == _currentQuestionIndex;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isCurrent ? 14 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: (isDone || isCurrent)
                                        ? widget.subject.themeColor
                                        : quizTheme.cardBorder,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Main Quiz Content Container
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.06, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey<int>(_currentQuestionIndex),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Card
                            Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: quizTheme.cardBackground,
                                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                                border: Border.all(color: quizTheme.cardBorder),
                                boxShadow: AppTokens.cardShadowLight(
                                  widget.subject.themeColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.subject.themeColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Q${_currentQuestionIndex + 1}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: widget.subject.themeColor,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    currentQuestion.questionText,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: quizTheme.textPrimary,
                                      height: 1.45,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Answer Options
                            ...List.generate(
                              currentQuestion.options.length,
                              (index) {
                                final label =
                                    String.fromCharCode(65 + index);
                                return AnswerOption(
                                  optionLabel: label,
                                  optionText: currentQuestion.options[index],
                                  isSelected: selectedOptionIndex == index,
                                  isDimmed:
                                      _isAdvancing && selectedOptionIndex != index,
                                  onTap: () => _selectOption(index),
                                  themeColor: widget.subject.themeColor,
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Hint Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 14.0,
                ),
                decoration: BoxDecoration(
                  color: quizTheme.cardBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(top: BorderSide(color: quizTheme.cardBorder)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLastQuestion
                              ? Icons.check_circle_outline_rounded
                              : Icons.touch_app_rounded,
                          size: 18,
                          color: widget.subject.themeColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLastQuestion
                              ? 'Tap an option to submit'
                              : 'Tap an option to continue',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.subject.themeColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;

    switch (difficulty) {
      case Difficulty.easy:
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = 'Easy';
        break;
      case Difficulty.medium:
        bg = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        label = 'Medium';
        break;
      case Difficulty.hard:
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        label = 'Hard';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
