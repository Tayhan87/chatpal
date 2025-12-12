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