import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlashCard {
  final String front;
  final String back;

  FlashCard({required this.front, required this.back});

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      front: json['front'] ?? json['question'] ?? '',
      back: json['back'] ?? json['answer'] ?? '',
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
  List<Map<String, dynamic>> _documents = [];
  bool _isFetchingDocs = true;
  int? _selectedDocId;

  final String BackEndUrl = 'http://192.168.0.109:8000/api';

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  // Fetch available documents
  Future<void> _fetchDocuments() async {
    final url = Uri.parse("$BackEndUrl/documents/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _documents = data.map((doc) => doc as Map<String, dynamic>).toList();
          _isFetchingDocs = false;
        });
      } else {
        setState(() => _isFetchingDocs = false);
        _showError("Failed to load documents");
      }
    } catch (e) {
      setState(() => _isFetchingDocs = false);
      _showError("Error loading documents: $e");
    }
  }

  Widget _buildBody() {
    // 1. Loading/Generating
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              "Generating Flashcards...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Viewing Flashcards
    if (_flashCards != null && _flashCards!.isNotEmpty) {
      return _buildFlashCardView();
    }

    // 3. Upload View
    if (_showUploadView) {
      return _buildUploadView();
    }

    // 4. Document List View
    return _buildDocumentListView();
  }

  Widget _buildDocumentListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green.shade300, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    )
                ),
                onPressed: () {
                  setState(() {
                    _showUploadView = true;
                  });
                },
                label: const Text(
                  "Upload PDF",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.style),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedDocId == null
                      ? Colors.grey.shade400
                      : Colors.purple.shade200,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: _selectedDocId == null
                              ? Colors.grey
                              : Colors.purple.shade300,
                          width: 2
                      ),
                      borderRadius: BorderRadius.circular(16)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _selectedDocId != null
                    ? () => _generateFlashCardsFromDocument(_selectedDocId!)
                    : null,
                label: const Text(
                  "Generate Flashcards",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _isFetchingDocs
              ? const Center(child: CircularProgressIndicator())
              : _documents.isEmpty
              ? Center(
            child: Text(
              "No documents available.\nUpload a PDF to get started!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final doc = _documents[index];
              final docId = doc['id'];
              final docName = doc['name'] ?? doc['title'] ?? 'Document ${index + 1}';
              final isSelected = _selectedDocId == docId;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(color: Colors.purple.shade400, width: 2)
                      : Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(15),
                  color: isSelected
                      ? Colors.purple.shade50
                      : Colors.white,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: isSelected ? Colors.purple.shade400 : Colors.red.shade400,
                    size: 30,
                  ),
                  title: Text(
                    docName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.purple.shade700 : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.purple.shade400)
                      : null,
                  onTap: () {
                    setState(() {
                      if (_selectedDocId == docId) {
                        _selectedDocId = null;
                      } else {
                        _selectedDocId = docId;
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUploadView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to List"),
              onPressed: () => setState(() {
                _showUploadView = false;
                _selectedFile = null;
              }),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
                      size: 80,
                      color: Colors.purple.shade400,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_selectedFile != null) ...[
                    Text(
                      "Selected File:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: _clearFile,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _uploadAndGenerateFlashCards,
                      label: const Text(
                        "Upload & Generate Flashcards",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ] else ...[
                    Text(
                      "No file selected",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.folder_open),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _pickFile,
                      label: const Text(
                        "Choose PDF File",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashCardView() {
    final card = _flashCards![_currentCardIndex];

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Card ${_currentCardIndex + 1} of ${_flashCards!.length}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text("Exit"),
                onPressed: () {
                  setState(() {
                    _flashCards = null;
                    _currentCardIndex = 0;
                    _isFlipped = false;
                    _selectedDocId = null;
                  });
                },
              ),
            ],
          ),
        ),

        // Linear progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: (_currentCardIndex + 1) / _flashCards!.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: 40),

        // Flashcard
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFlipped = !_isFlipped;
                });
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey<bool>(_isFlipped),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(
                    minHeight: 300,
                    maxHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    color: _isFlipped ? Colors.purple.shade400 : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isFlipped ? "ANSWER" : "QUESTION",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isFlipped ? Colors.white70 : Colors.grey.shade500,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isFlipped ? card.back : card.front,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _isFlipped ? Colors.white : Colors.grey.shade800,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Icon(
                            Icons.touch_app,
                            color: _isFlipped ? Colors.white60 : Colors.grey.shade400,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap to flip",
                            style: TextStyle(
                              fontSize: 12,
                              color: _isFlipped ? Colors.white70 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentCardIndex > 0
                      ? Colors.purple.shade400
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _currentCardIndex > 0 ? _previousCard : null,
                label: const Text("Previous"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentCardIndex < _flashCards!.length - 1
                      ? Colors.purple.shade400
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _currentCardIndex < _flashCards!.length - 1 ? _nextCard : null,
                label: const Text("Next"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ["pdf"]
      );
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showError("Error picking file: $e");
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _uploadAndGenerateFlashCards() async {
    if (_selectedFile == null) {
      _showError("Please select a file first");
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Upload PDF and generate flashcards
      var request = http.MultipartRequest("POST", Uri.parse("$BackEndUrl/generate_flashcards/"));
      request.files.add(
        await http.MultipartFile.fromPath("pdf", _selectedFile!.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(responseData);

        setState(() {
          _flashCards = (jsonData['flashcards'] as List)
              .map((card) => FlashCard.fromJson(card))
              .toList();
          _isGenerating = false;
          _showUploadView = false;
          _selectedFile = null;
          _currentCardIndex = 0;
          _isFlipped = false;
        });

        // Refresh document list
        _fetchDocuments();
      } else {
        throw Exception("Failed to generate flashcards: ${response.statusCode} $responseData");
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError("Error generating flashcards: $e");
    }
  }

  Future<void> _generateFlashCardsFromDocument(int documentId) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      var url = Uri.parse("$BackEndUrl/generate_flashcards_from_doc/");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
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
      } else {
        throw Exception("Failed to generate flashcards: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError("Error generating flashcards: $e");
    }
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

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackTap,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Flashcards",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}