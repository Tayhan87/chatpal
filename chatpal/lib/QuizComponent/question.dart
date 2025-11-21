import "package:flutter/material.dart";

class Question{
  final String questionText;
  final List<String>Options;
  final String answer;

  Question({
    required this.answer,
    required this.Options,
    required this.questionText,
  });

  factory Question.fromJson(Map<String,dynamic>json){
    return Question(
      answer:json['answer'] ,
      Options: List<String>.from(json['options']),
      questionText: json['question'],
    );
  }
}