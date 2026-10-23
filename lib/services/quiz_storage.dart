import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';

class QuizStorage {
  static const String _storageKey = 'custom_quizzes_v1';

  static Future<List<Subject>> loadCustomQuizzes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => Subject.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> saveCustomQuiz(Subject subject) async {
    try {
      final currentQuizzes = await loadCustomQuizzes();
      // Replace if existing ID, else add
      final index = currentQuizzes.indexWhere((s) => s.id == subject.id);
      if (index >= 0) {
        currentQuizzes[index] = subject;
      } else {
        currentQuizzes.add(subject);
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonList = currentQuizzes.map((s) => s.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteCustomQuiz(String id) async {
    try {
      final currentQuizzes = await loadCustomQuizzes();
      currentQuizzes.removeWhere((s) => s.id == id);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = currentQuizzes.map((s) => s.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      return false;
    }
  }
}
