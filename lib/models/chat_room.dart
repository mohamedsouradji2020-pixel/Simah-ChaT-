class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastSenderId;
  final bool isGroup;
  final String groupName;
  final String groupPhotoUrl;
  final Map<String, int> unreadCount;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    required this.lastMessageAt,
    this.lastSenderId = '',
    this.isGroup = false,
    this.groupName = '',
    this.groupPhotoUrl = '',
    this.unreadCount = const {},
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt']?.toDate() ?? DateTime.now(),
      lastSenderId: map['lastSenderId'] ?? '',
      isGroup: map['isGroup'] ?? false,
      groupName: map['groupName'] ?? '',
      groupPhotoUrl: map['groupPhotoUrl'] ?? '',
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'lastSenderId': lastSenderId,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupPhotoUrl': groupPhotoUrl,
      'unreadCount': unreadCount,
    };
  }
}
