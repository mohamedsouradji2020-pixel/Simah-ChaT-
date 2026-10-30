import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String title;
  final String? otherUid;

  const ChatScreen({super.key, required this.chatId, required this.title, this.otherUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _storageService = StorageService();
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _typingTimer;
  final String _myUid = FirebaseAuth.instance.currentUser!.uid;

  void _onTextChanged(String value) {
    _chatService.setTyping(widget.chatId, value.isNotEmpty);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatService.setTyping(widget.chatId, false);
    });
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    _chatService.setTyping(widget.chatId, false);
    await _chatService.sendText(widget.chatId, text);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return;
    final url = await _storageService.uploadChatImage(widget.chatId, File(file.path));
    await _chatService.sendImage(widget.chatId, url);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _chatService.setTyping(widget.chatId, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            if (widget.otherUid != null)
              StreamBuilder<bool>(
                stream: _chatService.typingStatus(widget.chatId, widget.otherUid!),
                builder: (context, snap) {
                  final typing = snap.data ?? false;
                  return Text(
                    typing ? 'écrit...' : ' ',
                    style: const TextStyle(fontSize: 12, color: AppColors.accent),
                  );
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.messagesOf(widget.chatId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snap.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Dites bonjour 👋', style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  reverse: true,
                  padding: const EdgeInsets.all(14),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final mine = msg.senderId == _myUid;
                    return _MessageBubble(message: msg, mine: mine);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.surfaceDark, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent),
              onPressed: _pickImage,
            ),
            Expanded(
              child: TextField(
                controller: _textCtrl,
                onChanged: _onTextChanged,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Écris un message...'),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  const _MessageBubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = mine ? AppColors.bubbleMine : AppColors.bubbleTheirs;
    final align = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: message.type == MessageType.image
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
          child: message.type == MessageType.image
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(imageUrl: message.mediaUrl, fit: BoxFit.cover),
                )
              : Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 15.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat.Hm().format(message.sentAt),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              if (mine) ...[
                const SizedBox(width: 4),
                Icon(
                  message.status == MessageStatus.read ? Icons.done_all : Icons.done,
                  size: 14,
                  color: message.status == MessageStatus.read ? AppColors.accent : AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
