import 'package:flutter/material.dart';
import 'home_page.dart';
import 'events_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';
import 'api_service.dart';
import 'user_session.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  int unreadCount = 0;

  final List<Widget> pages = [
    const HomePage(),
    const EventsPage(),
    const FriendsPage(),
    const ProfilePage(),
  ];

  void goToPage(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 2) {
      loadUnreadCount();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final result = await ApiService.getUnreadMessages(UserSession.id);

      setState(() {
        unreadCount = result["totalUnread"] ?? 0;
      });
    } catch (e) {
      setState(() {
        unreadCount = 0;
      });
    }
  }

  Widget buildFriendsIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.people),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 9 ? "9+" : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: goToPage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF005F89),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: buildFriendsIcon(),
            label: "Friends",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}