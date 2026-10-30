enum MessageType { text, image, system }

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final MessageType type;
  final MessageStatus status;
  final DateTime sentAt;
  final String mediaUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.sentAt,
    this.mediaUrl = '',
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values[map['type'] ?? 0],
      status: MessageStatus.values[map['status'] ?? 0],
      sentAt: map['sentAt']?.toDate() ?? DateTime.now(),
      mediaUrl: map['mediaUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type.index,
      'status': status.index,
      'sentAt': sentAt,
      'mediaUrl': mediaUrl,
    };
  }
}
