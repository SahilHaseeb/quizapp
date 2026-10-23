import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../services/quiz_generator.dart';
import 'difficulty_screen.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  final Subject subject;
  final Map<int, int> selectedAnswers;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final int answeredCount;
  final int skippedCount;

  const ResultScreen({
    super.key,
    required this.subject,
    required this.selectedAnswers,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    this.answeredCount = 0,
    this.skippedCount = 0,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _updateBestScore();
  }

  Future<void> _updateBestScore() async {
    final difficulty = widget.subject.selectedDifficulty;
    if (difficulty == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'best_score_${widget.subject.id}_${difficulty.name}';
    final currentPercentage =
        ((widget.correctCount / widget.totalQuestions) * 100).toInt();

    final existingBest = prefs.getInt(key) ?? 0;
    if (currentPercentage > existingBest) {
      await prefs.setInt(key, currentPercentage);
    }
  }

  double get percentage => (widget.correctCount / widget.totalQuestions) * 100;

  String get resultMessage {
    if (percentage >= 90) {
      return 'Outstanding! 🏆';
    } else if (percentage >= 70) {
      return 'Great job! 🎉';
    } else if (percentage >= 50) {
      return 'Good effort 👍 Keep practicing';
    } else {
      return 'Don\'t give up 💪 Try again';
    }
  }

  Color get scoreColor {
    if (percentage >= 90) return const Color(0xFF059669); // Emerald
    if (percentage >= 70) return const Color(0xFF2563EB); // Blue
    if (percentage >= 50) return const Color(0xFFD97706); // Amber
    return const Color(0xFFDC2626); // Red
  }

  bool get _shouldSuggestNextLevel {
    final level = widget.subject.selectedDifficulty;
    if (level == null) return false;
    return percentage >= 80 &&
        (level == Difficulty.easy || level == Difficulty.medium);
  }

  String get _titleText {
    final level = widget.subject.selectedDifficulty;
    if (level != null) {
      final levelName =
          level.name[0].toUpperCase() + level.name.substring(1);
      return '${widget.subject.title} - $levelName';
    }
    return widget.subject.title;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 28,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.subject.effectiveGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.subject.themeColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        children: [
                          const Text(
                            'Quiz Completed!',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.subject.icon,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _titleText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Main Score Card & Stats
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          // Card Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Animated Circular Progress Indicator
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: percentage),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: CircularProgressIndicator(
                                              value: value / 100,
                                              strokeWidth: 14,
                                              backgroundColor:
                                                  const Color(0xFFF1F5F9),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                scoreColor,
                                              ),
                                              strokeCap: StrokeCap.round,
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${value.toInt()}%',
                                                style: TextStyle(
                                                  fontSize: 38,
                                                  fontWeight: FontWeight.bold,
                                                  color: scoreColor,
                                                  height: 1.1,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                'SCORE',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF64748B),
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Suggestion Pill if score >= 80% on Easy/Medium
                                if (_shouldSuggestNextLevel) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFA7F3D0),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.workspace_premium_rounded,
                                          size: 16,
                                          color: Color(0xFF059669),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Great! Try the next level 🚀',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF065F46),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Answered & Skipped Pills
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.touch_app_rounded,
                                            size: 16,
                                            color: Color(0xFF059669),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Answered: ${widget.answeredCount}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF065F46),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFCA5A5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.timer_off_rounded,
                                            size: 16,
                                            color: Color(0xFFDC2626),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Skipped (time up): ${widget.skippedCount}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF991B1B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Result Message
                                Text(
                                  resultMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),

                                const SizedBox(height: 24),
                                const Divider(color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 20),

                                // 3 Stat Cards Row
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth < 340) {
                                      return Column(
                                        children: [
                                          _StatBox(
                                            label: 'Total',
                                            value: '${widget.totalQuestions}',
                                            icon: Icons
                                                .format_list_numbered_rounded,
                                            color: const Color(0xFF4F46E5),
                                          ),
                                          const SizedBox(height: 10),
                                          _StatBox(
                                            label: 'Correct',
                                            value: '${widget.correctCount}',
                                            icon: Icons.check_circle_rounded,
                                            color: const Color(0xFF10B981),
                                          ),
                                          const SizedBox(height: 10),
                                          _StatBox(
                                            label: 'Wrong',
                                            value: '${widget.wrongCount}',
                                            icon: Icons.cancel_rounded,
                                            color: const Color(0xFFEF4444),
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _StatBox(
                                            label: 'Total',
                                            value: '${widget.totalQuestions}',
                                            icon: Icons
                                                .format_list_numbered_rounded,
                                            color: const Color(0xFF4F46E5),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _StatBox(
                                            label: 'Correct',
                                            value: '${widget.correctCount}',
                                            icon: Icons.check_circle_rounded,
                                            color: const Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _StatBox(
                                            label: 'Wrong',
                                            value: '${widget.wrongCount}',
                                            icon: Icons.cancel_rounded,
                                            color: const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Stacked Buttons Area (Max Width 500)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Review Answers Button
                                Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3730A3),
                                        Color(0xFF4F46E5),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4F46E5)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReviewScreen(
                                              subject: widget.subject,
                                              selectedAnswers:
                                                  widget.selectedAnswers,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      splashColor:
                                          Colors.white.withValues(alpha: 0.2),
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.rate_review_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Review Answers',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Retry Quiz Button (same difficulty level)
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => const AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: Text(
                                                    'Generating new quiz set...'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );

                                      final newSessionSubject =
                                          await QuizGenerator
                                              .generateQuizSession(
                                        widget.subject,
                                        difficulty:
                                            widget.subject.selectedDifficulty,
                                      );

                                      if (context.mounted) {
                                        Navigator.pop(context); // close loading
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QuizScreen(
                                                subject: newSessionSubject),
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      Icons.replay_rounded,
                                      size: 20,
                                      color: widget.subject.themeColor,
                                    ),
                                    label: Text(
                                      'Retry Quiz',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: widget.subject.themeColor,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: widget.subject.themeColor,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Try Another Level Button (if not custom)
                                if (!widget.subject.isCustom) ...[
                                  SizedBox(
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DifficultyScreen(
                                              subject: widget.subject,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.speed_rounded,
                                        size: 20,
                                        color: Color(0xFF7C3AED),
                                      ),
                                      label: const Text(
                                        'Try Another Level',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF7C3AED),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Back to Home Button
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                  },
                                  icon: const Icon(
                                    Icons.home_rounded,
                                    size: 20,
                                    color: Color(0xFF64748B),
                                  ),
                                  label: const Text(
                                    'Back to Home',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
