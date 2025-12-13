import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../QuizComponent/uploadview.dart';
import '../QuizComponent/loadview.dart';
import '../QuizComponent/pdftitleview.dart';
import '../FlashCardComponent/flashcard.dart';
import '../FlashCardComponent/flashcardcomponent.dart';
import "../theme/theme.dart";
import '../url.dart';

// Header widget component
class Head extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;

  const Head({
    super.key,
    required this.title,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class FlashCardScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const FlashCardScreen({super.key, required this.onBackTap});

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  // View State
  File? _selectedFile;
  bool _isGenerating = false;
  bool _showUploadView = false;

  // Flashcard Data
  List<FlashCard>? _flashCards;
  int _currentCardIndex = 0;
  bool _isFlipped = false;

  // Document List
  List<dynamic> _documents = [];
  bool _isLoading = true;
  int? _selectedDocId;

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }



  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ["pdf"]);
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _currentCardIndex = 0;
          _flashCards = null;
        });
      }
    } catch (e) {
      _showError("Error Picking File $e");
    }
  }

  // Fetch available documents
  Future<void> _fetchdata() async {
    final url = Uri.parse("${BackEndUrl}/pdf_titles/");
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    print("Using Token: $token");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> docList = data['titles'] ?? [];

        if (mounted) {
          setState(() {
            _documents = docList;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Exception fetching data: $e");
    }
  }

  Future<void> _GeneratePDFFromFile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (_selectedFile == null) {
      _showError("Please select a file first");
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      var request = http.MultipartRequest("POST", Uri.parse("${BackEndUrl}makepdf/"));
      request.headers["Authorization"] = "Token $token";
      request.files.add(await http.MultipartFile.fromPath("pdf", _selectedFile!.path),);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(responseData);

        setState(() {
          _isGenerating = false;
          _showUploadView = false;
          _selectedFile = null;
          _currentCardIndex = 0;
          _isFlipped = false;
        });
        _showSuccess("File uploaded successfully.");
        _fetchdata();
      } else {
        throw Exception(
            "Failed to generate flashcards: ${response.statusCode} $responseData");
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError("Error generating flashcards: $e");
    }
  }

  // Added missing method
  Future<void> _generateCardFromDocument(int documentId) async {
    setState(() {
      _isGenerating = true;
      _selectedDocId = documentId;
    });
    final prefs = await SharedPreferences.getInstance();
    final String? token =prefs.getString("token");


    try {
      var url = Uri.parse("${BackEndUrl}generate_flashcards_from_doc/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json","Authorization":"Token $token"},
        body: json.encode({"document_id": documentId}),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        setState(() {
          _flashCards = (jsonData['flashcards'] as List)
              .map((card) => FlashCard.fromJson(card))
              .toList();
          _isGenerating = false;
          _currentCardIndex = 0;
          _isFlipped = false;
        });
        _showSuccess("Flashcards generated successfully.");
      } else {
        throw Exception(
            "Failed to generate flashcards: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError("Error generating flashcards: $e");
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade400,
      duration: const Duration(seconds: 2),
    ));
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    if (_currentCardIndex < _flashCards!.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
      });
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _isFlipped = false;
      });
    }
  }

  void _exitFlashCards() {
    setState(() {
      _flashCards = null;
      _currentCardIndex = 0;
      _isFlipped = false;
      _selectedDocId = null;
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }


  Widget _buildBody() {
    if (_isGenerating) return LoadView(fun: "Flash Card",);

    if (_flashCards != null && _flashCards!.isNotEmpty) {
      return FlashCardView(
        flashCards: _flashCards!,
        currentCardIndex: _currentCardIndex,
        isFlipped: _isFlipped,
        onNextCard: _nextCard,
        onPreviousCard: _previousCard,
        onFlip: _flipCard,
        onExit: _exitFlashCards,
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
              fun:"Flash Card",
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
      fun:"Generate Flash Card",
      onGenerateQuizTap: (String docIdString) {
        print("User selected document ID: $docIdString");
        try {
          int docId = int.parse(docIdString);
          _generateCardFromDocument(docId);
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
              Head(title: "Flash Notes", onBackTap: widget.onBackTap),
              Expanded(child: _buildBody()),
            ],
          ),
        ));
  }
}