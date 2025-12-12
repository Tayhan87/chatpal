class Question {
  final String questionText;
  final List<String> Options;
  final String answer; // Keep for backward compatibility
  final String correctAnswer; // For checking answers

  Question({
    required this.questionText,
    required this.Options,
    required this.answer,
  }) : correctAnswer = answer; // Same value for both

  // Alternative constructor if you want to be explicit
  Question.withAnswer({
    required this.questionText,
    required this.Options,
    required this.correctAnswer,
  })  : answer = correctAnswer;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'] ?? '',
      Options: List<String>.from(json['options'] ?? []),
      answer: json['correct_answer'] ?? json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': questionText,
      'options': Options,
      'correct_answer': correctAnswer,
    };
  }
}