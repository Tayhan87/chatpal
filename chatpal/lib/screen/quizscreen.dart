import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import "../theme/theme.dart";
import '../QuizComponent/loadview.dart';
import '../QuizComponent/uploadview.dart';
import '../QuizComponent/questionview.dart';
import '../QuizComponent/question.dart';
import '../CommonComponnent/commoncomponent.dart';
import '../QuizComponent/pdftitleview.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback onBackTap;
  const QuizScreen({super.key, required this.onBackTap});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  File? _selectedFile;
  bool _isGenerating = false;
  bool _showUploadView = false;

  List<Question>? _quizQuestions;
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswer = {};
  int? _currentDocumentId;

  final String BackEndUrl = 'http://192.168.0.109:8000/api';




  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ["pdf"]);
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _currentQuestionIndex = 0;
          _quizQuestions = null;
          _selectedAnswer.clear();
        });
      }
    } catch (e) {
      _showError("Error Picking File $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade100,
      duration: const Duration(seconds: 2),
    ));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 2)));
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _GeneratePDFFromFile() async {
    if (_selectedFile == null) {
      _showError("Please select a file first");
      return;
    }
    setState(() {
      _isGenerating = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    try {
      var request =
      http.MultipartRequest("POST", Uri.parse("$BackEndUrl/makepdf/"));
      request.headers["Authorization"] = "Token $token";
      request.files.add(
        await http.MultipartFile.fromPath("pdf", _selectedFile!.path),
      );
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isGenerating = false;
          _showUploadView = false;
          _selectedFile = null;
        });

        _showSuccess("File uploaded successfully.");
      } else {
        var responseData = await response.stream.bytesToString();
        throw Exception(
            "Failed to Upload: ${response.statusCode} $responseData");
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError("Error uploading file: $e");
    }
  }


  Future<void> _generateQuizFromDocument(int documentId,
      {List<String>? wrongTopics}) async {

    if (!mounted) return;

    setState(() {
      _isGenerating = true;
      _currentDocumentId = documentId;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    try {
      var url = Uri.parse("$BackEndUrl/generate_quiz/");

      Map<String, dynamic> requestBody = {
        "document_id": documentId,
      };
      if (wrongTopics != null && wrongTopics.isNotEmpty) {
        requestBody["wrong_topics"] = wrongTopics;
        requestBody["retry_mode"] = true;
      }

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: json.encode(requestBody),
      );

      // Safety check again after async await
      if (!mounted) return;

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        setState(() {
          _quizQuestions = (jsonData['questions'] as List)
              .map((ques) => Question.fromJson(ques))
              .toList();
          _currentQuestionIndex = 0;
          _selectedAnswer.clear();

          _isGenerating = false; // This switches UI back to QuizView
          _showUploadView = false;
        });

        if (wrongTopics != null && wrongTopics.isNotEmpty) {
          _showSuccess("New quiz focused on your weak areas!");
        }
      } else {
        throw Exception(
            "Failed to Generate Quiz: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
      _showError("Error generating quiz: $e");
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer[_currentQuestionIndex] = answer;
    });
  }

  Map<String, dynamic> _calculateResults() {
    int score = 0;
    List<int> wrongIndices = [];

    for (int i = 0; i < _quizQuestions!.length; i++) {
      if (_selectedAnswer[i] == _quizQuestions![i].correctAnswer) {
        score++;
      } else {
        wrongIndices.add(i);
      }
    }

    return {
      'score': score,
      'total': _quizQuestions!.length,
      'wrongIndices': wrongIndices,
    };
  }

  void _submitQuiz(BuildContext context, int score, List<int> wrongIndices) {

    if (_currentDocumentId != null) {
      List<String> wrongTopics = wrongIndices.map((index) {
        return _quizQuestions![index].questionText;
      }).toList();


      _generateQuizFromDocument(_currentDocumentId!, wrongTopics: wrongTopics);

    } else {
      _showError("Cannot retry: Document ID not found");
    }
  }


  // Inside _QuizScreenState in quizscreen.dart

  void _returnToTitleView() {
    setState(() {
      _quizQuestions = null; // <--- This triggers the switch back to PDFTitleView
      _currentQuestionIndex = 0;
      _selectedAnswer.clear();
      _currentDocumentId = null; // Optional: Clear ID if you want fresh start
    });
  }



  Widget _buildBody() {
  if (_isGenerating) return LoadView();
  if (_quizQuestions != null) {
    return QuizView(
      Questions: _quizQuestions!,
      currentQuestionIndex: _currentQuestionIndex,
      selectedAnswers: _selectedAnswer,
      onAnswerSelected: _selectAnswer,
      onNextQuestion: _nextQuestion,
      onPreviousQuestion: _previousQuestion,
      onSubmitQuiz: _submitQuiz,
      onQuizDone: _returnToTitleView,
    );
  }
  if (_showUploadView) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.arrow_back),
            label: Text("Back to List"),
            onPressed: () => setState(() => _showUploadView = false),
          ),
        ),
        Expanded(
          child: UploadView(
            selectedFile: _selectedFile,
            onClearFile: _clearFile,
            onPickFile: _pickFiles,
            onGenerateQuiz: _GeneratePDFFromFile,
          ),
        ),
      ],
    );
  }

  return PDFTitleView(
    onUploadFileTap: () {
      setState(() {
        _showUploadView = true;
      });
    },
    onGenerateQuizTap: (String docIdString) {
      print("User selected document ID: $docIdString");

      try {
        int docId = int.parse(docIdString);
        _generateQuizFromDocument(docId);
      } catch (e) {
        _showError("Invalid Document ID format");
      }
    },
  );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: AppTheme.buildBoxDecoration,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Head(title: "Take Quizzes", onBackTap: widget.onBackTap),
              Expanded(child: _buildBody()),
            ],
          ),
        ));
  }
}