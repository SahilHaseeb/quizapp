import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quiz_data.dart';
import '../models/question.dart';
import '../models/subject.dart';

class QuizGenerator {
  static const int questionsPerQuiz = QuizData.questionsPerQuiz;

  /// Generate a randomized quiz session filtered by difficulty level
  /// with repeat prevention across attempts and option shuffling.
  static Future<Subject> generateQuizSession(
    Subject rawSubject, {
    Difficulty? difficulty,
  }) async {
    List<Question> bank = rawSubject.questions;

    // Filter by difficulty if provided
    if (difficulty != null) {
      final filtered = bank.where((q) => q.difficulty == difficulty).toList();
      if (filtered.isNotEmpty) {
        bank = filtered;
      }
    }

    List<Question> selectedBank;

    if (rawSubject.isCustom) {
      selectedBank = List<Question>.from(bank);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final levelKey = difficulty != null ? difficulty.name : 'all';
      final storageKey = 'last_used_q_ids_${rawSubject.id}_$levelKey';
      final List<String> lastUsedIds =
          prefs.getStringList(storageKey) ?? <String>[];

      final unusedQuestions =
          bank.where((q) => !lastUsedIds.contains(q.id)).toList();
      final usedQuestions =
          bank.where((q) => lastUsedIds.contains(q.id)).toList();

      unusedQuestions.shuffle(Random());
      usedQuestions.shuffle(Random());

      if (unusedQuestions.length >= questionsPerQuiz) {
        selectedBank = unusedQuestions.take(questionsPerQuiz).toList();
      } else {
        selectedBank = List<Question>.from(unusedQuestions);
        final needed = questionsPerQuiz - selectedBank.length;
        selectedBank.addAll(usedQuestions.take(needed));
      }

      final newUsedIds = selectedBank.map((q) => q.id).toList();
      await prefs.setStringList(storageKey, newUsedIds);
    }

    // Shuffle question order
    selectedBank.shuffle(Random());

    // Shuffle options for each question
    final List<Question> sessionQuestions = selectedBank.map((q) {
      final List<String> originalOptions = List<String>.from(q.options);
      final String correctAnswerText = originalOptions[q.correctAnswerIndex];

      final List<String> shuffledOptions = List<String>.from(originalOptions)
        ..shuffle(Random());
      final int newCorrectIndex = shuffledOptions.indexOf(correctAnswerText);

      return Question(
        id: q.id,
        questionText: q.questionText,
        options: shuffledOptions,
        correctAnswerIndex: newCorrectIndex,
        explanation: q.explanation,
        difficulty: q.difficulty,
      );
    }).toList();

    return Subject(
      id: rawSubject.id,
      title: rawSubject.title,
      subtitle: rawSubject.subtitle,
      icon: rawSubject.icon,
      themeColor: rawSubject.themeColor,
      gradientColors: rawSubject.gradientColors,
      questions: sessionQuestions,
      isCustom: rawSubject.isCustom,
      createdAt: rawSubject.createdAt,
      selectedDifficulty: difficulty,
    );
  }
}
