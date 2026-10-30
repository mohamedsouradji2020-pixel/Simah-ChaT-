import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_room.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../theme.dart';
import 'chat_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatService.myChatRooms(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snap.data!;
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('Aucune conversation pour l\'instant', style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  const Text('Appuie sur + pour démarrer', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final room = rooms[i];
              return _ChatTile(room: room, myUid: myUid);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewChatScreen())),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatRoom room;
  final String myUid;
  const _ChatTile({required this.room, required this.myUid});

  @override
  Widget build(BuildContext context) {
    if (room.isGroup) {
      return _buildTile(
        context,
        title: room.groupName,
        subtitle: room.lastMessage,
        avatarText: room.groupName.isNotEmpty ? room.groupName[0].toUpperCase() : 'G',
        online: false,
      );
    }
    final otherUid = room.participants.firstWhere((p) => p != myUid, orElse: () => '');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? '...';
        final online = data?['online'] ?? false;
        return _buildTile(
          context,
          title: name,
          subtitle: room.lastMessage,
          avatarText: name.isNotEmpty ? name[0].toUpperCase() : '?',
          online: online,
          chatId: room.id,
          otherUid: otherUid,
          otherName: name,
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String avatarText,
    required bool online,
    String? chatId,
    String? otherUid,
    String? otherName,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: room.id,
              title: title,
              otherUid: otherUid,
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.25),
            child: Text(avatarText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDark, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle.isEmpty ? 'Dites bonjour 👋' : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textMuted),
      ),
      trailing: Text(
        timeago.format(room.lastMessageAt, locale: 'fr_short'),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }
}
