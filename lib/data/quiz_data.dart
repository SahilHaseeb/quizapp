import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../theme/app_tokens.dart';
import 'coal_questions.dart';
import 'daa_questions.dart';
import 'mobile_questions.dart';
import 'os_questions.dart';
import 'stats_questions.dart';
import 'web_questions.dart';

class QuizData {
  static const int questionsPerQuiz = 10;

  static const List<Subject> subjects = [
    Subject(
      id: 'os',
      title: 'Operating Systems',
      subtitle: 'OS concepts, processes, memory & scheduling',
      icon: Icons.memory_rounded,
      themeColor: Color(0xFF2563EB),
      gradientColors: AppTokens.osGradient,
      questions: osQuestionBank,
    ),
    Subject(
      id: 'web',
      title: 'Web Application',
      subtitle: 'HTML, CSS, JS, HTTP & Client-Server architecture',
      icon: Icons.language_rounded,
      themeColor: Color(0xFF0D9488),
      gradientColors: AppTokens.webGradient,
      questions: webQuestionBank,
    ),
    Subject(
      id: 'mobile',
      title: 'Mobile Application Development',
      subtitle: 'Flutter, Dart, Widgets, State & Layouts',
      icon: Icons.phone_android_rounded,
      themeColor: Color(0xFF7C3AED),
      gradientColors: AppTokens.mobileGradient,
      questions: mobileQuestionBank,
    ),
    Subject(
      id: 'daa',
      title: 'Design & Analysis of Algorithms',
      subtitle: 'Big-O notation, searching, sorting & invariants',
      icon: Icons.account_tree_rounded,
      themeColor: Color(0xFFEA580C),
      gradientColors: AppTokens.daaGradient,
      questions: daaQuestionBank,
    ),
    Subject(
      id: 'stats',
      title: 'Statistics',
      subtitle: 'Means, medians, variance, deviation & dispersion',
      icon: Icons.bar_chart_rounded,
      themeColor: Color(0xFFDB2777),
      gradientColors: AppTokens.statsGradient,
      questions: statsQuestionBank,
    ),
    Subject(
      id: 'coal',
      title: 'COAL',
      subtitle: 'CPU architecture, registers, binary & assembly',
      icon: Icons.developer_board_rounded,
      themeColor: Color(0xFF059669),
      gradientColors: AppTokens.coalGradient,
      questions: coalQuestionBank,
    ),
  ];
}
