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
  List searchResults = [];
  Map unreadByFriend = {};
  Map previewsByFriend = {};
  bool isLoading = true;
  bool isSearching = false;

  TextEditingController searchController = TextEditingController();

  Future<void> loadFriends() async {
    try {
      final friendResult = await ApiService.getFriends(UserSession.id);
      final unreadResult = await ApiService.getUnreadMessages(UserSession.id);
      final previewResult = await ApiService.getMessagePreviews(UserSession.id);

      setState(() {
        friendRequests = friendResult["friendRequests"] ?? [];
        friends = friendResult["friends"] ?? [];
        unreadByFriend = unreadResult["unreadByFriend"] ?? {};
        previewsByFriend = previewResult["previewsByFriend"] ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> searchUsers(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final result = await ApiService.searchUsers(UserSession.id, value.trim());

      setState(() {
        searchResults = result["users"] ?? [];
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  Future<void> sendRequestFromSearch(String toUserId) async {
    final result = await ApiService.sendFriendRequest(UserSession.id, toUserId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "Friend request sent")),
    );

    await searchUsers(searchController.text);
    await loadFriends();
  }

  Future<void> acceptRequest(String requestUserId) async {
    await ApiService.acceptFriendRequest(UserSession.id, requestUserId);
    loadFriends();
  }

  Future<void> rejectRequest(String requestUserId) async {
    await ApiService.rejectFriendRequest(UserSession.id, requestUserId);
    loadFriends();
  }

  Future<void> removeFriend(String friendId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Friend"),
        content: const Text("Are you sure you want to remove this friend?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.removeFriend(UserSession.id, friendId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friend removed")),
      );

      loadFriends();
    }
  }

  bool hasUnread(String friendId) {
    return unreadByFriend[friendId] != null && unreadByFriend[friendId] > 0;
  }

  String getPreviewText(String friendId) {
    final preview = previewsByFriend[friendId];

    if (preview == null) {
      return "No messages yet";
    }

    final text = preview["text"]?.toString() ?? "";
    final senderId = preview["senderId"]?.toString() ?? "";

    if (senderId == UserSession.id) {
      return "You: $text";
    }

    return text;
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget buildSearchResultCard(Map user) {
    final bool isFriend = user["isFriend"] == true;
    final bool requestSent = user["requestSent"] == true;
    final bool requestReceived = user["requestReceived"] == true;

    String buttonText = "Add";
    bool disableButton = false;

    if (isFriend) {
      buttonText = "Friends";
      disableButton = true;
    } else if (requestSent) {
      buttonText = "Sent";
      disableButton = true;
    } else if (requestReceived) {
      buttonText = "Pending";
      disableButton = true;
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user["email"] ?? "",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: disableButton
                ? null
                : () async {
                    await sendRequestFromSearch(user["_id"]);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F89),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserCard(
    Map user, {
    Widget? trailing,
    bool boldName = false,
    String previewText = "",
    bool boldPreview = false,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"] ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: boldName ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  previewText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: boldPreview ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: searchUsers,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search users",
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (searchController.text.isNotEmpty) ...[
                      const Text(
                        "Results",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (isSearching)
                        const Center(child: CircularProgressIndicator())
                      else if (searchResults.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text("No users found"),
                        )
                      else
                        Column(
                          children: searchResults.map((user) {
                            return buildSearchResultCard(user);
                          }).toList(),
                        ),
                      const SizedBox(height: 10),
                    ],
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
                                previewText: request["email"] ?? "",
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
                              final previewText = getPreviewText(friendId);

                              return buildUserCard(
                                friend,
                                boldName: unread,
                                previewText: previewText,
                                boldPreview: unread,
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
                                    IconButton(
                                      onPressed: () => removeFriend(friendId),
                                      icon: const Icon(
                                        Icons.person_remove,
                                        color: Colors.red,
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