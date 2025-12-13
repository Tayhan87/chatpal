import "dart:convert";
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";
import "../theme/theme.dart";
import '../CommonComponnent/commoncomponent.dart';



class AIChatScreen extends StatefulWidget{
  final VoidCallback onBackTap;
  const AIChatScreen({super.key,required this.onBackTap});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();

}

class _AIChatScreenState extends State<AIChatScreen>{

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List <_Message> _messages=[];
  bool _isTyping=false;

  Future<String> fetchData() async{

    final response =await http.post(Uri.parse
     (BackEndUrl),
    headers:{'Content-Type':'application/json'},
     body:jsonEncode({"messages":_messages.map((m)=>{
     "role": m.isUser ? "user" : "assistant",
     "content" :m.text,
     }).toList()
     }),
   );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      debugPrint('Error: ${response.statusCode}');
      return '⚠️ Server error';
    }

  }

  Future<void> _sendMessage(String text) async{
    if (text.trim().isEmpty) return;

    setState(()=>_messages.add(_Message(text, true)));

    _scrollToBottom();
    _controller.clear();
    setState(() => _isTyping = true);

    final reply = await fetchData();
    _simulateResponse(reply);
  }

  @override
  void dispose(){
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
}

void _simulateResponse(String response) async{

    String displayed = "";
    bool firstChar = true;

    for(int i=0;i<response.length;i++){
    await Future.delayed(const Duration(milliseconds: 40));
    if(!mounted) return;

    setState(() {
      displayed =response.substring(0,i+1);

      if(_messages.isNotEmpty && !_messages.last.isUser){
        _messages[_messages.length-1 ] = _Message(displayed, false);
      }

      else{
        _messages.add(_Message(displayed, false));
        _scrollToBottom();
        firstChar = false;
      }

    });

    if (firstChar){
      _scrollToBottom();
    }

    }

    if (!mounted) return;
    setState(() => _isTyping=false);

}

void _scrollToBottom(){

 WidgetsBinding.instance.addPostFrameCallback((_){

   if (_scrollController.hasClients){
     _scrollController.animateTo(
       _scrollController.position.maxScrollExtent,
       duration: const Duration(milliseconds: 300),
       curve: Curves.easeIn,
     );
   }

 });

}


  @override
  Widget build(BuildContext context){
    return Container(
      decoration:AppTheme.buildBoxDecoration ,
      child:SafeArea(
        child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Head(title: "AI Chat", onBackTap: widget.onBackTap),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount:_messages.length,
                itemBuilder: (context,index){
                  final msg =_messages[index];
                  return Align(
                    alignment: msg.isUser
                        ?Alignment.centerRight
                        :Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ?Colors.lightBlueAccent
                            :Colors.white38,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.black87 : Colors.deepPurpleAccent,
                          fontSize: 16,
                        )
                        ,
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "AI is typing...",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal:12,vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_outlined, color:Colors.lightBlue),
                    onPressed: ()=>_sendMessage(_controller.text),
                  ),
                ],
              ),
            ),

          ],
        ) ,
      ),
    );
  }
}

class _Message{
  final String text;
  final bool isUser;
  _Message (this.text,this.isUser);
}