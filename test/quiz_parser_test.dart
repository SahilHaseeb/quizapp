import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/quiz_parser.dart';

void main() {
  group('QuizParser Unit Tests', () {
    test('Parses valid text format correctly', () {
      const rawText = '''
Subject: Software Engineering Basics

Q1. What does SDLC stand for?
A) Software Development Life Cycle
B) System Design Logic Center
C) Standard Data Link Control
D) Software Design Language Compiler
Answer: A
Explanation: SDLC is Software Development Life Cycle.

Q2. Which model is sequential?
A) Agile
B) Waterfall
C) Scrum
D) Kanban
Ans: B
Explanation: Waterfall is sequential.
''';

      final result = QuizParser.parseText(
        rawText: rawText,
        defaultTitle: 'Default Title',
      );

      expect(result.title, equals('Software Engineering Basics'));
      expect(result.validQuestions.length, equals(2));
      expect(result.errors.isEmpty, isTrue);

      final q1 = result.validQuestions[0];
      expect(q1.questionText, equals('What does SDLC stand for?'));
      expect(q1.options.length, equals(4));
      expect(q1.options[0], equals('Software Development Life Cycle'));
      expect(q1.correctAnswerIndex, equals(0)); // Option A
      expect(q1.explanation, contains('SDLC is Software Development Life Cycle'));

      final q2 = result.validQuestions[1];
      expect(q2.questionText, equals('Which model is sequential?'));
      expect(q2.correctAnswerIndex, equals(1)); // Option B
    });

    test('Collects errors for broken questions and parses valid ones', () {
      const rawText = '''
Q1. Valid Question?
A) Option A
B) Option B
C) Option C
D) Option D
Answer: C

Q2. Broken Question missing option D
A) Opt A
B) Opt B
C) Opt C
Answer: A

Q3. Broken Question missing answer
A) Opt A
B) Opt B
C) Opt C
D) Opt D
''';

      final result = QuizParser.parseText(
        rawText: rawText,
        defaultTitle: 'Test Title',
      );

      expect(result.validQuestions.length, equals(1));
      expect(result.errors.length, equals(2));
      expect(result.errors[0], contains('Missing option(s): D'));
      expect(result.errors[1], contains('Missing or invalid correct answer'));
    });
  });
}
