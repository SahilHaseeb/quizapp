import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/quiz_data.dart';
import '../models/subject.dart';
import '../services/quiz_generator.dart';
import '../services/quiz_parser.dart';
import '../services/quiz_storage.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../widgets/study_background.dart';
import '../widgets/subject_card.dart';
import 'difficulty_screen.dart';
import 'quiz_screen.dart';
import 'upload_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  List<Subject> _customQuizzes = [];
  bool _isLoadingCustom = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
    _loadCustomQuizzes();
  }

  Future<void> _loadCustomQuizzes() async {
    setState(() => _isLoadingCustom = true);
    final list = await QuizStorage.loadCustomQuizzes();
    if (mounted) {
      setState(() {
        _customQuizzes = list;
        _isLoadingCustom = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onSubjectCardTap(BuildContext context, Subject subject) {
    if (subject.isCustom) {
      _startQuiz(context, subject);
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DifficultyScreen(subject: subject),
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

  Future<void> _startQuiz(BuildContext context, Subject subject) async {
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

    final sessionSubject = await QuizGenerator.generateQuizSession(subject);

    if (context.mounted) {
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

  Future<void> _handleFileUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileName = file.name;
      final lowerName = fileName.toLowerCase();

      if (lowerName.endsWith('.doc')) {
        if (!mounted) return;
        _showAlertDialog(
          title: 'Unsupported Format',
          message:
              'Old .doc files are not supported. Please save or convert the file to .docx and try again.',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.amber.shade900,
        );
        return;
      }

      if (!lowerName.endsWith('.pdf') && !lowerName.endsWith('.docx')) {
        if (!mounted) return;
        _showAlertDialog(
          title: 'Unsupported File Type',
          message: 'Only PDF and Word (.docx) files are supported.',
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
        );
        return;
      }

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        _showAlertDialog(
          title: 'File Read Error',
          message: 'Could not read file data. Please try another file.',
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
        );
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text('Extracting and parsing quiz questions...'),
              ),
            ],
          ),
        ),
      );

      ParseResult parseResult;
      try {
        final extractedText = QuizParser.extractText(
          bytes: bytes,
          fileName: fileName,
        );

        final defaultTitle = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;

        parseResult = QuizParser.parseText(
          rawText: extractedText,
          defaultTitle: defaultTitle,
        );
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (!mounted) return;
        _showAlertDialog(
          title: 'Parsing Failed',
          message: e is FormatException ? e.message : e.toString(),
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
        );
        return;
      }

      if (mounted) Navigator.pop(context);

      if (parseResult.validQuestions.isEmpty) {
        if (!mounted) return;
        _showFormatHelpDialog();
        return;
      }

      if (!mounted) return;
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadPreviewScreen(parseResult: parseResult),
        ),
      );

      if (saved == true) {
        await _loadCustomQuizzes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Quiz uploaded and saved successfully!'),
                ],
              ),
              backgroundColor: context.quizTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showAlertDialog(
        title: 'Upload Error',
        message: 'An unexpected error occurred: ${e.toString()}',
        icon: Icons.error_outline_rounded,
        iconColor: Colors.red,
      );
    }
  }

  void _showAlertDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 15, color: context.quizTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFormatHelpDialog() {
    final quizTheme = context.quizTheme;
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            const Text('No Questions Found'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not parse any valid MCQs from the document. Please ensure your document follows this structure:',
                style: TextStyle(fontSize: 14, color: quizTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2035) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: quizTheme.cardBorder),
                ),
                child: Text(
                  'Subject: Computer Architecture\n\n'
                  'Q1. What does CPU stand for?\n'
                  'A) Central Processing Unit\n'
                  'B) Control Performance Unit\n'
                  'C) Computer Unit\n'
                  'D) Central Power Unit\n'
                  'Answer: A\n'
                  'Explanation: CPU is the main processor.\n\n'
                  'Q2. ...',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: quizTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomQuiz(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: context.quizTheme.errorColor),
            const SizedBox(width: 10),
            const Text('Delete Quiz?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${subject.title}"? This cannot be undone.',
          style: TextStyle(fontSize: 15, color: context.quizTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.quizTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await QuizStorage.deleteCustomQuiz(subject.id);
      await _loadCustomQuizzes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${subject.title}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultSubjects = QuizData.subjects;
    final quizTheme = context.quizTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StudyBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Gradient Section
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
                      colors: quizTheme.headerGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppTokens.radiusHeader),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: quizTheme.headerGradient.first.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Welcome back, Student 👋',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'My Quiz App',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose a subject or upload your own custom quiz',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Content Area
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Upload Quiz Card
                          InkWell(
                            onTap: _handleFileUpload,
                            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppTokens.mobileGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTokens.mobileGradient.first
                                        .withValues(alpha: 0.3),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.upload_file_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Upload Custom Quiz',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Import MCQs from PDF or Word (.docx)',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white
                                                .withValues(alpha: 0.88),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                                    ),
                                    child: const Text(
                                      'Upload',
                                      style: TextStyle(
                                        color: AppTokens.primaryIndigoLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Stats Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _StatChip(
                                  icon: Icons.category_rounded,
                                  label: '${defaultSubjects.length} Default',
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 10),
                                _StatChip(
                                  icon: Icons.folder_special_rounded,
                                  label: '${_customQuizzes.length} Custom',
                                  color: const Color(0xFF7C3AED),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Default Subjects Section
                          Text(
                            'Default Subjects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: quizTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 16),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              int crossAxisCount;
                              double childAspectRatio;

                              if (width < 600) {
                                crossAxisCount = 1;
                                childAspectRatio = 2.3;
                              } else if (width <= 1000) {
                                crossAxisCount = 2;
                                childAspectRatio = 1.45;
                              } else {
                                crossAxisCount = 3;
                                childAspectRatio = 1.35;
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: defaultSubjects.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  childAspectRatio: childAspectRatio,
                                ),
                                itemBuilder: (context, index) {
                                  final subject = defaultSubjects[index];

                                  final start = (index * 0.08).clamp(0.0, 0.6);
                                  final end = (start + 0.4).clamp(0.0, 1.0);

                                  final animation = CurvedAnimation(
                                    parent: _animController,
                                    curve: Interval(start, end,
                                        curve: Curves.easeOutCubic),
                                  );

                                  final slideAnim = Tween<Offset>(
                                    begin: const Offset(0, 0.15),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return SlideTransition(
                                    position: slideAnim,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: SubjectCard(
                                        subject: subject,
                                        onTap: () =>
                                            _onSubjectCardTap(context, subject),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // My Uploaded Quizzes Section
                          Row(
                            children: [
                              Text(
                                'My Uploaded Quizzes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: quizTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_customQuizzes.length}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          if (_isLoadingCustom)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_customQuizzes.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: quizTheme.cardBackground,
                                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                                border: Border.all(
                                  color: quizTheme.cardBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.folder_open_rounded,
                                    size: 40,
                                    color: quizTheme.textMuted,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No custom quizzes uploaded yet.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: quizTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap "Upload Custom Quiz" above to import MCQs from a PDF or Word document!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: quizTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                int crossAxisCount;
                                double childAspectRatio;

                                if (width < 600) {
                                  crossAxisCount = 1;
                                  childAspectRatio = 2.2;
                                } else if (width <= 1000) {
                                  crossAxisCount = 2;
                                  childAspectRatio = 1.45;
                                } else {
                                  crossAxisCount = 3;
                                  childAspectRatio = 1.35;
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _customQuizzes.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                    childAspectRatio: childAspectRatio,
                                  ),
                                  itemBuilder: (context, index) {
                                    final subject = _customQuizzes[index];
                                    return Stack(
                                      children: [
                                        SubjectCard(
                                          subject: subject,
                                          onTap: () =>
                                              _onSubjectCardTap(context, subject),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Material(
                                            color: Colors.black
                                                .withValues(alpha: 0.3),
                                            shape: const CircleBorder(),
                                            child: InkWell(
                                              customBorder:
                                                  const CircleBorder(),
                                              onTap: () =>
                                                  _deleteCustomQuiz(subject),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                          const SizedBox(height: 40),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
