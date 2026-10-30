import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_room.dart';
import '../models/message.dart';

/// Gère les conversations et les messages en temps réel via Firestore.
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Liste des conversations de l'utilisateur, triées par dernier message.
  Stream<List<ChatRoom>> myChatRooms() {
    return _db
        .collection('chats')
        .where('participants', arrayContains: _uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatRoom.fromMap(d.data(), d.id)).toList());
  }

  /// Récupère (ou crée) une conversation 1-to-1 entre deux utilisateurs.
  Future<String> getOrCreateDirectChat(String otherUid) async {
    final ids = [_uid, otherUid]..sort();
    final chatId = 'direct_${ids[0]}_${ids[1]}';
    final ref = _db.collection('chats').doc(chatId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(ChatRoom(
        id: chatId,
        participants: ids,
        lastMessageAt: DateTime.now(),
      ).toMap());
    }
    return chatId;
  }

  Future<String> createGroupChat(String name, List<String> memberUids) async {
    final participants = [_uid, ...memberUids];
    final ref = await _db.collection('chats').add(ChatRoom(
      id: '',
      participants: participants,
      isGroup: true,
      groupName: name,
      lastMessageAt: DateTime.now(),
    ).toMap());
    return ref.id;
  }

  Stream<List<ChatMessage>> messagesOf(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromMap(d.data(), d.id)).toList());
  }

  Future<void> sendText(String chatId, String text) async {
    final msg = ChatMessage(
      id: '',
      senderId: _uid,
      text: text,
      type: MessageType.text,
      status: MessageStatus.sent,
      sentAt: DateTime.now(),
    );
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.collection('messages').add(msg.toMap());
    await chatRef.update({
      'lastMessage': text,
      'lastMessageAt': DateTime.now(),
      'lastSenderId': _uid,
    });
  }

  Future<void> sendImage(String chatId, String imageUrl) async {
    final msg = ChatMessage(
      id: '',
      senderId: _uid,
      text: '📷 Photo',
      type: MessageType.image,
      mediaUrl: imageUrl,
      sentAt: DateTime.now(),
    );
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.collection('messages').add(msg.toMap());
    await chatRef.update({
      'lastMessage': '📷 Photo',
      'lastMessageAt': DateTime.now(),
      'lastSenderId': _uid,
    });
  }

  Stream<bool> typingStatus(String chatId, String otherUid) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(otherUid)
        .snapshots()
        .map((d) => d.data()?['isTyping'] ?? false);
  }

  Future<void> setTyping(String chatId, bool isTyping) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(_uid)
        .set({'isTyping': isTyping});
  }
}
