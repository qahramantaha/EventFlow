import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_session.dart';
import 'chat_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List friendRequests = [];
  List friends = [];
  Map unreadByFriend = {};
  bool isLoading = true;

  Future<void> loadFriends() async {
    try {
      final friendResult = await ApiService.getFriends(UserSession.id);
      final unreadResult = await ApiService.getUnreadMessages(UserSession.id);

      setState(() {
        friendRequests = friendResult["friendRequests"] ?? [];
        friends = friendResult["friends"] ?? [];
        unreadByFriend = unreadResult["unreadByFriend"] ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> acceptRequest(String requestUserId) async {
    await ApiService.acceptFriendRequest(UserSession.id, requestUserId);
    loadFriends();
  }

  Future<void> rejectRequest(String requestUserId) async {
    await ApiService.rejectFriendRequest(UserSession.id, requestUserId);
    loadFriends();
  }

  bool hasUnread(String friendId) {
    return unreadByFriend[friendId] != null && unreadByFriend[friendId] > 0;
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Widget buildUserCard(
    Map user, {
    Widget? trailing,
    bool boldName = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF005F89),
            child: Text(
              user["name"] != null && user["name"].toString().isNotEmpty
                  ? user["name"][0].toUpperCase()
                  : "?",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user["name"] ?? "",
              style: TextStyle(
                fontSize: 16,
                fontWeight: boldName ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005F89),
        title: const Text(
          "Friends",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadFriends,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Friend Requests",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    friendRequests.isEmpty
                        ? const Text("No friend requests")
                        : Column(
                            children: friendRequests.map((request) {
                              return buildUserCard(
                                request,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        acceptRequest(request["_id"]);
                                      },
                                      icon: const Icon(Icons.check, color: Colors.green),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        rejectRequest(request["_id"]);
                                      },
                                      icon: const Icon(Icons.close, color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 24),
                    const Text(
                      "My Friends",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    friends.isEmpty
                        ? const Text("No friends added yet")
                        : Column(
                            children: friends.map((friend) {
                              final friendId = friend["_id"];
                              final unread = hasUnread(friendId);

                              return buildUserCard(
                                friend,
                                boldName: unread,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (unread)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    IconButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              friendId: friendId,
                                              friendName: friend["name"] ?? "",
                                            ),
                                          ),
                                        );
                                        loadFriends();
                                      },
                                      icon: const Icon(
                                        Icons.message_outlined,
                                        color: Color(0xFF005F89),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}