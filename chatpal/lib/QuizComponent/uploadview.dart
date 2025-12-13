import 'package:flutter/material.dart';
import "dart:io";

class UploadView extends StatelessWidget {

  final File? selectedFile;
  final VoidCallback onClearFile;
  final VoidCallback onPickFile;
  final VoidCallback onGenerateQuiz;
  final String fun;

  const UploadView({  //constructor
    super.key,
    required this.selectedFile,
    required this.onClearFile,
    required this.onPickFile,
    required this.onGenerateQuiz,
    required this.fun,
  });

  @override
  Widget build(BuildContext context){
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(
                Icons.cloud_upload_outlined,
                size: 120,
                color: Colors.deepPurple.shade300,
              ),

              const SizedBox(height: 32,),

              Text(
                "Upload Your Pdf here",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900
                ),
              ),

              const SizedBox(height: 16,),

              Text(
                "Upload a PDF to generate a ${fun}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height:40),

              if(selectedFile != null)...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description,color:Colors.deepPurple),
                      const SizedBox(width: 12,),
                      Flexible(
                        child: Text(
                        selectedFile!.path.split('/').last,
                          style: const TextStyle(fontSize:16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                          onPressed: onClearFile,
                          icon: const Icon(Icons.close,color:Colors.red)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24,),
              ],
    ElevatedButton.icon(
    onPressed: onPickFile,
    icon: const Icon(Icons.file_upload),
    label: Text(selectedFile == null ? 'Choose File' : 'Change File'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white70,
    foregroundColor: Colors.deepPurple.shade700,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25),
    ),
    elevation: 8,
         )
      ,),
              if(selectedFile!=null)...[
                const SizedBox(height: 16,),
                ElevatedButton.icon(
                    onPressed: onGenerateQuiz,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Upload"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
                      elevation:10,
                    ),

                )
              ],
            ],
          ),
      ),

    );
  }

}