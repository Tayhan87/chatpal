import "package:flutter/material.dart";
import "dart:async";

class AIChatScreen extends StatefulWidget {
  final VoidCallback onBackTap;
  const AIChatScreen({super.key, required this.onBackTap});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For auto-scrolling
  final List<_Message> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Don't forget to dispose!
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true));
    });
    _scrollToBottom(); // Scroll down
    _controller.clear();

    // Simulate AI typing
    _simulateResponse(
        "Hello Tayhan 👋, this is a sample Copilot response with typing animation.");
  }

  void _simulateResponse(String response) async {
    setState(() => _isTyping = true);

    String displayed = "";
    bool firstChar = true;
    for (int i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      // Make sure the widget is still mounted
      if (!mounted) return;

      setState(() {
        displayed = response.substring(0, i + 1);
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages[_messages.length - 1] = _Message(displayed, false);
        } else {
          _messages.add(_Message(displayed, false));
          firstChar = false; // Flag that we added the message
        }
      });
      // Only scroll when the new message bubble is first added
      if (firstChar) {
        _scrollToBottom();
      }
    }

    if (!mounted) return;
    setState(() => _isTyping = false);
  }

  // Function to scroll to the end of the list
  void _scrollToBottom() {
    // We use addPostFrameCallback to wait for the UI to build
    // before trying to scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0E0E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBackTap,
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.black54, size: 28),
                  ),
                  const Text(
                    "AI Chat Interface",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                ],
              ),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // Assign the controller
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- AI Typing Indicator ---
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

              // Input field
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  _Message(this.text, this.isUser);
}

// Removed the redundant 'bool _isTyping = false;' from here.