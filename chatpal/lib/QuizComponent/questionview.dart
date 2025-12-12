import 'package:chatpal/screen/quizscreen.dart';
import 'package:flutter/material.dart';
import 'question.dart';

class QuizView extends StatelessWidget {
  final List<Question> Questions;
  final int currentQuestionIndex;
  final Map<int, String> selectedAnswers;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onNextQuestion;
  final VoidCallback onPreviousQuestion;
  final Function(BuildContext, int, List<int>) onSubmitQuiz;
  final VoidCallback onQuizDone;

  const QuizView({
    super.key,
    required this.Questions,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    required this.onNextQuestion,
    required this.onPreviousQuestion,
    required this.onSubmitQuiz,
    required this.onQuizDone,
  });

  // Calculate score and get wrong question indices
  Map<String, dynamic> _calculateResults() {
    int correctCount = 0;
    List<int> wrongIndices = [];

    for (int i = 0; i < Questions.length; i++) {
      final userAnswer = selectedAnswers[i];
      final correctAnswer = Questions[i].correctAnswer;

      if (userAnswer == correctAnswer) {
        correctCount++;
      } else {
        wrongIndices.add(i);
      }
    }

    return {
      'score': correctCount,
      'total': Questions.length,
      'wrongIndices': wrongIndices,
    };
  }

  void _showResultDialog(BuildContext context) {
    final results = _calculateResults();
    final score = results['score'] as int;
    final total = results['total'] as int;
    final wrongIndices = results['wrongIndices'] as List<int>;
    final percentage = (score / total * 100).toStringAsFixed(1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                score >= total * 0.7 ? Icons.celebration : Icons.info_outline,
                size: 60,
                color: score >= total * 0.7 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                score >= total * 0.7 ? 'Great Job!' : 'Keep Practicing!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Score',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score / $total',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade700,
                ),
              ),
              if (wrongIndices.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'You got ${wrongIndices.length} question(s) wrong',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (wrongIndices.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onSubmitQuiz(context, score, wrongIndices);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onQuizDone();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = Questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == Questions.length - 1;
    final allQuestionAnswered = selectedAnswers.length == Questions.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${currentQuestionIndex + 1}/${Questions.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${selectedAnswers.length}/${Questions.length}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      question.questionText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...question.Options.map((option) {
                  final isSelected =
                      selectedAnswers[currentQuestionIndex] == option;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => onAnswerSelected(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple.shade100
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.deepPurple.shade900
                                        : Colors.black87),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ]),
          child: Row(
            children: [
              if (currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPreviousQuestion,
                    icon: const Icon(Icons.arrow_back_ios),
                    label: const Text("Previous"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.deepPurple),
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
              if (currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLastQuestion && allQuestionAnswered
                      ? () => _showResultDialog(context)
                      : isLastQuestion
                      ? null
                      : onNextQuestion,
                  icon: Icon(
                    isLastQuestion && allQuestionAnswered
                        ? Icons.check_circle
                        : Icons.arrow_forward,
                  ),
                  label: Text(isLastQuestion && allQuestionAnswered
                      ? "Submit Quiz"
                      : "Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion && allQuestionAnswered
                        ? Colors.green
                        : Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}