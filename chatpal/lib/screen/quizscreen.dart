import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "../theme/theme.dart";
import '../QuizComponent/loadview.dart';
import '../QuizComponent/uploadview.dart';
import '../QuizComponent/questionview.dart';
import '../QuizComponent/question.dart';
import '../CommonComponnent/commoncomponent.dart';
import 'testscreen.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback onBackTap;
  const QuizScreen({super.key, required this.onBackTap});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  // View State Variables
  File? _selectedFile;
  bool _isGenerating = false;
  bool _showUploadView = false; // Controls switching between TestScreen and UploadView

  // Quiz Data
  List<Question>? _quizQuestions;
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswer = {};

  // UPDATED: Base URL without the trailing 'quiz/' so endpoints like /make_pdf work correctly
  final String BackEndUrl = 'http://192.168.0.109:8000/api';

  // --- LOGIC: MAIN VIEW SWITCHER ---
  Widget _buildBody() {
    // 1. Loading
    if (_isGenerating) return LoadView();

    // 2. Taking Quiz
    if (_quizQuestions != null) {
      return QuizView(
        Questions: _quizQuestions!,
        currentQuestionIndex: _currentQuestionIndex,
        selectedAnswers: _selectedAnswer,
        onAnswerSelected: _selectAnswer,
        onNextQuestion: _nextQuestion,
        onPreviousQuestion: _previousQuestion,
        onSubmitQuiz: _submitQuiz,
      );
    }

    // 3. Upload New File
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
              onGenerateQuiz: _GenerateQuizFromFile,
            ),
          ),
        ],
      );
    }

    // 4. List of Existing Docs (TestScreen)
    return TestScreen(
      onUploadFileTap: () {
        setState(() {
          _showUploadView = true;
        });
      },
      onGenerateQuizTap: (String docIdString) {
        print("User selected document ID: $docIdString");
        // Convert the string ID to int and generate quiz
        try {
          int docId = int.parse(docIdString);
          _generateQuizFromDocument(docId);
        } catch (e) {
          _showError("Invalid Document ID format");
        }
      },
    );
  }

  Future<void> _pickFiles() async {
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions:["pdf"]
      );
      if(result!=null) {
        setState ((){
          _selectedFile= File(result.files.single.path!);
          _currentQuestionIndex=0;
          _quizQuestions=null;
          _selectedAnswer.clear();
        });
      }
    }catch(e){
      _showError("Error Picking File $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade100,
    ));
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _GenerateQuizFromFile() async {
    if(_selectedFile == null){
      _showError("Please select a file first");
      return;
    }
    setState(() {
      _isGenerating=true;
    });

    try{
      var request = http.MultipartRequest("POST", Uri.parse("$BackEndUrl/makepdf/"));
      request.files.add(
        await http.MultipartFile.fromPath("pdf", _selectedFile!.path),
      );
      var response = await request.send();

      if(response.statusCode==200 || response.statusCode==201){

        setState(() {
          _isGenerating = false;
          _showUploadView = false;
          _selectedFile = null;
        });

        _showError("File uploaded successfully.");

      }
      else{
        var responseData = await response.stream.bytesToString();
        throw Exception("Failed to Upload: ${response.statusCode} $responseData");
      }

    }catch(e){
      setState(() {
        _isGenerating=false;
      });
      _showError("Error uploading file: $e");
    }
  }


  // --- OPTION B: Generate from Existing Document ID ---
  Future<void> _generateQuizFromDocument(int documentId) async {
    setState(() {
      _isGenerating = true;
    });

    try {

      var url = Uri.parse("$BackEndUrl/generate_quiz/");

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "document_id": documentId,
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        setState(() {
          _quizQuestions = (jsonData['questions'] as List)
              .map((ques) => Question.fromJson(ques))
              .toList();
          _isGenerating = false;
          _showUploadView = false; // Close upload view if open
        });

        print("Quiz Generated with ${_quizQuestions!.length} questions");

      } else {
        throw Exception("Failed to Generate Quiz: ${response.statusCode} - ${response.body}");
      }

    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError("Error generating quiz: $e");
    }
  }



  void _nextQuestion(){
    if(_currentQuestionIndex<_quizQuestions!.length-1){
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion(){
    if(_currentQuestionIndex>0){
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }


  void _selectAnswer(String answer){
    setState(() {
      _selectedAnswer[_currentQuestionIndex]= answer ;
    });
  }

  int _calculateScore(){
    int score=0;
    for (int i=0;i<_quizQuestions!.length;i++){
      if(_selectedAnswer[i]==_quizQuestions![i].answer)
        score++;
    }
    return score;
  }

  void _submitQuiz(){
    final int score= _calculateScore();
    showDialog(
      context: context,
      builder: (dialogContext)=>AlertDialog(
        title: const Text("Quiz Complete"),
        content: Text(
          "Your Score: $score/${_quizQuestions!.length}\n"
              "${(score/_quizQuestions!.length*100).toStringAsFixed(1)}%",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(dialogContext);
            setState(() {
              _quizQuestions=null;
              _selectedFile=null;
              _currentQuestionIndex=0;
              _selectedAnswer.clear();
              _showUploadView=false; // Go back to start
            });
          }
              , child: const Text("Start Over"))
        ],
      ),
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
              Expanded(
                  child: _buildBody()
              ),
            ],
          ),
        ));
  }
}