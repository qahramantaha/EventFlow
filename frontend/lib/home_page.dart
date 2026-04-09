import 'package:flutter/material.dart';
import 'map_page.dart';
import 'main_page.dart';
import 'api_service.dart';
import 'user_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  int friendRequestsCount = 0;
  int unreadMessagesCount = 0;
  int goingEventsCount = 0;
  List notifications = [];

  Future<void> loadHomeNotifications() async {
    try {
      final result = await ApiService.getHomeNotifications(UserSession.id);

      if (!mounted) return;

      setState(() {
        friendRequestsCount = result["friendRequestsCount"] ?? 0;
        unreadMessagesCount = result["unreadMessagesCount"] ?? 0;
        goingEventsCount = result["goingEventsCount"] ?? 0;
        notifications = result["notifications"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  IconData getNotificationIcon(String type) {
    if (type == "friend_request") return Icons.person_add;
    if (type == "message") return Icons.message;
    if (type == "event") return Icons.event_available;
    return Icons.notifications;
  }

  Color getNotificationColor(String type) {
    if (type == "friend_request") return Colors.deepPurple;
    if (type == "message") return Colors.green;
    if (type == "event") return Colors.orange;
    return Colors.blue;
  }

  @override
  void initState() {
    super.initState();
    loadHomeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHomeNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "My Events: $goingEventsCount",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "Notifications: ${notifications.length} update${notifications.length == 1 ? "" : "s"}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: Color(0xFF005F89),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Notifications",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2D3D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          notifications.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F8FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "You're all caught up.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : Column(
                                  children: notifications.map((notification) {
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F8FA),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: getNotificationColor(
                                              notification["type"],
                                            ),
                                            child: Icon(
                                              getNotificationIcon(
                                                notification["type"],
                                              ),
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              notification["text"] ?? "",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final mainPage =
                            context.findAncestorStateOfType<MainPageState>();
                        mainPage?.goToPage(1);
                      },
                      child: const Text("View Events"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapPage(),
                          ),
                        );
                      },
                      child: const Text("Open Map"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}