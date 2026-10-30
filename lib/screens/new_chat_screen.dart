import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

/// Liste tous les autres utilisateurs pour démarrer une conversation.
class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle discussion')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final users = snap.data!.docs.where((d) => d.id != myUid).toList();
          if (users.isEmpty) {
            return const Center(
              child: Text('Personne d\'autre pour le moment', style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final data = users[i].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Utilisateur';
              final about = data['about'] ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.25),
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                title: Text(name),
                subtitle: Text(about, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () async {
                  final chatId = await chatService.getOrCreateDirectChat(users[i].id);
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId, title: name, otherUid: users[i].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
