import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/data/quiz_data.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/services/quiz_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Difficulty Quiz Bank Quality & Integrity Tests', () {
    test('Every default subject has 60 questions (20 Easy, 20 Medium, 20 Hard)', () {
      expect(QuizData.subjects.length, equals(6));

      for (final subject in QuizData.subjects) {
        final totalCount = subject.questions.length;
        expect(
          totalCount,
          equals(60),
          reason: 'Subject "${subject.title}" must have exactly 60 questions total.',
        );

        final easyCount = subject.questions
            .where((q) => q.difficulty == Difficulty.easy)
            .length;
        final mediumCount = subject.questions
            .where((q) => q.difficulty == Difficulty.medium)
            .length;
        final hardCount = subject.questions
            .where((q) => q.difficulty == Difficulty.hard)
            .length;

        expect(
          easyCount,
          equals(20),
          reason: 'Subject "${subject.title}" must have 20 Easy questions.',
        );
        expect(
          mediumCount,
          equals(20),
          reason: 'Subject "${subject.title}" must have 20 Medium questions.',
        );
        expect(
          hardCount,
          equals(20),
          reason: 'Subject "${subject.title}" must have 20 Hard questions.',
        );
      }
    });

    test('No duplicate question text within any subject', () {
      for (final subject in QuizData.subjects) {
        final textSet = <String>{};
        for (final q in subject.questions) {
          final text = q.questionText.trim().toLowerCase();
          expect(
            textSet.contains(text),
            isFalse,
            reason:
                'Duplicate question text found in "${subject.title}": "${q.questionText}"',
          );
          textSet.add(text);
        }
      }
    });

    test('Every question has exactly 4 distinct options and valid correct answer index', () {
      for (final subject in QuizData.subjects) {
        for (final q in subject.questions) {
          expect(
            q.options.length,
            equals(4),
            reason: 'Question "${q.id}" must have 4 options.',
          );
          final uniqueOptions = q.options.map((o) => o.trim().toLowerCase()).toSet();
          expect(
            uniqueOptions.length,
            equals(4),
            reason: 'Question "${q.id}" in "${subject.title}" has duplicate options: ${q.options}',
          );
          expect(
            q.correctAnswerIndex >= 0 && q.correctAnswerIndex < 4,
            isTrue,
            reason: 'Question "${q.id}" has invalid correctAnswerIndex: ${q.correctAnswerIndex}',
          );
        }
      }
    });

    test('QuizGenerator filters by difficulty level and generates 10 questions', () async {
      final rawSubject = QuizData.subjects.first; // OS subject

      for (final level in Difficulty.values) {
        final sessionSubject = await QuizGenerator.generateQuizSession(
          rawSubject,
          difficulty: level,
        );

        expect(sessionSubject.questions.length, equals(10));
        expect(sessionSubject.selectedDifficulty, equals(level));

        for (final sessionQ in sessionSubject.questions) {
          expect(sessionQ.difficulty, equals(level));

          // Verify option shuffling tracking
          final originalQ = rawSubject.questions.firstWhere((q) => q.id == sessionQ.id);
          final originalCorrectText = originalQ.options[originalQ.correctAnswerIndex];
          final sessionCorrectText = sessionQ.options[sessionQ.correctAnswerIndex];

          expect(sessionCorrectText, equals(originalCorrectText));
        }
      }
    });
  });
}
