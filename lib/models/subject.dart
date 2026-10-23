import 'package:flutter/material.dart';
import 'question.dart';

class Subject {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final List<Color>? gradientColors;
  final List<Question> questions;
  final bool isCustom;
  final DateTime? createdAt;
  final Difficulty? selectedDifficulty;

  const Subject({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    this.gradientColors,
    required this.questions,
    this.isCustom = false,
    this.createdAt,
    this.selectedDifficulty,
  });

  List<Color> get effectiveGradient {
    if (gradientColors != null && gradientColors!.length >= 2) {
      return gradientColors!;
    }
    return [
      themeColor,
      themeColor.withValues(alpha: 0.85),
    ];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'themeColorValue': themeColor.toARGB32(),
        'gradientColorValues':
            gradientColors?.map((c) => c.toARGB32()).toList(),
        'questions': questions.map((q) => q.toJson()).toList(),
        'isCustom': isCustom,
        'createdAt': createdAt?.toIso8601String(),
        'selectedDifficulty': selectedDifficulty?.name,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? 'Custom Uploaded Quiz',
        icon: Icons.quiz_outlined,
        themeColor: Color(json['themeColorValue'] as int? ?? 0xFF4F46E5),
        gradientColors: (json['gradientColorValues'] as List<dynamic>?)
            ?.map((e) => Color(e as int))
            .toList(),
        questions: (json['questions'] as List<dynamic>)
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList(),
        isCustom: json['isCustom'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        selectedDifficulty: json['selectedDifficulty'] != null
            ? Difficulty.values.firstWhere(
                (d) => d.name == json['selectedDifficulty'],
                orElse: () => Difficulty.easy,
              )
            : null,
      );
}
