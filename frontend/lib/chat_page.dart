import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_session.dart';

class ChatPage extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatPage({
    super.key,
    required this.friendId,
    required this.friendName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List messages = [];
  bool isLoading = true;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> loadMessages() async {
    try {
      await ApiService.markMessagesAsRead(UserSession.id, widget.friendId);
      final result = await ApiService.getMessages(UserSession.id, widget.friendId);

      setState(() {
        messages = result;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final text = messageController.text.trim();
    messageController.clear();

    await ApiService.sendMessage(
      UserSession.id,
      widget.friendId,
      text,
    );

    await loadMessages();
  }

  bool isMyMessage(Map message) {
    return message["senderId"].toString() == UserSession.id;
  }

  String formatTime(String? dateText) {
    if (dateText == null || dateText.isEmpty) return "";
    try {
      final date = DateTime.parse(dateText).toLocal();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    } catch (e) {
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1F2D3D)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF005F89),
              child: Text(
                widget.friendName.isNotEmpty
                    ? widget.friendName[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.friendName,
                style: const TextStyle(
                  color: Color(0xFF1F2D3D),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(
                        child: Text(
                          "No messages yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final mine = isMyMessage(message);

                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? const Color(0xFF005F89)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(mine ? 18 : 4),
                                  bottomRight: Radius.circular(mine ? 4 : 18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message["text"] ?? "",
                                    style: TextStyle(
                                      color: mine ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatTime(message["createdAt"]),
                                    style: TextStyle(
                                      color: mine
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message...",
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF005F89),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}