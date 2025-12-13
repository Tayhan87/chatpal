import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../url.dart';

class PDFTitleView extends StatefulWidget {
  final VoidCallback onUploadFileTap;
  final Function(String) onGenerateQuizTap;
  final String fun;

  const PDFTitleView({
    Key? key,
    required this.onUploadFileTap,
    required this.onGenerateQuizTap,
    required this.fun,
  }) : super(key: key);

  @override
  State<PDFTitleView> createState() => _PDFTitleState();
}

class _PDFTitleState extends State<PDFTitleView> {

  List<dynamic> _documents = [];
  bool _isLoading = true;
  int? _selectedindex;


  @override
  void initState() {
    super.initState();
    _fetchdata();
  }



  Future<void> _deleteDocument(int index) async {
    final document = _documents[index];
    final docId = document['id'].toString();

    final url = Uri.parse("${BackEndUrl}delete_pdf/$docId/");

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          setState(() {
            _documents.removeAt(index);
            if (_selectedindex == index) {
              _selectedindex = null;
            } else if (_selectedindex != null && _selectedindex! > index) {
              _selectedindex = _selectedindex! - 1;
            }
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print("Error deleting document: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete document: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Exception deleting document: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(int index) {
    final document = _documents[index];
    final title = document['title'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDocument(index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }




  Future<void> _fetchdata() async {

    final url = Uri.parse("${BackEndUrl}pdf_titles/");

    final prefs= await SharedPreferences.getInstance();
    final String?  token = prefs.getString("token");

    print("Using Token: $token");

    try {
      final response = await http.get(
          url,
        headers:{
            "Content-Type":"application/json",
            "Authorization" :"Token $token",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> docList = data['titles']  ?? [];

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
                label: Text(widget.fun, style: TextStyle(fontSize: 15))),
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
                      onLongPress: () => _showDeleteDialog(index),
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