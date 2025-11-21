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




class QuizScreen extends StatefulWidget{
  final VoidCallback onBackTap;
  const QuizScreen({super.key,required this.onBackTap});

  State<QuizScreen>createState()=>_QuizScreenState();


}

class _QuizScreenState extends State<QuizScreen>{


  File? _selectedFile;
  bool _isLoading = false ;
  int _currentQuestionIndex= 0 ;
  final Map<int,String>_selectedAnswer= {} ;
  List<Question>? _quizQuestions;

  final String BackEndUrl = 'http://192.168.0.109:8000/api/quiz/';




  Widget _buildBody(){
  if (_isLoading)
    return LoadView();
   else if (_quizQuestions !=null)
    return QuizView(
      Questions: _quizQuestions!,
      currentQuestionIndex: _currentQuestionIndex,
      selectedAnswers: _selectedAnswer,
      onAnswerSelected:_selectAnswer ,
      onNextQuestion: _nextQuestion,
      onPreviousQuestion: _previousQuestion,
      onSubmitQuiz: _submitQuiz,
    );
  else
    return UploadView(
      selectedFile: _selectedFile,
      onClearFile: _clearFile,
      onPickFile:_pickFiles,
      onGenerateQuiz:_GenerateQuiz ,
    );
  }


  Future <void> _pickFiles() async{
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


  void _showError(String msg){
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade100,
        )
      );
      print(msg);
  }



  void _clearFile(){
    setState(() {
      _selectedFile=null;
    });
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
          title: const Text("Quz Complete"),
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

              });
            }
                , child: const Text("Start Over"))
          ],
        ),
    );
  }


  Future <void> _GenerateQuiz() async{
    if(_selectedFile == null){
      _showError("Please  select a file first");
      return;
    }
    setState(() {
      _isLoading=true;
    });

    try{
      var request=http.MultipartRequest("POST",Uri.parse(BackEndUrl));
      request.files.add(
        await http.MultipartFile.fromPath("File", _selectedFile!.path),
      );
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      
      if(response.statusCode==200){
        var jsonData=json.decode(responseData);
        setState(() {
          _quizQuestions=(jsonData['questions'] as List)
              .map((ques)=>Question.fromJson(ques)).toList();
          _isLoading=false;
        });
      }
      else{
        throw Exception("Failed to Generate Quiz: ${response.reasonPhrase} ");
      }
      
    }catch(e){
      setState(() {
      _isLoading=false;
      });
      _showError("Error generating quiz $e");
    }

  }


  @override
  Widget build(BuildContext context){
    return Container(

        decoration:AppTheme.buildBoxDecoration,
        child: SafeArea(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width:8),
                  IconButton(
                      onPressed: widget.onBackTap,
                      icon: Icon(Icons.arrow_back_ios,color: Colors.black54,size: 38,)
                  ),
                  SizedBox(width: 8,),
                  Text("Take Quizes", style: AppTheme.Titlefont,)
                ],
              ),
              Expanded(
                  child: _buildBody()
              ),
            ],
          ),
        )
    );
  }

}




