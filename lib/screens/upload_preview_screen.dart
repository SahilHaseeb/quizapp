import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/quiz_parser.dart';
import '../services/quiz_storage.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

class UploadPreviewScreen extends StatefulWidget {
  final ParseResult parseResult;

  const UploadPreviewScreen({
    super.key,
    required this.parseResult,
  });

  @override
  State<UploadPreviewScreen> createState() => _UploadPreviewScreenState();
}

class _UploadPreviewScreenState extends State<UploadPreviewScreen> {
  late TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.parseResult.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a quiz title.'),
          backgroundColor: context.quizTheme.warningColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final String customId =
        'custom_${DateTime.now().millisecondsSinceEpoch}';
    final Subject customSubject = Subject(
      id: customId,
      title: title,
      subtitle: '${widget.parseResult.validQuestions.length} Questions',
      icon: Icons.upload_file_rounded,
      themeColor: AppTokens.primaryIndigoLight,
      gradientColors: AppTokens.mobileGradient,
      questions: widget.parseResult.validQuestions,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    final success = await QuizStorage.saveCustomQuiz(customSubject);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true); // Return true to indicate quiz saved
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save quiz to local storage.'),
            backgroundColor: context.quizTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = context.quizTheme;
    final validQuestions = widget.parseResult.validQuestions;
    final errors = widget.parseResult.errors;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTokens.mobileGradient.first,
        foregroundColor: Colors.white,
        title: const Text(
          'Quiz Preview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Input Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: quizTheme.cardBackground,
                            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                            border: Border.all(color: quizTheme.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz Title',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: quizTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _titleController,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: quizTheme.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Enter quiz title...',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats Card (Found vs Skipped)
                        Row(
                          children: [
                            Expanded(
                              child: _StatPill(
                                label: 'Valid Questions',
                                value: '${validQuestions.length}',
                                icon: Icons.check_circle_rounded,
                                color: quizTheme.successColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatPill(
                                label: 'Skipped / Errors',
                                value: '${errors.length}',
                                icon: errors.isEmpty
                                    ? Icons.check_circle_outline
                                    : Icons.warning_amber_rounded,
                                color: errors.isEmpty
                                    ? quizTheme.textSecondary
                                    : quizTheme.errorColor,
                              ),
                            ),
                          ],
                        ),

                        // Errors Expandable Box if any errors
                        if (errors.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: quizTheme.errorBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: quizTheme.errorColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                iconColor: quizTheme.errorColor,
                                collapsedIconColor: quizTheme.errorColor,
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: quizTheme.errorColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${errors.length} Question(s) Skipped (Click to view)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: quizTheme.errorColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: errors.map((err) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            '• $err',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: quizTheme.errorColor,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        Text(
                          'Questions Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: quizTheme.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // List of Questions Preview
                        ...List.generate(validQuestions.length, (idx) {
                          final q = validQuestions[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: quizTheme.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: quizTheme.cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTokens.mobileGradient.first
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Q${idx + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTokens.mobileGradient.first,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  q.questionText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: quizTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...List.generate(q.options.length, (optIdx) {
                                  final letter =
                                      String.fromCharCode(65 + optIdx);
                                  final isCorrect =
                                      optIdx == q.correctAnswerIndex;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? quizTheme.successBackground
                                          : quizTheme.cardBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isCorrect
                                            ? quizTheme.successColor
                                            : quizTheme.cardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$letter) ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCorrect
                                                ? quizTheme.successColor
                                                : quizTheme.textSecondary,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            q.options[optIdx],
                                            style: TextStyle(
                                              color: isCorrect
                                                  ? quizTheme.successColor
                                                  : quizTheme.textPrimary,
                                              fontWeight: isCorrect
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (isCorrect)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: quizTheme.successColor,
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar (Save / Cancel)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: quizTheme.cardBackground,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(top: BorderSide(color: quizTheme.cardBorder)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: AppTokens.buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                            gradient: LinearGradient(
                              colors: AppTokens.mobileGradient,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                            child: InkWell(
                              onTap: _isSaving ? null : _saveQuiz,
                              borderRadius: BorderRadius.circular(AppTokens.radiusButton),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Save Quiz',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
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
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.quizTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
