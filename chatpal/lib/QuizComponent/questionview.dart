import 'package:chatpal/screen/quizscreen.dart';
import 'package:flutter/material.dart';
import 'question.dart';

class QuizView extends StatelessWidget{

  final List<Question> Questions;
  final int currentQuestionIndex;
  final Map <int,String> selectedAnswers;
  final ValueChanged<String>onAnswerSelected;
  final VoidCallback onNextQuestion;
  final VoidCallback onPreviousQuestion;
  final VoidCallback onSubmitQuiz;

  const QuizView({
    super.key,
    required this.Questions,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    required this.onNextQuestion,
    required this.onPreviousQuestion,
    required this.onSubmitQuiz

  });
  
  @override
  Widget build(BuildContext context) {
    final question =Questions[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == Questions.length-1;
    final allQuestionAnswered = selectedAnswers.length==Questions.length;



    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "${currentQuestionIndex+1}/${Questions.length}",
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
        Expanded(child: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Padding(
                    padding:const EdgeInsets.all(20),
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
              const SizedBox(height: 24,),
              ...question.Options.map((option){
                final isSelected = selectedAnswers[currentQuestionIndex] ==option;
                return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: ()=>onAnswerSelected(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected? Colors.deepPurple.shade100 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.deepPurple: Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked:Icons.radio_button_unchecked,
                              color: isSelected ? Colors.deepPurple:Colors.grey,
                            ),
                            const SizedBox(width: 12,),
                            Expanded(child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.deepPurple.shade900 :Colors.black87
                              ),
                            ),)
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
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, -2),
              )
            ]
          ),
          child: Row(
            children: [
              if(currentQuestionIndex>0)
                Expanded(
                  child: OutlinedButton.icon(
                      onPressed: onPreviousQuestion ,
                      icon:const Icon(Icons.arrow_back_ios),
                      label:const Text("Previous"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.deepPurple),
                        foregroundColor: Colors.deepPurple,
                      ),
                  ),
                ),
              if(currentQuestionIndex>0) const SizedBox(width: 12,),
              Expanded(
                  child: ElevatedButton.icon(
                  onPressed:
                  isLastQuestion && allQuestionAnswered ?
                  onSubmitQuiz:isLastQuestion?null:onNextQuestion,
                  icon: Icon(
                     isLastQuestion && allQuestionAnswered ?
                         Icons.check_circle : Icons.arrow_forward,
                   ),
                      label: Text(isLastQuestion && allQuestionAnswered ? "Submit Quiz" :"Next"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastQuestion && allQuestionAnswered ? Colors.green :Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey,
                  )
                )
              )
            ],
          ),
        )
      ],
    );
  }
}