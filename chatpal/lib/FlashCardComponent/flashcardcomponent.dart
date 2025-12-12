import "package:flutter/material.dart";
import '../FlashCardComponent/flashcard.dart';

class FlashCardView extends StatelessWidget {
  final List<FlashCard> flashCards;
  final int currentCardIndex;
  final bool isFlipped;
  final VoidCallback onNextCard;
  final VoidCallback onPreviousCard;
  final VoidCallback onFlip;
  final VoidCallback onExit;

  const FlashCardView({
    super.key,
    required this.flashCards,
    required this.currentCardIndex,
    required this.isFlipped,
    required this.onNextCard,
    required this.onPreviousCard,
    required this.onFlip,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final card = flashCards[currentCardIndex];

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Card ${currentCardIndex + 1} of ${flashCards.length}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text("Exit"),
                onPressed: onExit,
              ),
            ],
          ),
        ),

        // Linear progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: (currentCardIndex + 1) / flashCards.length,
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
              onTap: onFlip,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey<bool>(isFlipped),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(
                    minHeight: 300,
                    maxHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    color: isFlipped ? Colors.purple.shade400 : Colors.white,
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
                            isFlipped ? "ANSWER" : "QUESTION",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isFlipped
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isFlipped ? card.back : card.front,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isFlipped
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Icon(
                            Icons.touch_app,
                            color: isFlipped
                                ? Colors.white60
                                : Colors.grey.shade400,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap to flip",
                            style: TextStyle(
                              fontSize: 12,
                              color: isFlipped
                                  ? Colors.white70
                                  : Colors.grey.shade500,
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
                  backgroundColor: currentCardIndex > 0
                      ? Colors.purple.shade400
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: currentCardIndex > 0 ? onPreviousCard : null,
                label: const Text("Previous"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentCardIndex < flashCards.length - 1
                      ? Colors.purple.shade400
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                currentCardIndex < flashCards.length - 1 ? onNextCard : null,
                label: const Text("Next"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}