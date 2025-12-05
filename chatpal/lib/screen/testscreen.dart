import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/theme.dart'; // Ensure this path is correct for your project

class TestScreen extends StatefulWidget {
  final VoidCallback onUploadFileTap;
  final Function(String) onGenerateQuizTap;

  const TestScreen({
    Key? key,
    required this.onUploadFileTap,
    required this.onGenerateQuizTap,
  }) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // Store the full objects (Maps), not just strings
  List<dynamic> _documents = [];
  bool _isLoading = true;
  int? _selectedindex;

  @override
  void initState() {
    super.initState();
    _fetchdata();
  }

  Future<void> _fetchdata() async {
    // Use 10.0.2.2 for Emulator, 192.168... for Device
    // Ensure this matches your backend URL (remove 'quiz/' if needed based on previous steps)
    final url = Uri.parse("http://192.168.0.109:8000/api/sentences/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Handle if the key is 'sentences' or 'documents'
        final List<dynamic> docList = data['sentences'] ?? data['documents'] ?? [];

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  )),
              // 3. Trigger the Parent's callback
              onPressed: widget.onUploadFileTap,
              label: const Text("Upload File", style: TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
                icon: const Icon(Icons.quiz),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedindex == null
                        ? Colors.grey.shade400
                        : Colors.green.shade200,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _selectedindex == null
                                ? Colors.grey
                                : Colors.green.shade200,
                            width: 2),
                        borderRadius: BorderRadius.circular(16))),
                // 4. Trigger Parent callback with the ID
                onPressed: _selectedindex != null
                    ? () {
                  // Get the ID from the selected document object
                  final docId = _documents[_selectedindex!]['id'].toString();
                  widget.onGenerateQuizTap(docId);
                }
                    : null,
                label: const Text("Generate Quiz", style: TextStyle(fontSize: 15))),
          ],
        ),
        const SizedBox(height: 50),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _documents.isEmpty
              ? const Center(child: Text("No documents found. Upload one!"))
              : ListView.builder(
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final document = _documents[index];
              bool isSelected = _selectedindex == index;

              return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  height: 70,
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(
                        color: Colors.deepPurpleAccent, width: 2)
                        : Border.all(color: Colors.black54, width: 2),
                    borderRadius: BorderRadius.circular(15),
                    color: isSelected
                        ? Colors.purple.shade100
                        : Colors.white,
                  ),
                  child: Center(
                    child: ListTile(
                      onTap: () => setState(() {
                        if (_selectedindex == index)
                          _selectedindex = null;
                        else
                          _selectedindex = index;
                      }),
                      title: Text(
                        // Display the TITLE
                        document['title'].toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.purple.shade300
                              : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w700,
                        ),
                      ),
                      leading: Icon(
                          Icons.picture_as_pdf,
                          color: isSelected ? Colors.deepPurple : Colors.grey
                      ),
                    ),
                  ));
            },
          ),
        )
      ],
    );
  }
}