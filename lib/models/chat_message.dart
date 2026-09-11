class ChatMessage {
  final String id;
  final String senderName;
  final bool isUser;
  final bool isAI;
  final String text;
  final DateTime time;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.isUser,
    required this.isAI,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderName': senderName,
        'isUser': isUser,
        'isAI': isAI,
        'text': text,
        'time': time.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        isAI: json['isAI'] as bool? ?? false,
        text: json['text'] as String? ?? '',
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      );
}