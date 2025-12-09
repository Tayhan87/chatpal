import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class PomodoroScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const PomodoroScreen({super.key, required this.onBackTap});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _selectedMinutes = 25;
  int _selectedSeconds = 0; // For custom seconds selection
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Study quotes
  final List<String> _quotes = [
    "Education is the most powerful weapon which you can use to change the world. - Nelson Mandela",
    "The expert in anything was once a beginner. - Helen Hayes",
    "Success is the sum of small efforts repeated day in and day out. - Robert Collier",
    "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
    "The beautiful thing about learning is that no one can take it away from you. - B.B. King",
    "Study while others are sleeping; work while others are loafing. - William A. Ward",
    "The capacity to learn is a gift; the ability to learn is a skill. - Brian Herbert",
    "Learning is not attained by chance, it must be sought for with ardor. - Abigail Adams",
  ];

  // Study jokes
  final List<String> _jokes = [
    "Why did the student eat his homework? Because the teacher said it was a piece of cake! 😄",
    "What's a math teacher's favorite place? Times Square! 🔢",
    "Why was the equal sign so humble? Because it knew it wasn't less than or greater than anyone else! =",
    "What do you call a person who keeps talking when nobody's listening? A teacher! 😅",
    "Why don't scientists trust atoms? Because they make up everything! ⚛️",
    "What's the king of all school supplies? The ruler! 👑",
    "Why did the student bring a ladder to class? To reach high grades! 📚",
    "What did one pencil say to the other? You're looking sharp today! ✏️",
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (_selectedMinutes * 60) + _selectedSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      if (_remainingSeconds == 0) {
        _remainingSeconds = (_selectedMinutes * 60) + _selectedSeconds;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = (_selectedMinutes * 60) + _selectedSeconds;
    });
  }

  void _onTimerComplete() {
    // Play notification sound
    _playNotificationSound();

    // Generate random number to decide quote or joke
    final random = Random();
    final randomNumber = random.nextInt(100);
    final isEven = randomNumber % 2 == 0;

    String message;
    if (isEven) {
      message = _quotes[random.nextInt(_quotes.length)];
    } else {
      message = _jokes[random.nextInt(_jokes.length)];
    }

    _showCompletionDialog(message, isEven);
  }

  Future<void> _playNotificationSound() async {
    try {
      // Using a simple beep sound - you can replace with your own audio file
      // For now, we'll just use the system notification
      // await _audioPlayer.play(AssetSource('notification.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _showCompletionDialog(String message, bool isQuote) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: Colors.amber,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text("Time's Up!"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isQuote ? Colors.blue.shade50 : Colors.orange
                        .shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isQuote ? Colors.blue.shade200 : Colors.orange
                          .shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isQuote ? Icons.format_quote : Icons.emoji_emotions,
                        color: isQuote ? Colors.blue.shade400 : Colors.orange
                            .shade400,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isQuote ? "Inspirational Quote" : "Study Joke",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isQuote ? Colors.blue.shade700 : Colors.orange
                              .shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _resetTimer();
                },
                child: const Text(
                  "Start Over",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(
        2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery
        .of(context)
        .size;
    final bool isSmallScreen = size.height < 700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA4A4F5),
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
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
                      "Pomodoro Timer",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Content (Use Expanded to fill remaining space)
              Expanded(
                child: SingleChildScrollView(
                  // Use smaller padding on small screens
                  padding: EdgeInsets.symmetric(
                      horizontal: 24, vertical: isSmallScreen ? 10 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- RESPONSIVE TIMER ---
                      Container(
                        // Dynamic size: 35% of screen height, but max 280
                        width: min(size.width * 0.7, 280),
                        height: min(size.width * 0.7, 280),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isRunning ? Icons.timer : Icons.timer_outlined,
                                size: isSmallScreen ? 40 : 50, // Smaller icon
                                color: Colors.purple.shade400,
                              ),
                              SizedBox(height: isSmallScreen ? 10 : 20),
                              Text(
                                _formatTime(_remainingSeconds),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 48 : 56,
                                  // Smaller font
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isRunning ? "Focus Time" : "Ready to Focus",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dynamic Spacing
                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // --- TIME SELECTION ---
                      if (!_isRunning && _remainingSeconds ==
                          (_selectedMinutes * 60) + _selectedSeconds)
                        Column(
                          children: [
                            Text(
                              "Select Focus Time",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade400,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildTimeOption(0, 5, isSeconds: true,
                                    isSmall: isSmallScreen),
                                ...[5, 10, 15, 25, 30, 45, 60].map((minutes) {
                                  return _buildTimeOption(
                                      minutes, 0, isSmall: isSmallScreen);
                                }).toList(),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 15 : 30),
                          ],
                        ),

                      // --- CONTROL BUTTONS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isRunning ||
                              _remainingSeconds != ((_selectedMinutes * 60) +
                                  _selectedSeconds))
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _resetTimer,
                                icon: const Icon(Icons.refresh),
                                iconSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(width: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _isRunning ? _pauseTimer : _startTimer,
                              icon: Icon(
                                  _isRunning ? Icons.pause : Icons.play_arrow),
                              iconSize: 48,
                              color: Colors.purple.shade400,
                              padding: const EdgeInsets.all(20),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 15 : 30),

                      // --- INFO CARD ---
                      Container(
                        padding: const EdgeInsets.all(16), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue.shade900,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                "Stay focused! You'll get a surprise\nmessage when time's up! 🎉",
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 13, // Slightly smaller text
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(int minutes, int seconds,
      {bool isSeconds = false, bool isSmall = false}) {
    final isSelected = _selectedMinutes == minutes &&
        _selectedSeconds == seconds;
    final displayValue = isSeconds ? seconds : minutes;
    final displayUnit = isSeconds ? "sec" : "min";

    // Smaller boxes on small screens (60px instead of 70px)
    final double boxSize = isSmall ? 60 : 70;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMinutes = minutes;
          _selectedSeconds = seconds;
          _remainingSeconds = (minutes * 60) + seconds;
        });
      },
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.5) : Colors.purple
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple.shade400 : Colors.transparent,
            width: 3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$displayValue",
                style: TextStyle(
                  fontSize: isSmall ? 20 : 24, // Responsive font
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.red.shade50 : Colors.white,
                ),
              ),
              Text(
                displayUnit,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.red.shade50 : Colors.white
                      .withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}