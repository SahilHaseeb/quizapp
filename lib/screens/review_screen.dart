import 'package:flutter/material.dart';
import '../models/subject.dart';

class ReviewScreen extends StatelessWidget {
  final Subject subject;
  final Map<int, int> selectedAnswers;

  const ReviewScreen({
    super.key,
    required this.subject,
    required this.selectedAnswers,
  });

  String get _titleText {
    final level = subject.selectedDifficulty;
    if (level != null) {
      final levelName =
          level.name[0].toUpperCase() + level.name.substring(1);
      return '${subject.title} - $levelName';
    }
    return subject.title;
  }

  @override
  Widget build(BuildContext context) {
    final questions = subject.questions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Header Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: subject.effectiveGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: subject.themeColor.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Answer Review',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _titleText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
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

            const SizedBox(height: 16),

            // Question Cards List
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final userChoice = selectedAnswers[index];
                      final correctIndex = question.correctAnswerIndex;
                      final isCorrect = userChoice == correctIndex;
                      final isSkipped = userChoice == null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                            // Question Badge Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: subject.themeColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Q${index + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: subject.themeColor,
                                    ),
                                  ),
                                ),
                                if (isCorrect)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: Color(0xFF16A34A),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Correct',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (isSkipped)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.help_outline_rounded,
                                          size: 14,
                                          color: Color(0xFFD97706),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Skipped',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD97706),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.cancel_rounded,
                                          size: 14,
                                          color: Color(0xFFDC2626),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Incorrect',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Question Text
                            Text(
                              question.questionText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Options List
                            ...List.generate(
                              question.options.length,
                              (optIdx) {
                                final label =
                                    String.fromCharCode(65 + optIdx);
                                final isThisCorrect = optIdx == correctIndex;
                                final isThisUserChoice = userChoice == optIdx;

                                Color optionBg = const Color(0xFFF8FAFC);
                                Color borderColor = const Color(0xFFE2E8F0);
                                IconData? statusIcon;
                                Color iconColor = Colors.transparent;

                                if (isThisCorrect) {
                                  optionBg = const Color(0xFFF0FDF4);
                                  borderColor = const Color(0xFF86EFAC);
                                  statusIcon = Icons.check_circle_rounded;
                                  iconColor = const Color(0xFF16A34A);
                                } else if (isThisUserChoice && !isCorrect) {
                                  optionBg = const Color(0xFFFEF2F2);
                                  borderColor = const Color(0xFFFCA5A5);
                                  statusIcon = Icons.cancel_rounded;
                                  iconColor = const Color(0xFFDC2626);
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: optionBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: isThisCorrect
                                              ? const Color(0xFF16A34A)
                                              : (isThisUserChoice
                                                  ? const Color(0xFFDC2626)
                                                  : const Color(0xFFCBD5E1)),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          question.options[optIdx],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isThisCorrect ||
                                                    isThisUserChoice
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isThisCorrect
                                                ? const Color(0xFF15803D)
                                                : (isThisUserChoice
                                                    ? const Color(0xFFB91C1C)
                                                    : const Color(0xFF334155)),
                                          ),
                                        ),
                                      ),
                                      if (statusIcon != null)
                                        Icon(
                                          statusIcon,
                                          color: iconColor,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Explanation Box
                            if (question.explanation.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF475569),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Explanation: ',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                            TextSpan(
                                              text: question.explanation,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
