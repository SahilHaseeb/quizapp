import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/subject.dart';
import '../services/quiz_generator.dart';
import '../theme/app_tokens.dart';
import '../widgets/study_background.dart';
import 'quiz_screen.dart';

class DifficultyScreen extends StatefulWidget {
  final Subject subject;

  const DifficultyScreen({
    super.key,
    required this.subject,
  });

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Map<Difficulty, int?> _bestScores = {};
  bool _isLoadingScores = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
    _loadBestScores();
  }

  Future<void> _loadBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    for (final level in Difficulty.values) {
      final key = 'best_score_${widget.subject.id}_${level.name}';
      final score = prefs.getInt(key);
      _bestScores[level] = score;
    }
    if (mounted) {
      setState(() {
        _isLoadingScores = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startQuizForLevel(Difficulty level) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Generating randomized quiz...')),
          ],
        ),
      ),
    );

    final sessionSubject = await QuizGenerator.generateQuizSession(
      widget.subject,
      difficulty: level,
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuizScreen(subject: sessionSubject),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.06);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeIn));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StudyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Banner Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.subject.effectiveGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.subject.themeColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          widget.subject.icon,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subject.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Choose your difficulty',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.80),
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

              const SizedBox(height: 20),

              // Main Difficulty Cards Column (Centered, Max Width 640)
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DifficultyCard(
                            title: 'Easy',
                            subtitle: 'Basic concepts and definitions',
                            icon: Icons.sentiment_satisfied_alt_rounded,
                            gradientColors: AppTokens.easyGradient,
                            bestScore: _isLoadingScores
                                ? null
                                : _bestScores[Difficulty.easy],
                            onTap: () =>
                                _startQuizForLevel(Difficulty.easy),
                            animationIndex: 0,
                            controller: _animController,
                          ),
                          const SizedBox(height: 14),
                          _DifficultyCard(
                            title: 'Medium',
                            subtitle: 'Application and understanding',
                            icon: Icons.speed_rounded,
                            gradientColors: AppTokens.mediumGradient,
                            bestScore: _isLoadingScores
                                ? null
                                : _bestScores[Difficulty.medium],
                            onTap: () =>
                                _startQuizForLevel(Difficulty.medium),
                            animationIndex: 1,
                            controller: _animController,
                          ),
                          const SizedBox(height: 14),
                          _DifficultyCard(
                            title: 'Hard',
                            subtitle: 'Tricky and analytical questions',
                            icon: Icons.local_fire_department_rounded,
                            gradientColors: AppTokens.hardGradient,
                            bestScore: _isLoadingScores
                                ? null
                                : _bestScores[Difficulty.hard],
                            onTap: () =>
                                _startQuizForLevel(Difficulty.hard),
                            animationIndex: 2,
                            controller: _animController,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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

class _DifficultyCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final int? bestScore;
  final VoidCallback onTap;
  final int animationIndex;
  final AnimationController controller;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.bestScore,
    required this.onTap,
    required this.animationIndex,
    required this.controller,
  });

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final start = (widget.animationIndex * 0.15).clamp(0.0, 0.6);
    final end = (start + 0.45).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(animation);

    final double scale = _isPressed
        ? 0.98
        : (_isHovered
            ? 1.01
            : 1.0);

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: animation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: Listener(
            onPointerDown: (_) => setState(() => _isPressed = true),
            onPointerUp: (_) => setState(() => _isPressed = false),
            onPointerCancel: (_) => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: isDark
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1,
                        )
                      : null,
                  boxShadow: isDark
                      ? const []
                      : [
                          BoxShadow(
                            color: widget.gradientColors.first
                                .withValues(alpha: _isHovered ? 0.22 : 0.15),
                            blurRadius: _isHovered ? 22 : 20,
                            offset: _isHovered
                                ? const Offset(0, 10)
                                : const Offset(0, 8),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(18),
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 40x40 Icon Container
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.subtitle,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withValues(alpha: 0.85),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withValues(alpha: 0.70),
                                size: 20,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.12),
                            height: 1,
                          ),
                          const SizedBox(height: 12),

                          // Chips Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Timer Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '${QuizScreen.questionTimeSeconds} sec per question',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Best Score Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.bestScore != null
                                      ? 'Best: ${widget.bestScore}%'
                                      : 'Best: --',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
