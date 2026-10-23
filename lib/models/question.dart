enum Difficulty { easy, medium, hard }

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final Difficulty difficulty;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.difficulty = Difficulty.easy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'explanation': explanation,
        'difficulty': difficulty.name,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String? ?? '',
        questionText: json['questionText'] as String? ?? '',
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        correctAnswerIndex: json['correctAnswerIndex'] as int? ?? 0,
        explanation: json['explanation'] as String? ?? '',
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == (json['difficulty'] as String? ?? 'easy'),
          orElse: () => Difficulty.easy,
        ),
      );
}
